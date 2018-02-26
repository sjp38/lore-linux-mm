Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 391706B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 03:12:16 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id a5so7324945plp.0
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 00:12:16 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c17sor1472939pgn.241.2018.02.26.00.12.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 00:12:15 -0800 (PST)
Date: Mon, 26 Feb 2018 17:12:10 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCHv3 1/2] zsmalloc: introduce zs_huge_object() function
Message-ID: <20180226081210.GF12539@jagdpanzerIV>
References: <20180210082321.17798-1-sergey.senozhatsky@gmail.com>
 <20180214055747.8420-1-sergey.senozhatsky@gmail.com>
 <20180220012429.GA186771@rodete-desktop-imager.corp.google.com>
 <20180226054927.GA12539@jagdpanzerIV>
 <20180226055804.GD112402@rodete-desktop-imager.corp.google.com>
 <20180226065035.GD12539@jagdpanzerIV>
 <20180226074652.GB168047@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180226074652.GB168047@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/26/18 16:46), Minchan Kim wrote:
[..]
> > hm, I think `huge_size' on it's own is a bit general and cryptic.
> > zs_huge_object_size() or zs_huge_class_size()?
> 
> I wanted to use more general word to hide zsmalloc internal but
> I realized it's really impossible to hide them all.
> If so, let's use zs_huge_class_size and then let's add big fat
> comment what the API represents in there.

Will do. Thanks!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
