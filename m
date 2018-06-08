Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 844CB6B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 21:23:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e16-v6so5362625pfn.5
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 18:23:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e4-v6sor3617549pfn.127.2018.06.07.18.23.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 18:23:29 -0700 (PDT)
Subject: Re: [PATCH v2] mm/ksm: ignore STABLE_FLAG of rmap_item->address in
 rmap_walk_ksm
References: <20180503124415.3f9d38aa@p-imbrenda.boeblingen.de.ibm.com>
 <1525403506-6750-1-git-send-email-hejianet@gmail.com>
 <20180509163101.02f23de1842a822c61fc68ff@linux-foundation.org>
 <2cd6b39b-1496-bbd5-9e31-5e3dcb31feda@arm.com>
 <6c417ab1-a808-72ea-9618-3d76ec203684@arm.com>
 <20180524133805.6e9bfd4bf48de065ce1d7611@linux-foundation.org>
 <20180607151344.a22a1e7182a2142e6d24e4de@linux-foundation.org>
From: Jia He <hejianet@gmail.com>
Message-ID: <f92a05ac-6f9d-a152-fb4c-52bfb15bdffb@gmail.com>
Date: Fri, 8 Jun 2018 09:23:20 +0800
MIME-Version: 1.0
In-Reply-To: <20180607151344.a22a1e7182a2142e6d24e4de@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Suzuki K Poulose <Suzuki.Poulose@arm.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com, Hugh Dickins <hughd@google.com>

Hi Andrew

On 6/8/2018 6:13 AM, Andrew Morton Wrote:
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
Sorry if you asked the previous question to me.
I've tested by myself in arm64 server (QDF2400,46 cpus,96G mem)
Without this patch, the WARN_ON is very easy for reproducing.
After this patch, I have run the same benchmarch for a whole day without any
WARN_ONs

Hope it helpful.

Cheers,
Jia
