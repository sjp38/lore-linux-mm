Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92FDC6B0007
	for <linux-mm@kvack.org>; Thu, 24 May 2018 04:50:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t2-v6so408575pgo.0
        for <linux-mm@kvack.org>; Thu, 24 May 2018 01:50:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h6-v6sor5493998pgc.313.2018.05.24.01.50.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 01:50:25 -0700 (PDT)
Subject: Re: [PATCH v2] mm/ksm: ignore STABLE_FLAG of rmap_item->address in
 rmap_walk_ksm
References: <20180503124415.3f9d38aa@p-imbrenda.boeblingen.de.ibm.com>
 <1525403506-6750-1-git-send-email-hejianet@gmail.com>
 <20180509163101.02f23de1842a822c61fc68ff@linux-foundation.org>
 <2cd6b39b-1496-bbd5-9e31-5e3dcb31feda@arm.com>
 <6c417ab1-a808-72ea-9618-3d76ec203684@arm.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <198fe48c-0d26-7dd1-89dc-415bd3c7ab41@gmail.com>
Date: Thu, 24 May 2018 16:50:16 +0800
MIME-Version: 1.0
In-Reply-To: <6c417ab1-a808-72ea-9618-3d76ec203684@arm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suzuki K Poulose <Suzuki.Poulose@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com, Hugh Dickins <hughd@google.com>

Hi Suzuki

On 5/24/2018 4:44 PM, Suzuki K Poulose Wrote:
> On 14/05/18 10:45, Suzuki K Poulose wrote:
>> On 10/05/18 00:31, Andrew Morton wrote:
>>> On Fri,A  4 May 2018 11:11:46 +0800 Jia He <hejianet@gmail.com> wrote:
>>>
>>>> In our armv8a server(QDF2400), I noticed lots of WARN_ON caused by PAGE_SIZE
>>>> unaligned for rmap_item->address under memory pressure tests(start 20 guests
>>>> and run memhog in the host).
>>>>
>>>> ...
>>>>
>>>> In rmap_walk_ksm, the rmap_item->address might still have the STABLE_FLAG,
>>>> then the start and end in handle_hva_to_gpa might not be PAGE_SIZE aligned.
>>>> Thus it will cause exceptions in handle_hva_to_gpa on arm64.
>>>>
>>>> This patch fixes it by ignoring(not removing) the low bits of address when
>>>> doing rmap_walk_ksm.
>>>>
>>>> Signed-off-by: jia.he@hxt-semitech.com
>>>
>>> I assumed you wanted this patch to be committed as
>>> From:jia.he@hxt-semitech.com rather than From:hejianet@gmail.com, so I
>>> made that change.A  Please let me know if this was inappropriate.
>>>
>>> You can do this yourself by adding an explicit From: line to the very
>>> start of the patch's email text.
>>>
>>> Also, a storm of WARN_ONs is pretty poor behaviour.A  Is that the only
>>> misbehaviour which this bug causes?A  Do you think the fix should be
>>> backported into earlier kernels?
>>>
> 
> 
> Jia, Andrew,
> 
> What is the status of this patch ?
> 
> Suzuki
I thought the patch is merged into mmotm tree.
http://www.ozlabs.org/~akpm/mmotm/series
But I don't know what is the next step.

Cheers,
Jia
