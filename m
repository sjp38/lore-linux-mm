Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id D44E66B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 02:20:44 -0400 (EDT)
Message-ID: <1338445233.19369.21.camel@cr0>
Subject: Re: [RFC Patch] fs: implement per-file drop caches
From: Cong Wang <amwang@redhat.com>
Date: Thu, 31 May 2012 14:20:33 +0800
In-Reply-To: <4FC6393B.7090105@draigBrady.com>
References: <1338385120-14519-1-git-send-email-amwang@redhat.com>
	 <4FC6393B.7090105@draigBrady.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2012-05-30 at 16:14 +0100, PA!draig Brady wrote:
> On 05/30/2012 02:38 PM, Cong Wang wrote:
> > This is a draft patch of implementing per-file drop caches.
> > 
> > It introduces a new fcntl command  F_DROP_CACHES to drop
> > file caches of a specific file. The reason is that currently
> > we only have a system-wide drop caches interface, it could
> > cause system-wide performance down if we drop all page caches
> > when we actually want to drop the caches of some huge file.
> 
> This is useful functionality.
> Though isn't it already provided with POSIX_FADV_DONTNEED?

Thanks for teaching this!

However, from the source code of madvise_dontneed() it looks like it is
using a totally different way to drop page caches, that is to invalidate
the page mapping, and trigger a re-mapping of the file pages after a
page fault. So, yeah, this could probably drop the page caches too (I am
not so sure, haven't checked the code in details), but with my patch, it
flushes the page caches directly, what's more, it can also prune
dcache/icache of the file.

Cheers.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
