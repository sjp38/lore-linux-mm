Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2C536B0022
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 14:28:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m198so7037018pga.4
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 11:28:51 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0047.outbound.protection.outlook.com. [104.47.40.47])
        by mx.google.com with ESMTPS id s13si3996121pgs.179.2018.03.12.11.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 Mar 2018 11:28:50 -0700 (PDT)
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
From: Felix Kuehling <felix.kuehling@amd.com>
Message-ID: <ef3d82cd-6c39-a50a-c4cb-d9d9ba13e31b@amd.com>
Date: Mon, 12 Mar 2018 14:28:42 -0400
MIME-Version: 1.0
In-Reply-To: <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-CA
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christian.koenig@amd.com, jglisse@redhat.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, "Bridgman, John" <John.Bridgman@amd.com>

On 2018-03-10 10:01 AM, Christian KA?nig wrote:
>> To accomodate those we need to
>> create a "hole" inside the process address space. This patchset have
>> a hack for that (patch 13 HACK FOR HMM AREA), it reserves a range of
>> device file offset so that process can mmap this range with PROT_NONE
>> to create a hole (process must make sure the hole is below 1 << 40).
>> I feel un-easy of doing it this way but maybe it is ok with other
>> folks.
>
> Well we have essentially the same problem with pre gfx9 AMD hardware.
> Felix might have some advise how it was solved for HSA. 

For pre-gfx9 hardware we reserve address space in user mode using a big
mmap PROT_NONE call at application start. Then we manage the address
space in user mode and use MAP_FIXED to map buffers at specific
addresses within the reserved range.

The big address space reservation causes issues for some debugging tools
(clang-sanitizer was mentioned to me), so with gfx9 we're going to get
rid of this address space reservation.

Regards,
A  Felix
