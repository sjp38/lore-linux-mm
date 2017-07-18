Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A051C6B0292
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 17:41:03 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u5so33630809pgq.14
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 14:41:03 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id f13si2493921pln.475.2017.07.18.14.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 14:41:02 -0700 (PDT)
Subject: Re: [PATCH 09/15] mm/hmm/devmem: device memory hotplug using
 ZONE_DEVICE v6
References: <20170628180047.5386-1-jglisse@redhat.com>
 <20170628180047.5386-10-jglisse@redhat.com>
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Message-ID: <be0503da-f1c4-f3c2-dace-6a9aa02c3186@nvidia.com>
Date: Tue, 18 Jul 2017 14:41:01 -0700
MIME-Version: 1.0
In-Reply-To: <20170628180047.5386-10-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On 6/28/17 11:00 AM, J=C3=A9r=C3=B4me Glisse wrote:

> +/*
> + * struct hmm_devmem_ops - callback for ZONE_DEVICE memory events
> + *
> + * @free: call when refcount on page reach 1 and thus is no longer use
> + * @fault: call when there is a page fault to unaddressable memory
> + */
> +struct hmm_devmem_ops {
> +	void (*free)(struct hmm_devmem *devmem, struct page *page);
> +	int (*fault)(struct hmm_devmem *devmem,
> +		     struct vm_area_struct *vma,
> +		     unsigned long addr,
> +		     struct page *page,
> +		     unsigned int flags,
> +		     pmd_t *pmdp);
> +};
>

Hi Jerome,

As discussed, could you please add detailed documentation for these=20
callbacks?

Specifically, for the 'fault' callback it is important to clarify the=20
meaning of each of its parameters and the return value (which error=20
codes are expected to be returned from it).

Thanks!

--=20
Evgeny Baskakov
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
