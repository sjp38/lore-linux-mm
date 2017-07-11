Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2B46B0533
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 12:49:55 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id b82so3382842ywc.11
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 09:49:55 -0700 (PDT)
Received: from mail-yw0-x22e.google.com (mail-yw0-x22e.google.com. [2607:f8b0:4002:c05::22e])
        by mx.google.com with ESMTPS id y2si5524ywc.367.2017.07.11.09.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 09:49:53 -0700 (PDT)
Received: by mail-yw0-x22e.google.com with SMTP id l21so4128025ywb.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 09:49:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170711150558.GB5347@redhat.com>
References: <20170703211415.11283-1-jglisse@redhat.com> <20170703211415.11283-2-jglisse@redhat.com>
 <CAPcyv4gXso2W0gxaeTsc7g9nTQnkO3WFNZfsdS95NvfYJupnxg@mail.gmail.com>
 <20170705142516.GA3305@redhat.com> <CAPcyv4hr+p+Bo8dcPfnW+O2q0KWvoM5z9LPZWhXLFJgE5ySojA@mail.gmail.com>
 <20170705184933.GD3305@redhat.com> <CAPcyv4g7DOCDrggZO=yVbkKp4He_5gGtMZQQTqwp_-XdidACqg@mail.gmail.com>
 <20170711150558.GB5347@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 11 Jul 2017 09:49:53 -0700
Message-ID: <CAPcyv4hnKwwbSYi_HW7hC8Z2Ox0riBSRgdNGGhSw2_2zSgUFiA@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm/persistent-memory: match IORES_DESC name and enum
 memory_type one
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Jul 11, 2017 at 8:05 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Tue, Jul 11, 2017 at 12:31:22AM -0700, Dan Williams wrote:
>> On Wed, Jul 5, 2017 at 11:49 AM, Jerome Glisse <jglisse@redhat.com> wrot=
e:
>> > On Wed, Jul 05, 2017 at 09:15:35AM -0700, Dan Williams wrote:
>> >> On Wed, Jul 5, 2017 at 7:25 AM, Jerome Glisse <jglisse@redhat.com> wr=
ote:
>> >> > On Mon, Jul 03, 2017 at 04:49:18PM -0700, Dan Williams wrote:
>> >> >> On Mon, Jul 3, 2017 at 2:14 PM, J=C3=A9r=C3=B4me Glisse <jglisse@r=
edhat.com> wrote:
>> >> >> > Use consistent name between IORES_DESC and enum memory_type, ren=
ame
>> >> >> > MEMORY_DEVICE_PUBLIC to MEMORY_DEVICE_PERSISTENT. This is to fre=
e up
>> >> >> > the public name for CDM (cache coherent device memory) for which=
 the
>> >> >> > term public is a better match.
>> >> >> >
>> >> >> > Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> >> >> > Cc: Dan Williams <dan.j.williams@intel.com>
>> >> >> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> >> >> > ---
>> >> >> >  include/linux/memremap.h | 4 ++--
>> >> >> >  kernel/memremap.c        | 2 +-
>> >> >> >  2 files changed, 3 insertions(+), 3 deletions(-)
>> >> >> >
>> >> >> > diff --git a/include/linux/memremap.h b/include/linux/memremap.h
>> >> >> > index 57546a07a558..2299cc2d387d 100644
>> >> >> > --- a/include/linux/memremap.h
>> >> >> > +++ b/include/linux/memremap.h
>> >> >> > @@ -41,7 +41,7 @@ static inline struct vmem_altmap *to_vmem_altm=
ap(unsigned long memmap_start)
>> >> >> >   * Specialize ZONE_DEVICE memory into multiple types each havin=
g differents
>> >> >> >   * usage.
>> >> >> >   *
>> >> >> > - * MEMORY_DEVICE_PUBLIC:
>> >> >> > + * MEMORY_DEVICE_PERSISTENT:
>> >> >> >   * Persistent device memory (pmem): struct page might be alloca=
ted in different
>> >> >> >   * memory and architecture might want to perform special action=
s. It is similar
>> >> >> >   * to regular memory, in that the CPU can access it transparent=
ly. However,
>> >> >> > @@ -59,7 +59,7 @@ static inline struct vmem_altmap *to_vmem_altm=
ap(unsigned long memmap_start)
>> >> >> >   * include/linux/hmm.h and Documentation/vm/hmm.txt.
>> >> >> >   */
>> >> >> >  enum memory_type {
>> >> >> > -       MEMORY_DEVICE_PUBLIC =3D 0,
>> >> >> > +       MEMORY_DEVICE_PERSISTENT =3D 0,
>> >> >> >         MEMORY_DEVICE_PRIVATE,
>> >> >> >  };
>> >> >> >
>> >> >> > diff --git a/kernel/memremap.c b/kernel/memremap.c
>> >> >> > index b9baa6c07918..e82456c39a6a 100644
>> >> >> > --- a/kernel/memremap.c
>> >> >> > +++ b/kernel/memremap.c
>> >> >> > @@ -350,7 +350,7 @@ void *devm_memremap_pages(struct device *dev=
, struct resource *res,
>> >> >> >         }
>> >> >> >         pgmap->ref =3D ref;
>> >> >> >         pgmap->res =3D &page_map->res;
>> >> >> > -       pgmap->type =3D MEMORY_DEVICE_PUBLIC;
>> >> >> > +       pgmap->type =3D MEMORY_DEVICE_PERSISTENT;
>> >> >> >         pgmap->page_fault =3D NULL;
>> >> >> >         pgmap->page_free =3D NULL;
>> >> >> >         pgmap->data =3D NULL;
>> >> >>
>> >> >> I think we need a different name. There's nothing "persistent" abo=
ut
>> >> >> the devm_memremap_pages() path. Why can't they share name, is the =
only
>> >> >> difference coherence? I'm thinking something like:
>> >> >>
>> >> >> MEMORY_DEVICE_PRIVATE
>> >> >> MEMORY_DEVICE_COHERENT /* persistent memory and coherent devices *=
/
>> >> >> MEMORY_DEVICE_IO /* "public", but not coherent */
>> >> >
>> >> > No that would not work. Device public (in the context of this patch=
set)
>> >> > is like device private ie device public page can be anywhere inside=
 a
