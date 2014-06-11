Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 74E5A6B0126
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 20:45:48 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id a13so5813555igq.9
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 17:45:48 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id f17si70861175igt.12.2014.06.10.17.45.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 17:45:47 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so995822iec.23
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 17:45:47 -0700 (PDT)
Date: Tue, 10 Jun 2014 17:45:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: kernelcore not working correctly
In-Reply-To: <53966E16.6010104@ubuntu.com>
Message-ID: <alpine.DEB.2.02.1406101744400.32203@chino.kir.corp.google.com>
References: <53966E16.6010104@ubuntu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 9 Jun 2014, Phillip Susi wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA512
> 
> I booted with kernelcore=1g and it appears that ZONE_MOVABLE is only using
> 760mb out of 4g and DMA32 is continuing to use much more than the specified
> 1g:
> 

kernelcore=1G works fine for me on the latest Linus tree, it doesn't 
shrink ZONE_DMA or ZONE_DMA32 as expected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
