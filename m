Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0856B0253
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 17:15:36 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v109so467399wrc.5
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 14:15:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 31si13655382wrf.176.2017.09.14.14.15.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 14:15:34 -0700 (PDT)
Date: Thu, 14 Sep 2017 14:15:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] z3fold: fix stale list handling
Message-Id: <20170914141532.9339436e0fb0fd85b99b8dbf@linux-foundation.org>
In-Reply-To: <20170914155936.697bf347a00dacee7e7f3778@gmail.com>
References: <20170914155936.697bf347a00dacee7e7f3778@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Oleksiy.Avramchenko@sony.com

On Thu, 14 Sep 2017 15:59:36 +0200 Vitaly Wool <vitalywool@gmail.com> wrote:

> Fix the situation when clear_bit() is called for page->private before
> the page pointer is actually assigned. While at it, remove work_busy()
> check because it is costly and does not give 100% guarantee anyway.

Does this fix https://bugzilla.kernel.org/show_bug.cgi?id=196877 ?  If
so, the bugzilla references and a reported-by should be added.

What are the end-user visible effects of the bug?  Please always
include this info when fixing bugs.

Should this fix be backported into -stable kernels?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
