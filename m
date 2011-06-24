Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E4962900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 08:51:36 -0400 (EDT)
Date: Fri, 24 Jun 2011 13:51:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Root-causing kswapd spinning on Sandy Bridge laptops?
Message-ID: <20110624125131.GQ9396@suse.de>
References: <BANLkTik7ubq9ChR6UEBXOo5D9tn3mMb1Yw@mail.gmail.com>
 <BANLkTikKwbsRD=WszbaUQQMamQbNXFdsPA@mail.gmail.com>
 <4E0465D8.3080005@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4E0465D8.3080005@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: P?draig Brady <P@draigBrady.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, linux-mm@kvack.org

On Fri, Jun 24, 2011 at 11:24:24AM +0100, P?draig Brady wrote:
> On 24/06/11 10:27, Minchan Kim wrote:
> > Hi Andrew,
> > 
> > Sorry but right now I don't have a time to dive into this.
> > But it seems to be similar to the problem Mel is looking at.
> > Cced him.
> > 
> > Even, Padraig Brady seem to have a reproducible scenario.
> > I will look when I have a time.
> > I hope I will be back sooner or later.
> 
> My reproducer is (I've 3GB RAM, 1.5G swap):
>   dd bs=1M count=3000 if=/dev/zero of=spin.test
> 
> To stop it spinning I just have to uncache the data,
> the handiest way being:
>   rm spin.test
> 
> To confirm, the top of the profile I posted is:
>   i915_gem_object_bind_to_gtt
>     shrink_slab
> 

I don't think it's an i915 bug. Another candidate fix in the other
thread that Padraig started.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
