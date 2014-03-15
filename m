Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 441836B004D
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 08:31:24 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so3672282pdi.30
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 05:31:23 -0700 (PDT)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id p2si8666508pbn.183.2014.03.15.05.31.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Mar 2014 05:31:23 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so3787466pbb.3
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 05:31:22 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20140315092455.GA6018@infradead.org>
References: <1394812471-9693-1-git-send-email-psusi@ubuntu.com>
 <532417CA.1040300@gmail.com> <20140315092455.GA6018@infradead.org>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Sat, 15 Mar 2014 13:31:02 +0100
Message-ID: <CAKgNAkgGZ-3U8PLKrZZ5KUWMmopd1B777_6ekva5ZpeXecEZ1g@mail.gmail.com>
Subject: Re: [PATCH] readahead.2: don't claim the call blocks until all data
 has been read
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Phillip Susi <psusi@ubuntu.com>, linux-man <linux-man@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-ext4@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>, "Gregory P. Smith" <gps@google.com>, Zhu Yanhai <zhu.yanhai@gmail.com>

On Sat, Mar 15, 2014 at 10:24 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Sat, Mar 15, 2014 at 10:05:14AM +0100, Michael Kerrisk (man-pages) wrote:
>>        However, it may block while  it  reads
>>        the  filesystem metadata needed to locate the requested blocks.
>>        This occurs frequently with ext[234] on large files using indi???
>>        rect  blocks instead of extents, giving the appearence that the
>>        call blocks until the requested data has been read.
>>
>> Okay?
>
> The part above is something that should be in the BUGS section.

Good call. Done. Thanks, Christoph.

Cheers,

Michael




-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
