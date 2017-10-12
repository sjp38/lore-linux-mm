Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF6F16B0038
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 12:32:19 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id a125so4145252ita.8
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 09:32:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b8sor365063itc.58.2017.10.12.09.32.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 09:32:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171012135127.GG29293@quack2.suse.cz>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150776923320.9144.6119113178052262946.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171012135127.GG29293@quack2.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 12 Oct 2017 09:32:17 -0700
Message-ID: <CA+55aFyy-nz99c6erFh=aeyCOzsk0td5wHaVLpwBNA-sWNDZkA@mail.gmail.com>
Subject: Re: [PATCH v9 1/6] mm: introduce MAP_SHARED_VALIDATE, a mechanism to
 safely define new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Arnd Bergmann <arnd@arndb.de>, Linux API <linux-api@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Thu, Oct 12, 2017 at 6:51 AM, Jan Kara <jack@suse.cz> wrote:
>
> When thinking a bit more about this I've realized one problem: Currently
> user can call mmap() with MAP_SHARED type and MAP_SYNC or MAP_DIRECT flags
> and he will get the new semantics (if the kernel happens to support it).  I
> think that is undesirable [..]

Why?

If you have a performance preference for MAP_DIRECT or something like
that, but you don't want to *enforce* it, you'd use just plain
MAP_SHARED with it.

Ie there may well be "I want this to work, possibly with downsides" issues.

So it seems to be a reasonable model, and disallowing it seems to
limit people and not really help anything.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
