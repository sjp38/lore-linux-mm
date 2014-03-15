Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id BB54F6B003A
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 05:25:01 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id w8so3473666qac.41
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 02:25:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.9])
        by mx.google.com with ESMTPS id y69si4941867qgd.62.2014.03.15.02.25.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Mar 2014 02:25:01 -0700 (PDT)
Date: Sat, 15 Mar 2014 02:24:55 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] readahead.2: don't claim the call blocks until all data
 has been read
Message-ID: <20140315092455.GA6018@infradead.org>
References: <1394812471-9693-1-git-send-email-psusi@ubuntu.com>
 <532417CA.1040300@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532417CA.1040300@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Phillip Susi <psusi@ubuntu.com>, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>, "Gregory P. Smith" <gps@google.com>, Zhu Yanhai <zhu.yanhai@gmail.com>

On Sat, Mar 15, 2014 at 10:05:14AM +0100, Michael Kerrisk (man-pages) wrote:
>        However, it may block while  it  reads
>        the  filesystem metadata needed to locate the requested blocks.
>        This occurs frequently with ext[234] on large files using indi???
>        rect  blocks instead of extents, giving the appearence that the
>        call blocks until the requested data has been read.
> 
> Okay?

The part above is something that should be in the BUGS section.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