>> >> > process address space either as anonymous memory page or as file ba=
ck
>> >> > page of regular filesystem (ie vma->ops is not pointing to anything
>> >> > specific to the device memory).
>> >> >
>> >> > As such device public is different from how persistent memory is us=
e
>> >> > and those the cache coherency being the same between the two kind o=
f
>> >> > memory is not a discerning factor. So i need to distinguish between
>> >> > persistent memory and device public memory.
>> >> >
>> >> > I believe keeping enum memory_type close to IORES_DESC naming is th=
e
>> >> > cleanest way to do that but i am open to other name suggestion.
>> >> >
>> >>
>> >> The IORES_DESC has nothing to do with how the memory range is handled
>> >> by the core mm. It sounds like the distinction this is trying to make
>> >> is between MEMORY_DEVICE_{PUBLIC,PRIVATE} and MEMORY_DEVICE_HOST.
>> >> Where a "host" memory range is one that does not need coordination
>> >> with a specific device.
>> >
>> > I want to distinguish between:
>> >   - device memory that is not accessible by the CPU
>> >   - device memory that is accessible by the CPU just like regular
>> >     memory
>> >   - existing user of devm_memremap_pages() which is persistent memory
>> >     (only pmem seems to call devm_memremap_pages()) that is use like a
>> >     filesystem or block device and thus isn't use like generic page in
>> >     a process address space
>> >
>> > So if existing user of devm_memremap_pages() are only persistent memor=
y
>> > then it made sense to match the IORES_DESC we are expecting to see on
>> > see such memory.
>> >
>> > For public device memory (in the sense introduced by this patchset) i
>> > do not know how it will be described by IORES_DESC. i think first folk=
s
>> > with it are IBM with CAPI and i am not sure they defined something for
>> > that already.
>> >
>> > I am open to any name beside public (well any reasonable name :)) but
>> > i do need to be able to distinguish persistent memory as use today fro=
m
>> > this device memory.
>>
>> Right, so that's why I suggested MEMORY_DEVICE_HOST for memory that is
>> just normal host memory and does not have any device-entanglements
>> outside of the base ZONE_DEVICE registration.
>
> Well the memory considered for DEVICE_PUBLIC is device memory so it is
> very much entangled with a device. It is memory that is physically on
> the device. It is just that new system bus like CAPI or CCIX allows
> CPU to access such memory with same cache coherency as if they were
> accessing regular system DDR memory. It is expect that this memory
> will be manage by the device driver and not core memory management.
>
> But i am ok with MEMORY_DEVICE_HOST after all this just a name. But
> what you put behind that name is not the reality of the memory. I just
> want to be clear on that.
>

I was suggesting MEMORY_DEVICE_HOST for persistent memory and
MEMORY_DEVICE_PUBLIC as you want for CDM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
