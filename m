Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 69C5C6B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 04:32:33 -0400 (EDT)
Date: Thu, 9 Aug 2012 09:31:28 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 3/5] kmemleak: use rbtree instead of prio tree
Message-ID: <20120809083127.GC14102@arm.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
 <1344324343-3817-4-git-send-email-walken@google.com>
 <CANN689EOZ64V_AO8B6N0-_B0_HdQZVk3dH8Ce5c=m5Q=ySDKUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689EOZ64V_AO8B6N0-_B0_HdQZVk3dH8Ce5c=m5Q=ySDKUg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: "riel@redhat.com" <riel@redhat.com>, "peterz@infradead.org" <peterz@infradead.org>, "vrajesh@umich.edu" <vrajesh@umich.edu>, "daniel.santos@pobox.com" <daniel.santos@pobox.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On Wed, Aug 08, 2012 at 06:07:39PM +0100, Michel Lespinasse wrote:
> kmemleak uses a tree where each node represents an allocated memory object
> in order to quickly find out what object a given address is part of.
> However, the objects don't overlap, so rbtrees are a better choice than
> prio tree for this use. They are both faster and have lower memory overhead.
> 
> Tested by booting a kernel with kmemleak enabled, loading the kmemleak_test
> module, and looking for the expected messages.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

The patch looks fine to me but I'll give it a test later today and let
you know.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
