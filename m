Date: Tue, 23 Dec 2003 17:13:51 +0100
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: load control demotion/promotion policy
Message-ID: <20031223161351.GB6082@k3.hellgate.ch>
References: <20031221235541.GA22896@k3.hellgate.ch> <Pine.LNX.4.44.0312211913420.26393-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0312211913420.26393-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, Andrew Morton <akpm@digeo.com>
List-ID: <linux-mm.kvack.org>

On Sun, 21 Dec 2003 20:34:30 -0500, Rik van Riel wrote:
> I agree, pageout in 2.6 needs to be finetuned a bit more
> to get that extra factor of 2 performance that's hiding
> in a dark corner.
> 
> However, I don't think that obviates the need for load
> control.  You have convinced me, though, that load
> control is an emergency thing and shouldn't be meant
> for regular use. 

We are in violent agreement then.

> Then again, I've wanted to work on load control for
> years and would like to use this opportunity to have
> some fun.
> 
> If you'd rather work on tuning the pageout code to make
> that faster, I'd be happy to play around a bit with the
> load control code ;))

I bet :-). I meant to save the load control stuff as a dessert, for later
(i.e. after the regressions are fixed where possible). Bad thinking I
reckon.

Roger
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
