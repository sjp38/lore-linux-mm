Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFCBB6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 00:37:02 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id fs8so96582999obb.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 21:37:02 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 103si15545162iom.30.2016.05.25.21.37.01
        for <linux-mm@kvack.org>;
        Wed, 25 May 2016 21:37:02 -0700 (PDT)
Date: Thu, 26 May 2016 13:37:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 11/12] zsmalloc: page migration support
Message-ID: <20160526043716.GE9661@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-12-git-send-email-minchan@kernel.org>
 <20160524052824.GA496@swordfish>
 <20160524062801.GB29094@bbox>
 <20160525051438.GA14786@bbox>
 <20160525152345.GA515@swordfish>
 <20160526003241.GA9661@bbox>
 <20160526005926.GA532@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160526005926.GA532@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 26, 2016 at 09:59:26AM +0900, Sergey Senozhatsky wrote:
<snip>
> btw, I've uploaded zram-fio test script to
>  https://github.com/sergey-senozhatsky/zram-perf-test
> 
> it's very minimalistic and half baked, but can be used
> to some degree. open to patches, improvements, etc.

Awesome!
Let's enhance it as zram benchmark tool.
Maybe I will help something. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
