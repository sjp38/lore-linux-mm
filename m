Date: Thu, 26 Feb 1998 22:36:18 GMT
Message-Id: <199802262236.WAA03891@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802261300.OAA03665@boole.fs100.suse.de>
References: <199802260805.JAA00715@cave.BitWizard.nl>
	<199802261300.OAA03665@boole.fs100.suse.de>
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: R.E.Wolff@BitWizard.nl, sct@dcs.ed.ac.uk, torvalds@transmeta.com, blah@kvack.org, H.H.vanRiel@fys.ruu.nl, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 26 Feb 1998 14:00:18 +0100, "Dr. Werner Fink" <werner@suse.de> said:

>> "swapping" (as opposed to paging) is becoming a required
>> strategy

> In other words: the pages swapped in or cached into the swap cache
> should get their initial age which its self is calculated out of the
> current priority of the corresponding process?

No, the idea is that we stop paging one or more processes altogether
and suspend them for a while, flushing their entire resident set out
to disk for the duration.  It's something very valuable when you are
running big concurrent batch jobs, and essentially moves the fairness
problem out of the memory space and into the scheduler, where we _can_
make a reasonable stab at being fair.

--Stephen
