Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BAB226B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:07:28 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 1-v6so1569506plv.6
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 08:07:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor713617pgo.331.2018.03.14.08.07.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 08:07:22 -0700 (PDT)
Date: Thu, 15 Mar 2018 00:07:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv3 0/2] zsmalloc/zram: drop zram's max_zpage_size
Message-ID: <20180314150713.GA144952@rodete-laptop-imager.corp.google.com>
References: <20180314081833.1096-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180314081833.1096-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Wed, Mar 14, 2018 at 05:18:31PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> 	ZRAM's max_zpage_size is a bad thing. It forces zsmalloc to
> store normal objects as huge ones, which results in bigger zsmalloc
> memory usage. Drop it and use actual zsmalloc huge-class value when
> decide if the object is huge or not.
> 
> v3:
> - add pool param to zs_huge_class_size() [Minchan]
> 
> Sergey Senozhatsky (2):
>   zsmalloc: introduce zs_huge_class_size() function
>   zram: drop max_zpage_size and use zs_huge_class_size()
 
Both looks good to me.

Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.
