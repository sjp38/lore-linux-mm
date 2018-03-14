Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 31A5E6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 07:22:15 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y10so1303566pge.2
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 04:22:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s6-v6si478363plp.79.2018.03.14.04.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Mar 2018 04:22:13 -0700 (PDT)
Date: Wed, 14 Mar 2018 04:22:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: BUG: unable to handle kernel paing request at fffffc0000000000
Message-ID: <20180314112212.GB29631@bombadil.infradead.org>
References: <270af3b0-ab0f-9ee5-d5d6-3e86983b8d9b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <270af3b0-ab0f-9ee5-d5d6-3e86983b8d9b@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chenjiankang <chenjiankang1@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yisheng Xie <xieyisheng1@huawei.com>, wangkefeng.wang@huawei.com

On Wed, Mar 14, 2018 at 04:14:01PM +0800, chenjiankang wrote:
> 
> 
> hello everyone:
> 	my kernel version is 3.10.0-327.62.59.101.x86_64, and 

That kernel version appears to be an internal Huawei kernel.  It's
probably impossible for anyone outside Huawei to debug it.
