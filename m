Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id CD3EC6B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 17:35:45 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so77935pab.14
        for <linux-mm@kvack.org>; Tue, 06 May 2014 14:35:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tm7si1171597pab.111.2014.05.06.14.35.44
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 14:35:44 -0700 (PDT)
Date: Tue, 6 May 2014 14:35:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC, PATCH 0/8] remap_file_pages() decommission
Message-Id: <20140506143542.1d4e5f41be58b3ad3543ffe3@linux-foundation.org>
In-Reply-To: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue,  6 May 2014 17:37:24 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> This patchset replaces the syscall with emulation which creates new VMA on
> each remap and remove code to support non-linear mappings.
> 
> Nonlinear mappings are pain to support and it seems there's no legitimate
> use-cases nowadays since 64-bit systems are widely available.
> 
> It's not yet ready to apply. Just to give rough idea of what can we get if
> we'll deprecated remap_file_pages().
> 
> I need to split patches properly and write correct commit messages. And there's
> still code to remove.

hah.  That's bold.  It would be great if we can get away with this.

Do we have any feeling for who will be impacted by this and how badly?

I wonder if we can give people a bit more warning - put a printk() in
there immediately, backport it into -stable, wait N months then make
the change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
