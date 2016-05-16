Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF1D6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 09:04:01 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ga2so59222056lbc.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 06:04:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2si20009704wma.79.2016.05.16.06.03.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 06:03:59 -0700 (PDT)
Subject: Re: UBIFS and page migration (take 3)
References: <1462974823-3168-1-git-send-email-richard@nod.at>
 <20160512114948.GA25113@infradead.org> <5739C0C1.1090907@nod.at>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5739C53B.1010700@suse.cz>
Date: Mon, 16 May 2016 15:03:55 +0200
MIME-Version: 1.0
In-Reply-To: <5739C0C1.1090907@nod.at>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>, Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hughd@google.com, mgorman@techsingularity.net

On 05/16/2016 02:44 PM, Richard Weinberger wrote:
> MM folks, do we have a way to force page migration?

On NUMA we have migrate_pages(2).

> Maybe we can create a generic stress test.
>
> Thanks,
> //richard
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
