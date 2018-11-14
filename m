Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id B34526B026D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 04:59:41 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id b80-v6so12442879ywe.15
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 01:59:41 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id s5-v6si16590339ywj.366.2018.11.14.01.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 01:59:40 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v3] mm: Create the new vm_fault_t type
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <CAFqt6zbwwkvuZypssKQtsKdfZKk3DEQXpA7Qw6yDNakpu=Jv1w@mail.gmail.com>
Date: Wed, 14 Nov 2018 02:59:11 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <0EAE1409-DF80-4A9A-8936-C6E9BC7C9604@oracle.com>
References: <20181106120544.GA3783@jordon-HP-15-Notebook-PC>
 <CAFqt6zbwwkvuZypssKQtsKdfZKk3DEQXpA7Qw6yDNakpu=Jv1w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, vbabka@suse.cz, riel@redhat.com, rppt@linux.ibm.com, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org



> On Nov 13, 2018, at 10:13 PM, Souptick Joarder <jrdr.linux@gmail.com> =
wrote:
>=20
> On Tue, Nov 6, 2018 at 5:33 PM Souptick Joarder <jrdr.linux@gmail.com> =
wrote:
>>=20
>> Page fault handlers are supposed to return VM_FAULT codes,
>> but some drivers/file systems mistakenly return error
>> numbers. Now that all drivers/file systems have been converted
>> to use the vm_fault_t return type, change the type definition
>> to no longer be compatible with 'int'. By making it an unsigned
>> int, the function prototype becomes incompatible with a function
>> which returns int. Sparse will detect any attempts to return a
>> value which is not a VM_FAULT code.
>>=20
>> VM_FAULT_SET_HINDEX and VM_FAULT_GET_HINDEX values are changed
>> to avoid conflict with other VM_FAULT codes.
>>=20
>> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>=20
> Any further comment on this patch ?

Reviewed-by: William Kucharski <william.kucharski@oracle.com>
