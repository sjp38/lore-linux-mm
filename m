Date: Mon, 2 Aug 2004 20:34:58 -0400 (EDT)
From: Song Jiang <sjiang@CS.WM.EDU>
Subject: Re: [PATCH] token based thrashing control
In-Reply-To: <410DCEBC.8030600@kolivas.org>
Message-ID: <Pine.LNX.4.44.0408022018080.8702-100000@va.cs.wm.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@osdl.org>, fchen@CS.WM.EDU, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When there is memory competition among multiple processes,
Which process grabs the token first is important.
A process with its memory demand exceeding the total
ram gets the token first and finally has to give it up 
due to a time-out would have little performance gain from token,
It could also hurt others. Ideally we could make small processes
more easily grab the token first and enjoy the benifis from
token. That is, we want to protect those that are deserved to be
protected. Can we take the rss or other available memory demand
information for each process into the consideration of whether 
a token should be taken, or given up and how long a token is held.  
  Song

On Mon, 2 Aug 2004, Con Kolivas wrote:

> Con Kolivas wrote:
> > Rik van Riel wrote:
> > 
> >> On Mon, 2 Aug 2004, Con Kolivas wrote:
> >>
> >>
> >>> We have some results that need interpreting with contest.
> >>> mem_load:
> >>> Kernel    [runs]    Time    CPU%    Loads    LCPU%    Ratio
> >>> 2.6.8-rc2      4    78    146.2    94.5    4.7    1.30
> >>> 2.6.8-rc2t     4    318    40.9    95.2    1.3    5.13
> >>>
> >>> The "load" with mem_load is basically trying to allocate 110% of free 
> >>> ram, so the number of "loads" although similar is not a true 
> >>> indication of how much ram was handed out to mem_load. What is 
> >>> interesting is that since mem_load runs continuously and constantly 
> >>> asks for too much ram it seems to be receiving the token most 
> >>> frequently in preference to the cc processes which are short lived. 
> >>> I'd say it is quite hard to say convincingly that this is bad because 
> >>> the point of this patch is to prevent swap thrash.
> >>
> >>
> >>
> >> It may be worth trying with a shorter token timeout
> >> time - maybe even keeping the long ineligibility ?
> > 
> > 
> > Give them a "refractory" bit which is set if they take the token? Next 
> > time they try to take the token unset the refractory bit instead of 
> > taking the token.
> 
> Or take that concept even further; Give them an absolute refractory 
> period where they cannot take the token again and a relative refractory 
> bit which can only be reset after the refractory period is over.
> 
> Con
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
