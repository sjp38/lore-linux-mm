Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1E3036B00B0
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 13:29:38 -0400 (EDT)
Subject: Re: [PATCH v3 0/5] kmemleak: few small cleanups and clear command
	support
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
References: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
Content-Type: text/plain
Date: Mon, 07 Sep 2009 18:29:30 +0100
Message-Id: <1252344570.23780.110.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Luis R. Rodriguez" <lrodriguez@Atheros.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, mcgrof@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 2009-09-04 at 17:44 -0700, Luis R. Rodriguez wrote:
> Here is my third respin, this time rebased ontop of:
> 
> git://linux-arm.org/linux-2.6 kmemleak
> 
> As suggested by Catalin we now clear the list by only painting reported
> unreferenced objects and the color we use is grey to ensure future
> scans are possible on these same objects to account for new allocations
> in the future referenced on the cleared objects.
> 
> Patch 3 is now a little different, now with a paint_ptr() and
> a __paint_it() helper.

Thanks for the patches. They look ok now, I'll merge them tomorrow to my
kmemleak branch and give them a try.

> I tested this by clearing kmemleak after bootup, then writing my
> own buggy module which kmalloc()'d onto some internal pointer,
> scanned, unloaded, and scanned again and then saw a new shiny
> report come up:

BTW, kmemleak comes with a test module which does this.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
