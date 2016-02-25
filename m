Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9EABD6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 00:36:23 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id fl4so25975430pad.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 21:36:23 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id bm5si9984685pad.107.2016.02.24.21.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 21:36:22 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id x65so26495592pfb.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 21:36:22 -0800 (PST)
Date: Wed, 24 Feb 2016 21:36:13 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Problems with swapping in v4.5-rc on POWER
In-Reply-To: <1456373550.30375.3.camel@ellerman.id.au>
Message-ID: <alpine.LSU.2.11.1602242131480.6876@eggly.anvils>
References: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils> <1456373550.30375.3.camel@ellerman.id.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Hugh Dickins <hughd@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Thu, 25 Feb 2016, Michael Ellerman wrote:
> 
> I do run tests on G5, but obviously not rigorously enough. I kicked off a few
> kernel builds on mine and it survived, though once it hits swap it's almost
> unusably slow. I'll leave it running overnight and see if I hit anything.

Oh yes, I'd forgotten how unusably slow: I tend to forget that I slipped an
SSD in there some while back, just for the swapping: slow, but not unusable.

Thanks, I'm hoping you will be able to reproduce it yourself.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
