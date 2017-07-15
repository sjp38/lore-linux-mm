Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15316440941
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 01:04:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v26so107344735pfa.0
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 22:04:47 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id g14si8446796plk.15.2017.07.14.22.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 22:04:46 -0700 (PDT)
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
 <20170711182922.GC5347@redhat.com>
 <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
 <20170711184919.GD5347@redhat.com>
 <84d83148-41a3-d0e8-be80-56187a8e8ccc@nvidia.com>
 <20170713201620.GB1979@redhat.com>
 <ca12b033-8ec5-84b0-c2aa-ea829e1194fa@nvidia.com>
 <20170715005554.GA12694@redhat.com>
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Message-ID: <648abdac-f9ae-ad59-0915-263ba8909b3d@nvidia.com>
Date: Fri, 14 Jul 2017 22:04:43 -0700
MIME-Version: 1.0
In-Reply-To: <20170715005554.GA12694@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 7/14/17 5:55 PM, Jerome Glisse wrote:
> So pushed an updated hmm-next branch this should fix all issues you had.
> Thought i am not sure about the test in this mail, all i see is that it
> continously spit error messages but it does not hang (i let it run 20min
> or so). Dunno if that is what expected. Let me know if this is still an
> issue and if so what should be the expected output of this test program.
>
> Cheers,
> J=C3=A9r=C3=B4me

Thanks, Jerome. The kernel hang indeed seems to be fixed.

Regarding the last issue I reported. It still persists. The test program=20
should eventually exit. Instead, it loops indefinitely (sorry, I was not=20
clear when I called it 'app-side hang').

This is what's expected. The number of error messages can be random, but=20
must be finite; the program must print "OK" at the end:

$ ./run.sh
&&& 1 migrate threads: STARTING
iteration 0
thread 0 is migrating 10000 pages starting from 0x7f6abce79000
migrate_thread_func:87: failed to migrate pages at 0x7f6abce79000=20
(migrate.npages (tid 0): 9725 !=3D npages: 10000)
thread 0 is migrating 10000 pages starting from 0x7f6abce79000
thread 0 is migrating 10000 pages starting from 0x7f6abce79000
&&& 1 migrate threads: PASSED
(OK)[./sanity_rmem004] anon migration read test

Thanks,

--=20
Evgeny Baskakov
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
