Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B44906B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 05:24:29 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j124so12700554ith.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 02:24:29 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n137si342388ion.219.2016.07.26.02.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 02:24:28 -0700 (PDT)
Subject: Re: [PATCH] mm: correctly handle errors during VMA merging
References: <1469514843-23778-1-git-send-email-vegard.nossum@oracle.com>
 <20160726085344.GA7370@node.shutemov.name>
From: Vegard Nossum <vegard.nossum@oracle.com>
Message-ID: <57972C45.5050803@oracle.com>
Date: Tue, 26 Jul 2016 11:24:21 +0200
MIME-Version: 1.0
In-Reply-To: <20160726085344.GA7370@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Leon Yu <chianglungyu@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>

On 07/26/2016 10:53 AM, Kirill A. Shutemov wrote:
> On Tue, Jul 26, 2016 at 08:34:03AM +0200, Vegard Nossum wrote:
>> Using trinity + fault injection I've been running into this bug a lot:
>>
>>      ==================================================================
>>      BUG: KASAN: out-of-bounds in mprotect_fixup+0x523/0x5a0 at addr ffff8800b9e7d740
>>      Read of size 8 by task trinity-c3/6338
[...]
>> I can give the reproducer a spin.
>
> Could you post your reproducer? I guess it requires kernel instrumentation
> to make allocation failure more likely.

I'm sorry but company policy prevents me from posting straight-up
reproducers. But as I said I'm happy to rerun it if you have an
alternative patch.

It should be enough to enable fault injection (echo 1 >
/proc/self/make-it-fail) for the process doing the mprotect().


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
