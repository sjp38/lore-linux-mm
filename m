Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA5436B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 11:22:55 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k126so17241888qke.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 08:22:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e36si1222639qtd.521.2017.08.08.08.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 08:22:55 -0700 (PDT)
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
References: <20170806140425.20937-1-riel@redhat.com>
 <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
 <bfdab709-e5b2-0d26-1c0f-31535eda1678@redhat.com>
 <1502198148.6577.18.camel@redhat.com>
 <0324df31-717d-32c1-95ef-351c5b23105f@oracle.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <aada5d93-9acb-c7c3-348c-044868335a0c@redhat.com>
Date: Tue, 8 Aug 2017 17:22:49 +0200
MIME-Version: 1.0
In-Reply-To: <0324df31-717d-32c1-95ef-351c5b23105f@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On 08/08/2017 05:19 PM, Mike Kravetz wrote:
> On 08/08/2017 06:15 AM, Rik van Riel wrote:
>> On Tue, 2017-08-08 at 11:58 +0200, Florian Weimer wrote:
>>> On 08/07/2017 08:23 PM, Mike Kravetz wrote:
>>>> If my thoughts above are correct, what about returning EINVAL if
>>>> one
>>>> attempts to set MADV_DONTFORK on mappings set up for sharing?
>>>
>>> That's my preference as well.  If there is a use case for shared or
>>> non-anonymous mappings, then we can implement MADV_DONTFORK with the
>>> semantics for this use case.  If we pick some arbitrary semantics
>>> now,
>>> without any use case, we might end up with something that's not
>>> actually
>>> useful.
>>
>> MADV_DONTFORK is existing semantics, and it is enforced
>> on shared, non-anonymous mappings. It is frequently used
>> for things like device mappings, which should not be
>> inherited by a child process, because the device can only
>> be used by one process at a time.
>>
>> When someone requests MADV_DONTFORK on a shared VMA, they
>> will get it. The later madvise request overrides the mmap
>> flags that were used earlier.
>>
>> The question is, should MADV_WIPEONFORK (introduced by
>> this series) have not just different semantics, but also
>> totally different behavior from MADV_DONTFORK?
> 
> Sorry for the confusion.  I accidentally used MADV_DONTFORK instead
> of MADV_WIPEONFORK in my reply (which Florian commented on).

Yes, I made the same mistake.  I meant MADV_WIPEONFORK as well.

Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
