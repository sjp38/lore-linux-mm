Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB03D6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 04:51:26 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so33580571lfg.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 01:51:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a1si7977554wmi.12.2016.04.27.01.51.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 01:51:25 -0700 (PDT)
Subject: Re: [BUG linux-next] Kernel panic found with linux-next-20160414
References: <5716C29F.1090205@linaro.org>
 <alpine.LSU.2.11.1604200041460.3009@eggly.anvils>
 <5717AA46.5020905@linaro.org>
 <alpine.LSU.2.11.1604270029350.7066@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57207D88.4000508@suse.cz>
Date: Wed, 27 Apr 2016 10:51:20 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1604270029350.7066@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, "Shi, Yang" <yang.shi@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, sfr@canb.auug.org.au, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 04/27/2016 10:14 AM, Hugh Dickins wrote:
> It's rather horrible that compaction.c uses functions in page_alloc.c
> which skip doing some of the things we expect to be done: the non-debug
> preparation tends to get noticed, but the debug options overlooked.
> We can expect more problems of this kind in future: someone will add
> yet another debug prep line in page_alloc.c, and at first nobody will
> notice that it's also needed in compaction.c.

Point taken, I'll try to come up with more maintainable solution next 
time I attempt the isolate_freepages_direct() approach. Sorry about the 
troubles.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
