Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2998C6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 10:40:05 -0500 (EST)
Received: by pabli10 with SMTP id li10so24939192pab.13
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 07:40:04 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id d4si1637060pat.7.2015.03.03.07.40.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Mar 2015 07:40:04 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKN00LAC7P92C30@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Mar 2015 15:43:57 +0000 (GMT)
Message-id: <54F5D5CC.6070901@samsung.com>
Date: Tue, 03 Mar 2015 18:39:56 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC] slub memory quarantine
References: <54F57716.80809@samsung.com>
 <CACT4Y+YQ3cuUvRrT_19RbxFVWHGnzviSFi0-ud88jq9g9jUZog@mail.gmail.com>
In-reply-to: 
 <CACT4Y+YQ3cuUvRrT_19RbxFVWHGnzviSFi0-ud88jq9g9jUZog@mail.gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Dmitry Chernenkov <dmitryc@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 03/03/2015 12:10 PM, Dmitry Vyukov wrote:
> Please hold on with this.
> Dmitry Chernenkov is working on a quarantine that works with both slub
> and slab, does not cause spurious OOMs and does not depend on
> slub-debug which has unacceptable performance (acquires global lock).

I think that it's a separate issue. KASan already depend on slub_debug - it required for redzones/user tracking.
I think that some parts slub debugging (like user tracking and this quarantine)
could be moved (for CONFIG_KASAN=y) to the fast path without any locking.


> Me or Dmitry C will send an email to kasan-dev@googlegroups.com to
> discuss quarantine development direction.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
