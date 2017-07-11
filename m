Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71A516B04CD
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 20:17:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3so129556633pfc.4
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 17:17:26 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id e3si9023719pgu.37.2017.07.10.17.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 17:17:24 -0700 (PDT)
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <f04a007d-fc34-fe3a-d366-1363248a609f@nvidia.com>
 <20170710234339.GA15226@redhat.com>
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Message-ID: <57146eb3-43bc-6e8b-4c8e-0632aa8ed577@nvidia.com>
Date: Mon, 10 Jul 2017 17:17:23 -0700
MIME-Version: 1.0
In-Reply-To: <20170710234339.GA15226@redhat.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 7/10/17 4:43 PM, Jerome Glisse wrote:

> On Mon, Jul 10, 2017 at 03:59:37PM -0700, Evgeny Baskakov wrote:
> ...
> Horrible stupid bug in the code, most likely from cut and paste. Attached
> patch should fix it. I don't know how long it took for you to trigger it.
>
> J=E9r=F4me
Thanks, this indeed fixes the problem! Yes, it took a nightly run before=20
it triggered.

One a side note, should this "return NULL" be replaced with "return=20
ERR_PTR(-ENOMEM)"?

struct hmm_device *hmm_device_new(void *drvdata)
{
...
     if (hmm_device->minor >=3D HMM_DEVICE_MAX) {
         spin_unlock(&hmm_device_lock);
         kfree(hmm_device);
->      return NULL;
     }

Thanks!

Evgeny Baskakov
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
