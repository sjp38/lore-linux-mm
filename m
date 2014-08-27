Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB466B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 08:14:23 -0400 (EDT)
Received: by mail-oi0-f52.google.com with SMTP id g201so73203oib.11
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 05:14:23 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id h8si207235oej.50.2014.08.27.05.14.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 05:14:21 -0700 (PDT)
Message-ID: <53FDCB8F.40001@oracle.com>
Date: Wed, 27 Aug 2014 08:14:07 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/rmap.c:530
References: <53F487EB.7070703@oracle.com> <20140820140247.C729CE00A3@blue.fi.intel.com>
In-Reply-To: <20140820140247.C729CE00A3@blue.fi.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/20/2014 10:02 AM, Kirill A. Shutemov wrote:
> Sasha Levin wrote:
>> > Hi all,
>> > 
>> > While fuzzing with trinity inside a KVM tools guest running the latest -next
>> > kernel, I've stumbled on the following spew:
>> > 
>> > [ 2581.180086] kernel BUG at mm/rmap.c:530!
> Page is mapped where it shouldn't be. Or vma/struct page/pgtable is corrupted.
> Basically, I have no idea what happend :-P
> 
> We really should dump page and vma info there. It's strange we don't have
> dump_vma() helper yet.
> 

It just happened again, I'll work on that dump_vma helper... :/


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
