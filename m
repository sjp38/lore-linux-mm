Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B63556B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 07:08:38 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id y123-v6so7750665oie.5
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 04:08:38 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g12-v6si8247147oti.89.2018.06.08.04.08.37
        for <linux-mm@kvack.org>;
        Fri, 08 Jun 2018 04:08:37 -0700 (PDT)
Subject: Re: [PATCH v2] mm/ksm: ignore STABLE_FLAG of rmap_item->address in
 rmap_walk_ksm
References: <20180503124415.3f9d38aa@p-imbrenda.boeblingen.de.ibm.com>
 <1525403506-6750-1-git-send-email-hejianet@gmail.com>
 <20180509163101.02f23de1842a822c61fc68ff@linux-foundation.org>
 <2cd6b39b-1496-bbd5-9e31-5e3dcb31feda@arm.com>
 <6c417ab1-a808-72ea-9618-3d76ec203684@arm.com>
 <20180524133805.6e9bfd4bf48de065ce1d7611@linux-foundation.org>
 <20180607151344.a22a1e7182a2142e6d24e4de@linux-foundation.org>
From: Suzuki K Poulose <suzuki.poulose@arm.com>
Message-ID: <ab427520-7e1c-097d-3a37-09c1ff05bcac@arm.com>
Date: Fri, 8 Jun 2018 12:08:45 +0100
MIME-Version: 1.0
In-Reply-To: <20180607151344.a22a1e7182a2142e6d24e4de@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com, Hugh Dickins <hughd@google.com>

On 06/07/2018 11:13 PM, Andrew Morton wrote:
> On Thu, 24 May 2018 13:38:05 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>>>
>>> Jia, Andrew,
>>>
>>> What is the status of this patch ?
>>>
>>
>> I have it scheduled for 4.18-rc1, with a cc:stable for backporting.
>>
>> I'd normally put such a fix into 4.17-rcX but I'd like to give Hugh
>> time to review it and to generally give it a bit more time for review
>> and test.
>>
>> Have you tested it yourself?
> 
> I'll take your silence as a no.
> 

Hi Andrew,

Sorry, I missed this one. I can see give a try to reproduce the problem
and verify the fix.

Cheers
Suzuki
