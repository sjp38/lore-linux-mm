Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA12225
	for <linux-mm@kvack.org>; Fri, 27 Feb 1998 07:03:21 -0500
Date: Fri, 27 Feb 1998 12:26:23 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802270729.IAA00680@cave.BitWizard.nl>
Message-ID: <Pine.LNX.3.91.980227122502.19469A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rogier Wolff <R.E.Wolff@BitWizard.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Feb 1998, Rogier Wolff wrote:

> Rik van Riel wrote:
> > fil_dsc - number of file descriptors (if it has loads of
> >           file descriptors, it communicates a lot with the environment
> >           and is less likely a batch process)
> 
> At shell they have 3D datasets. 
> 
> They store them in an "array of 2D files". That way you can do:
> 
>          (echo "P5";echo 230 500;cat file24) | xv -
> 
> A program processing these e.g. in 2D, but then along a different axis
> as over here, would have all 300 files open at the same time.......

OK, we could take the number of non-file file descriptors.
The number of network connections (to not-self) is usually
a good indication of program interaction. The number of
network I/Os also is a good bonus.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
