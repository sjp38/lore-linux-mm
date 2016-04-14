Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4386B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 04:48:55 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l15so41143662lfg.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 01:48:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id is6si44145784wjb.96.2016.04.14.01.48.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 01:48:53 -0700 (PDT)
Subject: Re: [PATCH] z3fold: the 3-fold allocator for compressed pages
References: <570F4F5F.6070209@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570F5973.40809@suse.cz>
Date: Thu, 14 Apr 2016 10:48:51 +0200
MIME-Version: 1.0
In-Reply-To: <570F4F5F.6070209@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Seth Jennings <sjenning@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

On 04/14/2016 10:05 AM, Vitaly Wool wrote:
> This patch introduces z3fold, a special purpose allocator for storing
> compressed pages. It is designed to store up to three compressed pages per
> physical page. It is a ZBUD derivative which allows for higher compression
> ratio keeping the simplicity and determinism of its predecessor.

So the obvious question is, why a separate allocator and not extend zbud?
I didn't study the code, nor notice a design/algorithm overview doc, but it 
seems z3fold keeps the idea of one compressed page at the beginning, one at the 
end of page frame, but it adds another one in the middle? Also how is the 
buddy-matching done?

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
