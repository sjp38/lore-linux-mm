Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id F3E1C6B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 14:46:20 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id b13so1222245wgh.14
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 11:46:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id dw1si16101566wib.88.2014.07.02.11.46.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 11:46:19 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: IMA: kernel reading files opened with O_DIRECT
References: <53B3D3AA.3000408@samsung.com>
	<x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
	<20140702184050.GA24583@infradead.org>
Date: Wed, 02 Jul 2014 14:45:50 -0400
In-Reply-To: <20140702184050.GA24583@infradead.org> (Christoph Hellwig's
	message of "Wed, 2 Jul 2014 11:40:50 -0700")
Message-ID: <x49tx6ztx9d.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dmitry Kasatkin <d.kasatkin@samsung.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, viro@ZenIV.linux.org.uk, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-security-module <linux-security-module@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>

Christoph Hellwig <hch@infradead.org> writes:

> On Wed, Jul 02, 2014 at 11:55:41AM -0400, Jeff Moyer wrote:
>> It's acceptable.
>
> It's not because it will then also affect other reads going on at the
> same time.

OK, that part I was fuzzy on.  I wasn't sure if they were preventing
other reads/writes to the same file somehow.  I should have mentioned
that.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
