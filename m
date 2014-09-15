Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id DDD056B0037
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 12:24:50 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq14so6660431pab.11
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 09:24:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id gz10si23990685pbd.137.2014.09.15.09.24.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 09:24:48 -0700 (PDT)
Message-ID: <541712C9.5020509@infradead.org>
Date: Mon, 15 Sep 2014 09:24:41 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH v2 01/10] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-2-git-send-email-a.ryabinin@samsung.com> <5414F0F3.4000001@infradead.org> <5417058E.1010206@samsung.com>
In-Reply-To: <5417058E.1010206@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On 09/15/14 08:28, Andrey Ryabinin wrote:
> On 09/14/2014 05:35 AM, Randy Dunlap wrote:
>> Following sentence is confusing.  I'm not sure how to fix it.
>>
> 
> 
> Perhaps rephrase is like this:
> 
> Do not use slub poisoning with KASan if user tracking enabled (iow slub_debug=PU).

                                       if user tracking is enabled

> User tracking info (allocation/free stacktraces) are stored inside slub object's metadata.
> Slub poisoning overwrites slub object and it's metadata with poison value on freeing.

                                            its

> So if KASan will detect use after free, allocation/free stacktraces will be overwritten

  So if KASan detects a use after free, allocation/free stacktraces are overwritten

> and KASan won't be able to print them.


Thanks.

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
