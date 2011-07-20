Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4A61A6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 04:30:44 -0400 (EDT)
Date: Wed, 20 Jul 2011 09:30:36 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: kmemleak fails to report detected leaks after allocation
 failure
Message-ID: <20110720083036.GG28726@e102109-lin.cambridge.arm.com>
References: <20110719211438.GA21588@elliptictech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110719211438.GA21588@elliptictech.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Bowler <nbowler@elliptictech.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jul 19, 2011 at 10:14:38PM +0100, Nick Bowler wrote:
> I just ran into a somewhat amusing issue with kmemleak.  After running
> for a while (10 days), and detecting about 100 "suspected memory leaks",
> kmemleak ultimately reported:
> 
>   kmemleak: Cannot allocate a kmemleak_object structure
>   kmemleak: Automatic memory scanning thread ended
>   kmemleak: Kernel memory leak detector disabled
> 
> OK, so something failed and kmemleak apparently can't recover from
> this.  However, at this point, it appears that kmemleak has *also*
> lost the ability to report the earlier leaks that it actually
> detected.
> 
>   cat: /sys/kernel/debug/kmemleak: Device or resource busy
> 
> It seems to me that kmemleak shouldn't lose the ability to report leaks
> that it already detected after it disables itself due to an issue that
> was potentially caused by the very leaks that it managed to detect
> (unlikely in this instance, but still...).

Very good point, I haven't thought of this. I'll try to improve this
part.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
