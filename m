Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id A95FD6B006C
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 10:27:46 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so48971302wgy.2
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 07:27:46 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id dd10si8441434wjb.53.2015.04.15.07.27.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 07:27:45 -0700 (PDT)
Date: Wed, 15 Apr 2015 16:27:31 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
Message-ID: <20150415142731.GI17717@twins.programming.kicks-ass.net>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
 <552E6486.6070705@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <552E6486.6070705@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 15, 2015 at 09:15:50AM -0400, Waiman Long wrote:
> I had included your patch with the 4.0 kernel and booted up a 16-socket
> 12-TB machine. I measured the elapsed time from the elilo prompt to the
> availability of ssh login. Without the patch, the bootup time was 404s. It
> was reduced to 298s with the patch. So there was about 100s reduction in
> bootup time (1/4 of the total).

But you cheat! :-)

How long between power on and the elilo prompt? Do the 100 seconds
matter on that time scale?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
