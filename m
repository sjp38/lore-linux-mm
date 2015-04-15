Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0406F6B006C
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 10:34:27 -0400 (EDT)
Received: by wiun10 with SMTP id n10so62475838wiu.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 07:34:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i6si8420611wjs.169.2015.04.15.07.34.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 07:34:25 -0700 (PDT)
Date: Wed, 15 Apr 2015 15:34:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
Message-ID: <20150415143420.GG14842@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
 <552E6486.6070705@hp.com>
 <20150415142731.GI17717@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150415142731.GI17717@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Waiman Long <waiman.long@hp.com>, Linux-MM <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 15, 2015 at 04:27:31PM +0200, Peter Zijlstra wrote:
> On Wed, Apr 15, 2015 at 09:15:50AM -0400, Waiman Long wrote:
> > I had included your patch with the 4.0 kernel and booted up a 16-socket
> > 12-TB machine. I measured the elapsed time from the elilo prompt to the
> > availability of ssh login. Without the patch, the bootup time was 404s. It
> > was reduced to 298s with the patch. So there was about 100s reduction in
> > bootup time (1/4 of the total).
> 
> But you cheat! :-)
> 
> How long between power on and the elilo prompt? Do the 100 seconds
> matter on that time scale?

Calling it cheating is a *bit* harsh as the POST times vary considerably
between manufacturers. While I'm interested in Waiman's answer, I'm told
that those that really care about minimising reboot times will use kexec
to avoid POST.  The 100 seconds is 100 seconds, whether that is 25% in
all cases is a different matter.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
