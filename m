Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 21D8E6B03BB
	for <linux-mm@kvack.org>; Sat, 22 Apr 2017 00:46:29 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a3so74167979oii.3
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 21:46:29 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id v199si6568422oie.221.2017.04.21.21.46.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 21:46:28 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id y11so86174079oie.0
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 21:46:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170422033037.3028-3-jglisse@redhat.com>
References: <20170422033037.3028-1-jglisse@redhat.com> <20170422033037.3028-3-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 21 Apr 2017 21:46:27 -0700
Message-ID: <CAPcyv4gGa_RrsbXHMH3Jy=GHPX-Vup-Bto-QM2OwY+BpO8MeQQ@mail.gmail.com>
Subject: Re: [HMM 02/15] mm/put_page: move ZONE_DEVICE page reference
 decrement v2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Apr 21, 2017 at 8:30 PM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.co=
m> wrote:
> Move page reference decrement of ZONE_DEVICE from put_page()
> to put_zone_device_page() this does not affect non ZONE_DEVICE
> page.
>
> Doing this allow to catch when a ZONE_DEVICE page refcount reach
> 1 which means the device is no longer reference by any one (unlike
> page from other zone, ZONE_DEVICE page refcount never reach 0).
>
> This patch is just a preparatory patch for HMM.
>
> Changes since v1:
>   - commit message
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
