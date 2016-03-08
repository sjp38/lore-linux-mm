Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 592E76B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 14:34:34 -0500 (EST)
Received: by mail-qk0-f175.google.com with SMTP id s68so10518575qkh.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 11:34:34 -0800 (PST)
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com. [209.85.192.50])
        by mx.google.com with ESMTPS id 68si4472547qkv.24.2016.03.08.11.34.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 11:34:33 -0800 (PST)
Received: by mail-qg0-f50.google.com with SMTP id u110so21626622qge.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 11:34:33 -0800 (PST)
Subject: Re: mmotm broken on arm with ebc495cfcea9 (mm: cleanup *pte_alloc*
 interfaces)
References: <56DE2A92.5010806@redhat.com>
 <20160307180205.1df26ec3.akpm@linux-foundation.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56DF2945.9070600@redhat.com>
Date: Tue, 8 Mar 2016 11:34:29 -0800
MIME-Version: 1.0
In-Reply-To: <20160307180205.1df26ec3.akpm@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/07/2016 06:02 PM, Andrew Morton wrote:
> On Mon, 7 Mar 2016 17:27:46 -0800 Laura Abbott <labbott@redhat.com> wrote:
>
>> Hi,
>>
>> I just tried the master of mmotm and ran into compilation issues on arm:
>>
>> ...
>>
>> It looks like this is caused by ebc495cfcea9 (mm: cleanup *pte_alloc* interfaces)
>> which added
>>
>> #define pte_alloc(mm, pmd, address)                     \
>>           (unlikely(pmd_none(*(pmd))) && __pte_alloc(mm, pmd, address))
>>
>>
>
> http://ozlabs.org/~akpm/mmots/broken-out/mm-cleanup-pte_alloc-interfaces-fix.patch
> and
> http://ozlabs.org/~akpm/mmots/broken-out/mm-cleanup-pte_alloc-interfaces-fix-2.patch
> should fix up arm?
>

Ah yes, I missed those. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
