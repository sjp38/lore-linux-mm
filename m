Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E978C6B0003
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 13:04:29 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y131-v6so1217411wmd.5
        for <linux-mm@kvack.org>; Sun, 30 Sep 2018 10:04:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z131-v6sor207843wmb.18.2018.09.30.10.04.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Sep 2018 10:04:28 -0700 (PDT)
Date: Sun, 30 Sep 2018 20:04:23 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: Patch "slub: make ->cpu_partial unsigned int" has been added to
 the 3.18-stable tree
Message-ID: <20180930170423.GA3413@avx2>
References: <153831153117858@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <153831153117858@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: stable@vger.kernel.org, linux-mm@kvack.org

On Sun, Sep 30, 2018 at 05:45:31AM -0700, gregkh@linuxfoundation.org wrote:
> 
> This is a note to let you know that I've just added the patch titled
> 
>     slub: make ->cpu_partial unsigned int

> From e5d9998f3e09359b372a037a6ac55ba235d95d57 Mon Sep 17 00:00:00 2001
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Thu, 5 Apr 2018 16:21:10 -0700
> Subject: slub: make ->cpu_partial unsigned int

This doesn't fix any bug that I know of, should not be in -stable.
