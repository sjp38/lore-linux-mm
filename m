Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C1E975F0001
	for <linux-mm@kvack.org>; Thu,  9 Apr 2009 03:54:54 -0400 (EDT)
Date: Thu, 9 Apr 2009 09:58:05 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] POISON: The high level memory error handler in the VM II
Message-ID: <20090409075805.GG14687@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407151010.E72A91D0471@basil.firstfloor.org> <1239210239.28688.15.camel@think.oraclecorp.com> <20090409072949.GF14687@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090409072949.GF14687@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Chris Mason <chris.mason@oracle.com>, hugh@veritas.com, npiggin@suse.de, riel@redhat.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Double checked the try_to_release_page logic. My assumption was that the 
writeback case could never trigger, because during write back the page
should be locked and so it's excluded with the earlier lock_page_nosync().

Is that a correct assumption?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
