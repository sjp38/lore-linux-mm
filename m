Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5FBE56B00F5
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 04:01:48 -0500 (EST)
Message-ID: <49B0E67C.2090404@cn.fujitsu.com>
Date: Fri, 06 Mar 2009 17:01:48 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
References: <49B0CAEC.80801@cn.fujitsu.com>	<20090306082056.GB3450@x200.localdomain>	<49B0DE89.9000401@cn.fujitsu.com> <20090306003900.a031a914.akpm@linux-foundation.org>
In-Reply-To: <20090306003900.a031a914.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 06 Mar 2009 16:27:53 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>>> Let's not add wrapper for every two lines that happen to be used
>>> together.
>>>
>> Why not if we have good reasons? And I don't think we can call this
>> "happen to" if there are 250+ of them?
> 
> The change is a good one.  If a reviewer (me) sees it then you know the
> code's all right and the review effort becomes less - all you need to check
> is that the call site is using IS_ERR/PTR_ERR and isn't testing for
> NULL.  Less code, less chance for bugs.
> 
> Plus it makes kernel text smaller.
> 
> Yes, the name is a bit cumbersome.
> 

How about memdup_user()? like kstrndup() vs strndup_user().

Here is the statistics when using 5 kmemdup_from_user() in btrfs:

$ diffstat
 ioctl.c |   49 ++++++++++++-------------------------------------
 super.c |   13 ++++---------
 2 files changed, 16 insertions(+), 46 deletions(-)

the kernel size on i386:

   text    data     bss     dec     hex filename
 288339    1924     508  290771   46fd3 fs/btrfs/btrfs.o.orig
   text    data     bss     dec     hex filename
 288255    1924     508  290687   46f7f fs/btrfs/btrfs.o

so saves 84 bytes.

the kernel size on IA64:

   text    data     bss     dec     hex filename
 898752    3736     109  902597   dc5c5 fs/btrfs/btrfs.o.orig
   text    data     bss     dec     hex filename
 898176    3712     109  901997   dc36d fs/btrfs/btrfs.o

so saves 576 bytes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
