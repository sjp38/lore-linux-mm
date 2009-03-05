Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 847FF6B00C5
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 08:49:32 -0500 (EST)
Date: Thu, 5 Mar 2009 21:48:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: drop_caches ...
Message-ID: <20090305134842.GB22442@localhost>
References: <200903041057.34072.M4rkusXXL@web.de> <200903041947.41542.M4rkusXXL@web.de> <20090305004850.GA6045@localhost> <200903051255.35407.M4rkusXXL@web.de> <20090305133603.GA22442@localhost> <20090305134528.GC646@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090305134528.GC646@ics.muni.cz>
Sender: owner-linux-mm@kvack.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: Markus <M4rkusXXL@web.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zdenek Kabelac <zkabelac@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 05, 2009 at 03:45:28PM +0200, Lukas Hejtmanek wrote:
> On Thu, Mar 05, 2009 at 09:36:03PM +0800, Wu Fengguang wrote:
> >           size = file size in bytes
> >         cached = cached pages
> > 
> > So it's normal that (size > cached).
> 
> I guess, the question was how it can happen that (cached > size).

Ah, because cached size is rounded up to page boundaries,
so a 1K sized file will have 4K cached size.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
