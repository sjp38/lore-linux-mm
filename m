Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 484BE6B02B4
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 05:02:13 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c66so977403qkb.11
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 02:02:13 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id 21si1377841qtu.34.2017.06.07.02.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 02:02:12 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id d14so701292qkb.1
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 02:02:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170601223518.GA2780@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com> <20170524172024.30810-13-jglisse@redhat.com>
 <20170531135954.1d67ca31@firefly.ozlabs.ibm.com> <20170601223518.GA2780@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 7 Jun 2017 19:02:11 +1000
Message-ID: <CAKTCnz=dHsiHVPmAro1=9PoFiUQt8hzxVenpTwSzOM9aSjsXOQ@mail.gmail.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Fri, Jun 2, 2017 at 8:35 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Wed, May 31, 2017 at 01:59:54PM +1000, Balbir Singh wrote:
>> On Wed, 24 May 2017 13:20:21 -0400
>> J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:
>>
>> > This patch add a new memory migration helpers, which migrate memory
>> > backing a range of virtual address of a process to different memory
>> > (which can be allocated through special allocator). It differs from
>> > numa migration by working on a range of virtual address and thus by
>> > doing migration in chunk that can be large enough to use DMA engine
>> > or special copy offloading engine.
>> >
>> > Expected users are any one with heterogeneous memory where different
>> > memory have different characteristics (latency, bandwidth, ...). As
>> > an example IBM platform with CAPI bus can make use of this feature
>> > to migrate between regular memory and CAPI device memory. New CPU
>> > architecture with a pool of high performance memory not manage as
>> > cache but presented as regular memory (while being faster and with
>> > lower latency than DDR) will also be prime user of this patch.
>> >
>> > Migration to private device memory will be useful for device that
>> > have large pool of such like GPU, NVidia plans to use HMM for that.
>> >
>>
>> It is helpful, for HMM-CDM however we would like to avoid the downsides
>> of MIGRATE_SYNC_NOCOPY
>
> What are the downside you are referring too ?

IIUC, MIGRATE_SYNC_NO_COPY is for anonymous memory only.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
