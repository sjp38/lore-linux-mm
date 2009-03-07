Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A2B7C6B006A
	for <linux-mm@kvack.org>; Sat,  7 Mar 2009 11:54:16 -0500 (EST)
From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH -v2] memdup_user(): introduce
References: <49B0CAEC.80801@cn.fujitsu.com>
	<20090306082056.GB3450@x200.localdomain>
	<49B0DE89.9000401@cn.fujitsu.com>
	<20090306003900.a031a914.akpm@linux-foundation.org>
	<49B0E67C.2090404@cn.fujitsu.com>
	<20090306011548.ffdf9cbc.akpm@linux-foundation.org>
	<49B0F1B9.1080903@cn.fujitsu.com>
	<20090306150335.c512c1b6.akpm@linux-foundation.org>
	<20090307084805.7cf3d574@infradead.org>
Date: Sat, 07 Mar 2009 08:54:14 -0800
In-Reply-To: <20090307084805.7cf3d574@infradead.org> (Arjan van de Ven's
	message of "Sat, 7 Mar 2009 08:48:05 -0800")
Message-ID: <adaeix9ff49.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, adobriyan@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 > I would like to question the use of the gfp argument here;
 > copy_from_user sleeps, so you can't use GFP_ATOMIC anyway.
 > You can't use GFP_NOFS etc, because the pagefault path will happily do
 > things that are equivalent, if not identical, to GFP_KERNEL.

That's a convincing argument, and furthermore, strndup_user() does not
take a gfp parameter, so interface consistency also argues that the
function prototype should just be

void *memdup_user(const void __user *src, size_t len);

(By the way, the len parameter of strndup_user() is declared as long,
which seems strange, since it matches neither the userspace strndup()
nor the kernel kstrndup(), which both use size_t.  So using size_t for
memdup_user() and possibly fixing strndup_user() to use size_t as well
seems like the sanest thing)

 - R.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
