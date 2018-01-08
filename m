Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1AEC36B027E
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 00:22:29 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id w196so5344473oia.17
        for <linux-mm@kvack.org>; Sun, 07 Jan 2018 21:22:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p67si2880384oia.165.2018.01.07.21.22.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jan 2018 21:22:27 -0800 (PST)
Date: Sun, 7 Jan 2018 23:22:25 -0600
From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: kernel BUG at ./include/linux/mm.h:LINE! (3)
Message-ID: <20180107232225.3b6a37ca@lembas.zaitcev.lan>
In-Reply-To: <20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
References: <20171228160346.6406d52df0d9afe8cf7a0862@linux-foundation.org>
	<20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-usb@vger.kernel.org, zaitcev@redhat.com

On Fri, 29 Dec 2017 16:24:20 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Looks like MON_IOCT_RING_SIZE reallocates ring buffer without any
> serialization wrt mon_bin_vma_fault(). By the time of get_page() the page
> may be freed.

As an update: I tried to make a smaller test for this, but was unsuccessful
so far. I'll poke a bit at it later, but it may take me some time.

-- Pete

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
