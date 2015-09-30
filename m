Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2DF6B0256
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 04:02:02 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so33195769pac.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:02:01 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id ui8si3999114pab.115.2015.09.30.01.02.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 01:02:01 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so33778311pac.2
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:02:01 -0700 (PDT)
Date: Wed, 30 Sep 2015 17:03:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv2 0/3] align zpool/zbud/zsmalloc on the api
Message-ID: <20150930080359.GD12727@bbox>
References: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: ddstreet@ieee.org, akpm@linux-foundation.org, Seth Jennings <sjennings@variantweb.net>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hello,

On Sat, Sep 26, 2015 at 10:04:01AM +0200, Vitaly Wool wrote:
> Here comes the second iteration over zpool/zbud/zsmalloc API alignment. 
> This time I divide it into three patches: for zpool, for zbud and for zsmalloc :)
> Patches are non-intrusive and do not change any existing functionality. They only
> add up stuff for the alignment purposes.

It exposes new API which needs justification in description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
