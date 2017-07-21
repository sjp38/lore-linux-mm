Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADAC6B0292
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 18:01:51 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u7so36871036pgo.6
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 15:01:51 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 43si3509946pla.295.2017.07.21.15.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 15:01:48 -0700 (PDT)
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
 <20170711182922.GC5347@redhat.com>
 <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
 <20170711184919.GD5347@redhat.com>
 <84d83148-41a3-d0e8-be80-56187a8e8ccc@nvidia.com>
 <20170713201620.GB1979@redhat.com>
 <ca12b033-8ec5-84b0-c2aa-ea829e1194fa@nvidia.com>
 <20170715005554.GA12694@redhat.com>
 <cfba9bfb-5178-bcae-0fa9-ef66e2a871d5@nvidia.com>
 <20170721013303.GA25991@redhat.com>
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Message-ID: <c6f02f5a-f3fa-487b-9651-b280f8979a72@nvidia.com>
Date: Fri, 21 Jul 2017 15:01:47 -0700
MIME-Version: 1.0
In-Reply-To: <20170721013303.GA25991@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 7/20/17 6:33 PM, Jerome Glisse wrote:

> So i pushed an updated hmm-next branch it should have all fixes so far, i=
ncluding
> something that should fix this issue. I still want to go over all emails =
again
> to make sure i am not forgetting anything.
>
> Cheers,
> J=C3=A9r=C3=B4me

Hi Jerome,

The issues I observed seem to be gone!

I am still running my stress tests, though. I will let you know if there=20
is anything else that needs to be addressed.

Thanks!

--=20
Evgeny Baskakov
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
