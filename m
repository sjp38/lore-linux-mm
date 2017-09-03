Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B21C6B02B4
	for <linux-mm@kvack.org>; Sun,  3 Sep 2017 10:09:11 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x29so8646869qtc.6
        for <linux-mm@kvack.org>; Sun, 03 Sep 2017 07:09:11 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o2sor7845358qkc.5.2017.09.03.07.09.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Sep 2017 07:09:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170903074306.GA8351@infradead.org>
References: <CABXGCsOL+_OgC0dpO1+Zeg=iu7ryZRZT4S7k-io8EGB0ZRgZGw@mail.gmail.com>
 <20170903074306.GA8351@infradead.org>
From: =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Date: Sun, 3 Sep 2017 19:08:54 +0500
Message-ID: <CABXGCsMmEvEh__R2L47jqVnxv9XDaT_KP67jzsUeDLhF2OuOyA@mail.gmail.com>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org

On 3 September 2017 at 12:43, Christoph Hellwig <hch@infradead.org> wrote:
>
> This is:
>
>         bh = head = page_buffers(page);
>
> Which looks odd and like some sort of VM/writeback change might
> have triggered that we get a page without buffers, despite always
> creating buffers in iomap_begin/end and page_mkwrite.
>
> Ccing linux-mm if anything odd happen in that area recently.
>
> Can you tell anything about the workload you are running?
>

On XFS partition stored launched KVM VM images, + home partition with
Google Chrome profiles.
Seems the bug triggering by high memory consumption and using swap
which two times larger than system memory.
I saw that it happens when swap has reached size of system memory.

--
Best Regards,
Mike Gavrilov.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
