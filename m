Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id B1F586B004A
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 10:06:57 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/7] mm: vma->vm_flags diet
References: <20120331091049.19373.28994.stgit@zurg>
Date: Sat, 31 Mar 2012 07:06:30 -0700
In-Reply-To: <20120331091049.19373.28994.stgit@zurg> (Konstantin Khlebnikov's
	message of "Sat, 31 Mar 2012 13:25:36 +0400")
Message-ID: <m2ty14yie1.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

Konstantin Khlebnikov <khlebnikov@openvz.org> writes:

> This patch-set moves/kills some VM_* flags in vma->vm_flags bit-field,
> as result there appears four free bits.
>
> Also I'm working on VM_RESERVED reorganization, probably it also can be killed.
> It lost original swapout-protection sense in 2.6 and now is used for other purposes.

Great, I ran into this problem recently too: I wanted to add a new bit,
but there was none.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
