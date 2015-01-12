Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 025006B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:09:25 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id 79so10571183ykr.7
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:09:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o1si9829385yhp.172.2015.01.12.15.09.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 15:09:23 -0800 (PST)
Date: Mon, 12 Jan 2015 15:09:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 00/20] DAX: Page cache bypass for filesystems on
 memory storage
Message-Id: <20150112150921.d9e8e46f9bb5d76d8cfb3fbc@linux-foundation.org>
In-Reply-To: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Fri, 24 Oct 2014 17:20:32 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> DAX is a replacement for the variation of XIP currently supported by
> the ext2 filesystem.

Looks pretty nice to me, thanks.  I had a bunch of relatively minor
review questions - mainly stuff which would benefit from some short
comments.

I had to do some mangling due to the intervening
i_mmap_mutex->i_mmap_lock_read/write.  I ended up choosing
i_mmap_lock_read() throughout, which needs careful checking please.  I
also converted the changelogs.  It still compiles!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
