
        Accepts auto-translate terms, not case-sensitive.
         "//cor [on/off]"
         "//cor roll [n] [job/roll_name]" -- set roll
         "//cor cc [n/off]"         -- Use crooked cards on roll [n] (default is 1st roll, 0 is off)
         "//cor save"               -- save settings on per character basis
            
        when setting rolls with commands it will check [job/roll_name] against the rolls job,
        next checks if a roll name is or begins with [job/roll_name].
        
            [n] is roll order

            Examples:
            "//cor roll 1 war" or "//cor roll 1 fight" or "//cor roll 1 fighter's roll"
            
            "//cor roll 2 thf" or "//cor roll 1 rog" or "//cor roll 1 rogue's roll"
