Date: Thu, 26 Feb 1998 14:00:18 +0100
Message-Id: <199802261300.OAA03665@boole.fs100.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <199802260805.JAA00715@cave.BitWizard.nl>
	(R.E.Wolff@BitWizard.nl)
Subject: Re: Fairness in love and swapping
Sender: owner-linux-mm@kvack.org
To: R.E.Wolff@BitWizard.nl
Cc: sct@dcs.ed.ac.uk, torvalds@transmeta.comsct@dcs.ed.ac.uk, blah@kvack.org, H.H.vanRiel@fys.ruu.nl, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



[...]

> 
> but if the system would be "fair" we would get: 
> 
>           0                  5                 10            15
>       P1  <------ swapping --- like --- mad ------------------- ....
> 
>           0                  5                 10            15
>       P2  <------ swapping --- like --- mad ------------------- ....
> 
> 
> So.... In some cases, this behaviour is exactly what you want. What we
> really need is that some mechanism that actually determines in the
> first and last case that the system is thrashing like hell, and that
> "swapping" (as opposed to paging) is becoming a required
> strategy. That would mean putting a "page-in" ban on each process for
> relatively long stretches of time. These should become longer with
> each time that it occurs. That way, you will get:
> 
>           0        50           51      100
>       P1  <in memory>...........<in memory> 
> 
>           0          1        50           51      100
>       P2  ...........<in memory>...........<in memory> 
> 
> 
> By making the periods longer, you will cater for larger machines where
> getting the working set into main memory might take a long time (think
> about a machine with 4G core, and a disk subsystem that reaches 4Mb (*)
> per second on "random access paging". That's a quarter of an hour
> worth of swapping before that 3.6G process is swapped in....)

In other words: the pages swapped in or cached into the swap cache should
get their initial age which its self is calculated out of the current priority
of the corresponding process?


         Werner
