Date: Wed, 16 Apr 2008 20:30:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/4] Add a basic debugging framework for memory initialisation
Message-ID: <20080416193017.GA13968@csn.ul.ie>
References: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie> <20080416135118.1346.72244.sendpatchset@skynet.skynet.ie> <20080416140431.GD24383@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080416140431.GD24383@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (16/04/08 16:04), Ingo Molnar didst pronounce:
> 
> * Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > +static __init int set_mminit_debug_level(char *str)
> > +{
> > +	get_option(&str, &mminit_debug_level);
> > +	return 0;
> > +}
> > +early_param("mminit_debug_level", set_mminit_debug_level);
> 
> another small suggestion: could you please also add a Kconfig method of 
> enabling it, dependent on KERNEL_DEBUG, default-off (for now). The best 
> would be not a numeric switch but something that gets randomized by 
> "make randconfig". I.e. an on/off switch kind of things.
> 

Makes sense. I've this and your other suggestions incorporated. It'll be
part of V2.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
