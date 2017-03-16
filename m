Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 038A76B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:59:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x63so75655811pfx.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:59:08 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id f3si4626429pgc.326.2017.03.16.01.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 01:59:08 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id m5so5333995pgk.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:59:08 -0700 (PDT)
Date: Thu, 16 Mar 2017 17:59:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 10/15] mm: page_alloc: 80 column neatening
Message-ID: <20170316085904.GE464@jagdpanzerIV.localdomain>
References: <cover.1489628477.git.joe@perches.com>
 <82f1665ccf57a7da21dcf878478e01c4765d0e66.1489628477.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <82f1665ccf57a7da21dcf878478e01c4765d0e66.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (03/15/17 19:00), Joe Perches wrote:
> Wrap some lines to make it easier to read.

hm, I thought that the general rule was "don't fix styles in the
code that left /staging". because it adds noise, messes with git
annotate, etc.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
