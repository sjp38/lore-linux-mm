Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD9C4440846
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 03:31:23 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id g195so107629682ywe.10
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:31:23 -0700 (PDT)
Received: from mail-yb0-x22a.google.com (mail-yb0-x22a.google.com. [2607:f8b0:4002:c09::22a])
        by mx.google.com with ESMTPS id j190si3703719ywd.474.2017.07.11.00.31.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 00:31:22 -0700 (PDT)
Received: by mail-yb0-x22a.google.com with SMTP id f194so35271814yba.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:31:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170705184933.GD3305@redhat.com>
References: <20170703211415.11283-1-jglisse@redhat.com> <20170703211415.11283-2-jglisse@redhat.com>
 <CAPcyv4gXso2W0gxaeTsc7g9nTQnkO3WFNZfsdS95NvfYJupnxg@mail.gmail.com>
 <20170705142516.GA3305@redhat.com> <CAPcyv4hr+p+Bo8dcPfnW+O2q0KWvoM5z9LPZWhXLFJgE5ySojA@mail.gmail.com>
 <20170705184933.GD3305@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 11 Jul 2017 00:31:22 -0700
Message-ID: <CAPcyv4g7DOCDrggZO=yVbkKp4He_5gGtMZQQTqwp_-XdidACqg@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm/persistent-memory: match IORES_DESC name and enum
 memory_type one
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Jul 5, 2017 at 11:49 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Wed, Jul 05, 2017 at 09:15:35AM -0700, Dan Williams wrote:
>> On Wed, Jul 5, 2017 at 7:25 AM, Jerome Glisse <jglisse@redhat.com> wrote=
:
>> > On Mon, Jul 03, 2017 at 04:49:18PM -0700, Dan Williams wrote:
>> >> On Mon, Jul 3, 2017 at 2:14 PM, J=C3=A9r=C3=B4me Glisse <jglisse@redh=
at.com> wrote:
>> >> > Use consistent name between IORES_DESC and enum memory_type, rename
>> >> > MEMORY_DEVICE_PUBLIC to MEMORY_DEVICE_PERSISTENT. This is to free u=
p
>> >> > the public name for CDM (cache coherent device memory) for which th=
e
>> >> > term public is a better match.
>> >> >
>> >> > Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> >> > Cc: Dan Williams <dan.j.williams@intel.com>
>> >> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> >> > ---
>> >> >  include/linux/memremap.h | 4 ++--
>> >> >  kernel/memremap.c        | 2 +-
>> >> >  2 files changed, 3 insertions(+), 3 deletions(-)
>> >> >
>> >> > diff --git a/include/linux/memremap.h b/include/linux/memremap.h
>> >> > index 57546a07a558..2299cc2d387d 100644
>> >> > --- a/include/linux/memremap.h
>> >> > +++ b/include/linux/memremap.h
>> >> > @@ -41,7 +41,7 @@ static inline struct vmem_altmap *to_vmem_altmap(=
unsigned long memmap_start)
>> >> >   * Specialize ZONE_DEVICE memory into multiple types each having d=
ifferents
>> >> >   * usage.
>> >> >   *
>> >> > - * MEMORY_DEVICE_PUBLIC:
>> >> > + * MEMORY_DEVICE_PERSISTENT:
>> >> >   * Persistent device memory (pmem): struct page might be allocated=
 in different
>> >> >   * memory and architecture might want to perform special actions. =
It is similar
>> >> >   * to regular memory, in that the CPU can access it transparently.=
 However,
>> >> > @@ -59,7 +59,7 @@ static inline struct vmem_altmap *to_vmem_altmap(=
unsigned long memmap_start)
>> >> >   * include/linux/hmm.h and Documentation/vm/hmm.txt.
>> >> >   */
>> >> >  enum memory_type {
>> >> > -       MEMORY_DEVICE_PUBLIC =3D 0,
>> >> > +       MEMORY_DEVICE_PERSISTENT =3D 0,
>> >> >         MEMORY_DEVICE_PRIVATE,
>> >> >  };
>> >> >
>> >> > diff --git a/kernel/memremap.c b/kernel/memremap.c
>> >> > index b9baa6c07918..e82456c39a6a 100644
>> >> > --- a/kernel/memremap.c
>> >> > +++ b/kernel/memremap.c
>> >> > @@ -350,7 +350,7 @@ void *devm_memremap_pages(struct device *dev, s=
truct resource *res,
>> >> >         }
>> >> >         pgmap->ref =3D ref;
>> >> >         pgmap->res =3D &page_map->res;
>> >> > -       pgmap->type =3D MEMORY_DEVICE_PUBLIC;
>> >> > +       pgmap->type =3D MEMORY_DEVICE_PERSISTENT;
>> >> >         pgmap->page_fault =3D NULL;
>> >> >         pgmap->page_free =3D NULL;
>> >> >         pgmap->data =3D NULL;
>> >>
>> >> I think we need a different name. There's nothing "persistent" about
>> >> the devm_memremap_pages() path. Why can't they share name, is the onl=
y
>> >> difference coherence? I'm thinking something like:
>> >>
>> >> MEMORY_DEVICE_PRIVATE
>> >> MEMORY_DEVICE_COHERENT /* persistent memory and coherent devices */
>> >> MEMORY_DEVICE_IO /* "public", but not coherent */
>> >
>> > No that would not work. Device public (in the context of this patchset=
)
>> > is like device private ie device public page can be anywhere inside a
>> > process address space either as anonymous memory page or as file back
>> > page of regular filesystem (ie vma->ops is not pointing to anything
>> > specific to the device memory).
>> >
>> > As such device public is different from how persistent memory is use
>> > and those the cache coherency being the same between the two kind of
>> > memory is not a discerning factor. So i need to distinguish between
>> > persistent memory and device public memory.
>> >
>> > I believe keeping enum memory_type close to IORES_DESC naming is the
>> > cleanest way to do that but i am open to other name suggestion.
>> >
>>
>> The IORES_DESC has nothing to do with how the memory range is handled
>> by the core mm. It sounds like the distinction this is trying to make
>> is between MEMORY_DEVICE_{PUBLIC,PRIVATE} and MEMORY_DEVICE_HOST.
>> Where a "host" memory range is one that does not need coordination
>> with a specific device.
>
> I want to distinguish between:
>   - device memory that is not accessible by the CPU
>   - device memory that is accessible by the CPU just like regular
>     memory
>   - existing user of devm_memremap_pages() which is persistent memory
>     (only pmem seems to call devm_memremap_pages()) that is use like a
>     filesystem or block device and thus isn't use like generic page in
>     a process address space
>
> So if existing user of devm_memremap_pages() are only persistent memory
> then it made sense to match the IORES_DESC we are expecting to see on
> see such memory.
>
> For public device memory (in the sense introduced by this patchset) i
> do not know how it will be described by IORES_DESC. i think first folks
> with it are IBM with CAPI and i am not sure they defined something for
> that already.
>
> I am open to any name beside public (well any reasonable name :)) but
> i do need to be able to distinguish persistent memory as use today from
> this device memory.

Right, so that's why I suggested MEMORY_DEVICE_HOST for memory that is
just normal host memory and does not have any device-entanglements
outside of the base ZONE_DEVICE registration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
