Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 639166B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 18:53:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c23so106537180pfj.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 15:53:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f16si6607952pli.169.2017.03.16.15.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 15:53:48 -0700 (PDT)
Date: Thu, 16 Mar 2017 15:53:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: page_alloc: Reduce object size by neatening
 printks
Message-Id: <20170316155347.966f5597082692df04494c4d@linux-foundation.org>
In-Reply-To: <1489689476.13953.3.camel@perches.com>
References: <cover.1489628459.git.joe@perches.com>
	<880b3172b67d806082284d80945e4a231a5574bb.1489628459.git.joe@perches.com>
	<20170316113056.GG464@jagdpanzerIV.localdomain>
	<1489689476.13953.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 16 Mar 2017 11:37:56 -0700 Joe Perches <joe@perches.com> wrote:

> > this can make it harder to read, in _the worst case_. one printk()
> > guaranteed that we would see a single line in the serial log/etc.
> > the sort of a problem with multiple printks is that printks coming
> > from other CPUs will split that "previously single" line.
> 
> Not true.  Note the multiple \n uses in the original code.

hm?  Won't printk("a\na") atomically emit all three chars into the log
buffer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
