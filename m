Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 655816B01AD
	for <linux-mm@kvack.org>; Thu, 24 Jun 2010 12:27:06 -0400 (EDT)
Date: Thu, 24 Jun 2010 18:27:02 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 50/52] mm: implement per-zone shrinker
Message-ID: <20100624162702.GS578@basil.fritz.box>
References: <20100624030212.676457061@suse.de>
 <20100624030733.676440935@suse.de>
 <87aaqkagn9.fsf@basil.nowhere.org>
 <20100624160052.GL10441@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100624160052.GL10441@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <johnstul@us.ibm.com>, Frank Mayhar <fmayhar@google.com>
List-ID: <linux-mm.kvack.org>

> > Overall it seems good, but I have not read all the shrinker callback
> > changes in all subsystems.
> 
> Thanks for looking over it Andi.

FWIW i skimmed over most of the patches and nothing stood out that
I really disliked. But I have gone over the code in very deep detail.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
