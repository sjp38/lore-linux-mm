Date: Fri, 27 Feb 1998 00:20:09 +0100
Message-Id: <199802262320.AAA21643@boole.fs100.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <199802262236.WAA03891@dax.dcs.ed.ac.uk> (sct@dcs.ed.ac.uk)
Subject: Re: Fairness in love and swapping
Sender: owner-linux-mm@kvack.org
To: sct@dcs.ed.ac.uk
Cc: R.E.Wolff@BitWizard.nl, torvalds@transmeta.com, blah@kvack.org, H.H.vanRiel@fys.ruu.nl, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >> "swapping" (as opposed to paging) is becoming a required
> >> strategy
> 
> > In other words: the pages swapped in or cached into the swap cache
> > should get their initial age which its self is calculated out of the
> > current priority of the corresponding process?
> 
> No, the idea is that we stop paging one or more processes altogether
> and suspend them for a while, flushing their entire resident set out
> to disk for the duration.  It's something very valuable when you are
> running big concurrent batch jobs, and essentially moves the fairness
> problem out of the memory space and into the scheduler, where we _can_
> make a reasonable stab at being fair.

Ohmm ... yes, but it's a pity because the diagrams of Roger took an old idea
of mine back into my mind :)  The idea was simply to give a process an
advantage over the others within its time slice by simply makeing
touch_page(), age_page(), and a new inline intial_age() depending on the
amount of the process time slice.


            Werner
