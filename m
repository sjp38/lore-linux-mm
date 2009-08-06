Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 361946B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 08:04:20 -0400 (EDT)
Date: Thu, 6 Aug 2009 14:04:17 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [11/19] HWPOISON: Refactor truncate to allow direct
	truncating of page v2
Message-ID: <20090806120417.GC22124@basil.fritz.box>
References: <200908051136.682859934@firstfloor.org> <20090805093638.D3754B15D8@basil.firstfloor.org> <20090805102008.GB17190@wotan.suse.de> <20090805134607.GH11385@basil.fritz.box> <20090805140145.GB28563@wotan.suse.de> <20090805141001.GJ11385@basil.fritz.box> <20090805141642.GB23992@wotan.suse.de> <20090806134830.4f3931d2@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090806134830.4f3931d2@skybase>
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> This is not relevant for s390, as current machines do transparent memory
> sparing if a memory module goes bad. Really old machines reported bad
> memory to the OS by means of a machine check (storage error uncorrected
> and storage error corrected). I have never seen this happen, the level
> below the OS deals with these errors for us.

Ok fine. It's for the poorer cousins then who can't afford memory mirroring.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
