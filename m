Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43F006B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 21:31:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p86so4496566pfl.12
        for <linux-mm@kvack.org>; Tue, 30 May 2017 18:31:15 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id u80si2909084pgb.204.2017.05.30.18.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 18:31:14 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id w69so594592pfk.1
        for <linux-mm@kvack.org>; Tue, 30 May 2017 18:31:14 -0700 (PDT)
Date: Wed, 31 May 2017 11:31:04 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [HMM 06/15] mm/memory_hotplug: introduce add_pages
Message-ID: <20170531113104.006dfc7e@firefly.ozlabs.ibm.com>
In-Reply-To: <20170524172024.30810-7-jglisse@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
	<20170524172024.30810-7-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>

On Wed, 24 May 2017 13:20:15 -0400
J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:

> From: Michal Hocko <mhocko@suse.com>
>=20
> There are new users of memory hotplug emerging. Some of them require
> different subset of arch_add_memory. There are some which only require
> allocation of struct pages without mapping those pages to the kernel
> address space. We currently have __add_pages for that purpose. But this
> is rather lowlevel and not very suitable for the code outside of the
> memory hotplug. E.g. x86_64 wants to update max_pfn which should be
> done by the caller. Introduce add_pages() which should care about those
> details if they are needed. Each architecture should define its
> implementation and select CONFIG_ARCH_HAS_ADD_PAGES. All others use
> the currently existing __add_pages.
>=20
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---

Acked-by: Balbir Singh <bsingharora@gmail.com>

Looks good, from a CDM perspective, this means that HMM-CDM would continue
to use arch_add_memory()

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
