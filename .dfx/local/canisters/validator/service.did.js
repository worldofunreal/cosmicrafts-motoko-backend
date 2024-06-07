export const idlFactory = ({ IDL }) => {
  const Validator = IDL.Service({
    'validateGame' : IDL.Func(
        [IDL.Float64, IDL.Float64, IDL.Float64, IDL.Float64],
        [IDL.Bool, IDL.Text],
        ['query'],
      ),
  });
  return Validator;
};
export const init = ({ IDL }) => { return []; };
