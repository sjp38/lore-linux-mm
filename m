Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3A86B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 13:43:28 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n40so16325071qtb.4
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 10:43:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 67si781209qkv.175.2017.06.15.10.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 10:43:27 -0700 (PDT)
Date: Thu, 15 Jun 2017 13:43:25 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <1982176625.36197567.1497548604992.JavaMail.zimbra@redhat.com>
In-Reply-To: <59420204.905@huawei.com>
References: <20170524172024.30810-1-jglisse@redhat.com> <20170524172024.30810-8-jglisse@redhat.com> <59420204.905@huawei.com>
Subject: Re: [HMM 07/15] mm/ZONE_DEVICE: new type of ZONE_DEVICE for
 unaddressable memory v3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

> On 2017/5/25 1:20, J=C3=A9r=C3=B4me Glisse wrote:

[...]

> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index d744cff..f5357ff 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -736,6 +736,19 @@ config ZONE_DEVICE
> > =20
> >  =09  If FS_DAX is enabled, then say Y.
> > =20
> > +config DEVICE_PRIVATE
> > +=09bool "Unaddressable device memory (GPU memory, ...)"
> > +=09depends on X86_64
> > +=09depends on ZONE_DEVICE
> > +=09depends on MEMORY_HOTPLUG
> > +=09depends on MEMORY_HOTREMOVE
> > +=09depends on SPARSEMEM_VMEMMAP
> > +
>  maybe just depends on ARCH_HAS_HMM is enough.

I have updated that as part of HMM CDM patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
