Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A6EB86810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:35:05 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g14so2070956pgu.9
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 12:35:05 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id o33si128809plb.384.2017.07.11.12.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 12:35:04 -0700 (PDT)
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
 <20170711182922.GC5347@redhat.com>
 <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
 <20170711184919.GD5347@redhat.com>
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Message-ID: <84d83148-41a3-d0e8-be80-56187a8e8ccc@nvidia.com>
Date: Tue, 11 Jul 2017 12:35:03 -0700
MIME-Version: 1.0
In-Reply-To: <20170711184919.GD5347@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 7/11/17 11:49 AM, Jerome Glisse wrote:

>
> What are the symptoms ? The program just stop making any progress and you
> trigger a sysrequest to dump current states of each threads ? In this
> log i don't see migration_entry_wait() anymore but it seems to be waiting
> on page lock so there might be 2 issues here.
>
> J=C3=A9r=C3=B4me

That is correct, the program is not making any progress.

The stack traces in the kernel log are produced by a "sysrq w" (blocked=20
tasks) command.

Thanks,

--=20
Evgeny Baskakov
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
