Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD1816B0292
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 17:05:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u17so39587793pfa.6
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 14:05:02 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id q63si2049895pfb.694.2017.07.20.14.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 14:05:01 -0700 (PDT)
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <f04a007d-fc34-fe3a-d366-1363248a609f@nvidia.com>
 <20170710234339.GA15226@redhat.com>
 <57146eb3-43bc-6e8b-4c8e-0632aa8ed577@nvidia.com>
 <20170711005408.GA15896@redhat.com>
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Message-ID: <d31b88e7-be7e-c1ca-513f-f12edb126eac@nvidia.com>
Date: Thu, 20 Jul 2017 14:05:00 -0700
MIME-Version: 1.0
In-Reply-To: <20170711005408.GA15896@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 7/10/17 5:54 PM, Jerome Glisse wrote:

> On Mon, Jul 10, 2017 at 05:17:23PM -0700, Evgeny Baskakov wrote:
>> On 7/10/17 4:43 PM, Jerome Glisse wrote:
>>
>>> On Mon, Jul 10, 2017 at 03:59:37PM -0700, Evgeny Baskakov wrote:
>>> ...
>>> Horrible stupid bug in the code, most likely from cut and paste. Attach=
ed
>>> patch should fix it. I don't know how long it took for you to trigger i=
t.
>>>
>>> J=C3=A9r=C3=B4me
>> Thanks, this indeed fixes the problem! Yes, it took a nightly run before=
 it
>> triggered.
>>
>> One a side note, should this "return NULL" be replaced with "return
>> ERR_PTR(-ENOMEM)"?
> Or -EBUSY but yes sure.
>
> J=C3=A9r=C3=B4me

Hi Jerome,

Are these fixes in already (for the alloc_chrdev_region and "return=20
NULL" issues)? I don't see them in hmm-next nor in hmm-v24.

Can you please double check it?

Thanks!

--=20
Evgeny Baskakov
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
