Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0A436B025E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 05:04:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so24904430wmw.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 02:04:01 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id c5si9077510wjm.164.2016.05.18.02.04.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 02:04:00 -0700 (PDT)
Subject: Re: UBIFS and page migration (take 3)
References: <1462974823-3168-1-git-send-email-richard@nod.at>
 <20160512114948.GA25113@infradead.org> <5739C0C1.1090907@nod.at>
 <5739C53B.1010700@suse.cz> <573B0009.3070004@nod.at>
From: Richard Weinberger <richard@nod.at>
Message-ID: <573C2FEF.6050500@nod.at>
Date: Wed, 18 May 2016 11:03:43 +0200
MIME-Version: 1.0
In-Reply-To: <573B0009.3070004@nod.at>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hughd@google.com, mgorman@techsingularity.net

Am 17.05.2016 um 13:27 schrieb Richard Weinberger:
> Vlastimil,
> 
> Am 16.05.2016 um 15:03 schrieb Vlastimil Babka:
>> On 05/16/2016 02:44 PM, Richard Weinberger wrote:
>>> MM folks, do we have a way to force page migration?
>>
>> On NUMA we have migrate_pages(2).
> 
> Doesn't this only migrate process (user) pages?
> AFAIK we need a way to force migration of pages which
> are in the page cache.

While migrate_pages(2) does not seem to hit the ->migratepage()
function, echo 1 > /proc/sys/vm/compact_memory does.
Thanks Vlastimil for pointing me in the right direction!

Just reproduce the issue on UBIFS in a KVM guest and a
simulated NAND. :-)
Let's see whether I can come up with a generic test.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
