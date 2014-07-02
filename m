Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6126B0038
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 14:40:57 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so12412395pdj.28
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 11:40:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ck17si289518pdb.421.2014.07.02.11.40.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 11:40:51 -0700 (PDT)
Date: Wed, 2 Jul 2014 11:40:50 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: IMA: kernel reading files opened with O_DIRECT
Message-ID: <20140702184050.GA24583@infradead.org>
References: <53B3D3AA.3000408@samsung.com>
 <x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dmitry Kasatkin <d.kasatkin@samsung.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, viro@ZenIV.linux.org.uk, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-security-module <linux-security-module@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>

On Wed, Jul 02, 2014 at 11:55:41AM -0400, Jeff Moyer wrote:
> It's acceptable.

It's not because it will then also affect other reads going on at the
same time.

The whole concept of ima is just broken, and if you want to do these
sort of verification they need to happen inside the filesystem and not
above it.

We really should never have merged ima, and I think we should leave
these sorts of issue that have been there since day one unfixed and
deprecate it instead of adding workaround on top of workaround.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
