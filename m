Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA075C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:47:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A3B8206A3
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:47:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r/34ZJvm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A3B8206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB79E8E0006; Mon,  1 Jul 2019 13:47:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D69878E0002; Mon,  1 Jul 2019 13:47:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C58638E0006; Mon,  1 Jul 2019 13:47:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f78.google.com (mail-ua1-f78.google.com [209.85.222.78])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9558E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 13:47:58 -0400 (EDT)
Received: by mail-ua1-f78.google.com with SMTP id z42so2437285uac.10
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 10:47:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mg0lJheZjJTp76Uwvy64KYyw9aDMKPv0BfHthZ54Upg=;
        b=Zw0YzD6hVmn7sse0hWKegNi/cHBDEdWBVCGBAQsgDKqPIy0xcDmLIx6ul0qCYCTWQh
         tuz4XY5GL0cKIyVSQMtGIdSdr9vHdw9KN8ylAzJnxuuN46AuKrp0CjDeWTeAFjpQgOEN
         XglFa3GFmuioNzHtHDZ7qbodHGswxBwfs8v/b34MJGYPmeIR9TyeeFeRsCzx2EbIBj2o
         ZrMVfgBRJoVVXyz5Dr/VYNM2Wt90z2kc1Bx7am/GpQV7gw2RwE9Bzbw9nUFPggYJciSI
         jUucOYg74ZaRlCeNgIwhRssoW+faXTgBiXuNUthaXrbu0u20YRPt+65HtHz06Htah4bO
         GcTw==
X-Gm-Message-State: APjAAAUTyTmcG1E+3zkVEGjZOLpHLFzBWkvexVnkdmDXwlCPaDJKL8G1
	9oksLQo+MrocJlQyklqnpSwI6Z7lLm6V5EOVEbQ4PweIBeCJuFSuDkjrImNw/JWS5FwplGzVyqw
	1e/+cfE2VoA1CNfkfNh9H1wnyn93G5/Vuqa3f3nQnyaj66aBuLHNuSRAEKx52FgFDWQ==
X-Received: by 2002:a67:f281:: with SMTP id m1mr14768124vsk.184.1562003278208;
        Mon, 01 Jul 2019 10:47:58 -0700 (PDT)
X-Received: by 2002:a67:f281:: with SMTP id m1mr14768091vsk.184.1562003277324;
        Mon, 01 Jul 2019 10:47:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562003277; cv=none;
        d=google.com; s=arc-20160816;
        b=Rrj8SN9l18Gswhc6Uy+TRKIs8TG6ed7KNP4B7vo7NJNYkg3zF74c+NxfqoWZ1CA4zN
         7yWrEe7flwyKlmb+zXK8WLLYkHM0wdQbCwvUTI8hN8R9GEgfQBrcCIJbLPi6l2nMntab
         qHRH0mvxxOQrVd2rTOKrO/DXe/BOO5fM/m/Iw0DdL1EFXnAm49Z+PwS/5WPSJpSbpDXa
         Kjk64oXnXE3pyXyrY4/AeGsHqKrr5miapD+mdDnMDXFodR60GE7PHzosbIo2IJ4COyqn
         CHplAu3J13c64n5Vsfi5mes8OVEpkdpIMOiNRoU8pe8mkhUEjBJg/RQh6tu9LqcxbtpP
         CM4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mg0lJheZjJTp76Uwvy64KYyw9aDMKPv0BfHthZ54Upg=;
        b=gLcXvHgkgrDkD/Ncd1vLqQUnJeNwWkXKB5cKn5tkh2ZS+nQW9Vx/YaX38HVNDOHEa6
         CRuDdI/P3GpkEkBgD5+xanUBJ89NQvLnSkul4AVvZULr0aFIX24uUfSMoHIxwOy/GOg+
         Aqx5dvYDCfICDavETgdlZgGiq2Q0OantcezAve9RPgsqVt1fD1twBEMPEHucJywxZr5z
         oKgw+ABtyVKXvWTmLGbf/zxZ7AIPxhHBRu2JA/UQN6aDqtYKEY4znRrGgu4sTVUpj7Eo
         5V9OTvMr/6Acf7H29fLu0k+Ct0k+onql7kIXRimpidQeTC2ndFMy0kz8YwID21lQkw3m
         Bi7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="r/34ZJvm";
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y25sor5891833vso.31.2019.07.01.10.47.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 10:47:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="r/34ZJvm";
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mg0lJheZjJTp76Uwvy64KYyw9aDMKPv0BfHthZ54Upg=;
        b=r/34ZJvmDVOjYRzKHdKmg17GH2Bx7S3N+IwJBddCwxAxs6d2zvlT+JZfU5pfuKPPhC
         6M/A/xewu5Zr74QYv/FiUfMpv8FVxzKUL3MIkAfD5JLI8d0U6oYILxs8n/Y9IiFeOnw2
         U+Lz/EfwcChGQvh3nOKRZd/WfJAoxOBH0ujRHdLsJKhVldDCaKXxDRzujP6RE3T7j9qj
         2pvtI5vhVYe0ty12+mpfPJrHo6roiyUGwQxDssRodcdhcn+a3IAt7GrCrwzNH6mJcohb
         dBLQZ8JchoXu5XBKAZUigVWoT1NwTi5ecqQC9wxRIfYRKKLBoTQER0tjrL74EuyKce6h
         520w==
X-Google-Smtp-Source: APXvYqwsPdX7uxSrLZ2M4iTFl5mkxwxWOBMkuzCg/gaJe7nOmjINylItaXQFMSIU9Ij8WYY28BWv6Faua//J5j8xwcQ=
X-Received: by 2002:a67:e8c3:: with SMTP id y3mr14332761vsn.94.1562003276767;
 Mon, 01 Jul 2019 10:47:56 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo564RoWpi8y2pOxoddnn0s3f3sA-fmNxpiXuxebV5TFBJA@mail.gmail.com>
 <CACDBo55GfomD4yAJ1qaOvdm8EQaD-28=etsRHb39goh+5VAeqw@mail.gmail.com>
 <20190626175131.GA17250@infradead.org> <CACDBo56fNVxVyNEGtKM+2R0X7DyZrrHMQr6Yw4NwJ6USjD5Png@mail.gmail.com>
 <c9fe4253-5698-a226-c643-32a21df8520a@arm.com>
In-Reply-To: <c9fe4253-5698-a226-c643-32a21df8520a@arm.com>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Mon, 1 Jul 2019 23:17:45 +0530
Message-ID: <CACDBo57CcYQmNrsTdMbax27nbLyeMQu4kfKZOzNczNcnde9g3Q@mail.gmail.com>
Subject: Re: DMA-API attr - DMA_ATTR_NO_KERNEL_MAPPING
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, 
	linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, 
	Michal Hocko <mhocko@kernel.org>
Content-Type: multipart/alternative; boundary="00000000000073288e058ca23af7"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000073288e058ca23af7
Content-Type: text/plain; charset="UTF-8"

On Mon, Jul 1, 2019 at 7:39 PM Robin Murphy <robin.murphy@arm.com> wrote:

> On 28/06/2019 17:29, Pankaj Suryawanshi wrote:
> > On Wed, Jun 26, 2019 at 11:21 PM Christoph Hellwig <hch@infradead.org>
> wrote:
> >>
> >> On Wed, Jun 26, 2019 at 10:12:45PM +0530, Pankaj Suryawanshi wrote:
> >>> [CC: linux kernel and Vlastimil Babka]
> >>
> >> The right list is the list for the DMA mapping subsystem, which is
> >> iommu@lists.linux-foundation.org.  I've also added that.
> >>
> >>>> I am writing driver in which I used DMA_ATTR_NO_KERNEL_MAPPING
> attribute
> >>>> for cma allocation using dma_alloc_attr(), as per kernel docs
> >>>> https://www.kernel.org/doc/Documentation/DMA-attributes.txt  buffers
> >>>> allocated with this attribute can be only passed to user space by
> calling
> >>>> dma_mmap_attrs().
> >>>>
> >>>> how can I mapped in kernel space (after dma_alloc_attr with
> >>>> DMA_ATTR_NO_KERNEL_MAPPING ) ?
> >>
> >> You can't.  And that is the whole point of that API.
> >
> > 1. We can again mapped in kernel space using dma_remap() api , because
> > when we are using  DMA_ATTR_NO_KERNEL_MAPPING for dma_alloc_attr it
> > returns the page as virtual address(in case of CMA) so we can mapped
> > it again using dma_remap().
>
> No, you really can't. A caller of dma_alloc_attrs(...,
> DMA_ATTR_NO_KERNEL_MAPPING) cannot make any assumptions about the void*
> it returns, other than that it must be handed back to dma_free_attrs()
> later. The implementation is free to ignore the flag and give back a
> virtual mapping anyway. Any driver which depends on how one particular
> implementation on one particular platform happens to behave today is,
> essentially, wrong.
>

Here is the example that i have tried in my driver.
///////////////code
snippet/////////////////////////////////////////////////////////////////////////

For CMA allocation using DMA API with DMA_ATTR_NO_KERNEL_MAPPING  :-

if(strcmp("video",info->name) == 0)
        {
        printk("Testing CMA Alloc %s\n", info->name);
        info->dma_virt = dma_alloc_attrs(pmap_device, info->size, &phys,
GFP_KERNEL,
                        DMA_ATTR_WRITE_COMBINE | DMA_ATTR_FORCE_CONTIGUOUS
| DMA_ATTR_NO_KERNEL_MAPPING);
        if (!info->dma_virt) {
                pr_err("\x1b[31m" "pmap: cma: failed to alloc %s"
"\x1b[0m\n",
                                info->name);
                return 0;
        }
                __dma_remap(info->dma_virt, info->size, PAGE_KERNEL); //
pgprot we will take from attr
                virt = page_address(info->dma_virt);
        }

For CMA free using DMA api with DMA_ATTR_NO_KERNEL_MAPPING:-

if(strcmp("video",info->name) == 0)
        {
        printk("Testing CMA Release\n");
        __dma_remap(info->dma_virt, info->size, PAGE_KERNEL);
        dma_free_attrs(pmap_device, info->size, info->dma_virt, phys,
                        DMA_ATTR_WRITE_COMBINE | DMA_ATTR_FORCE_CONTIGUOUS
| DMA_ATTR_NO_KERNEL_MAPPING);
        }

Flow of Function calls :-

1. static void *__dma_alloc() // .want_vaddr = ((attrs &
DMA_ATTR_NO_KERNEL_MAPPING) == 0)

2.cma_allocator :-
                            i.  static void *cma_allocator_alloc ()
                            ii. static void *__alloc_from_contiguous()  //
file name :- ./arch/arm/mm/dma-mapping.c
                                                                     if
(!want_vaddr)

                                                                      goto
out; // condition true for DMA_ATTR_NO_KERNEL_MAPPING

                                                                     if
(PageHighMem(page)) {
                                                                     ptr =
__dma_alloc_remap(page, size, GFP_KERNEL, prot, caller);
                                                                     if
(!ptr) {


dma_release_from_contiguous(dev, page, count);

                                                          return NULL;
                                                                      }
                                                                     } else
{

__dma_remap(page, size, prot);
                                                                    ptr =
page_address(page);
                                                                     }

                                                                   out:

                                                                  *ret_page
= page; // return  page
                                                                   return
ptr;  // nothing in ptr
                                                                  }
                            iii. struct page *dma_alloc_from_contiguous()
                            iv. cma_alloc()
3. dma_alloc () // returns
return args.want_vaddr ? addr : page; // returns page which is return by
alloc_from_contiguous().

What wrong with this if we already know page is returning dma_alloc_attr().
we can use dma_remap in our driver and free as freed in static void
__free_from_contiguous ().
Please let me know if i missing anything.

> 2. We can mapped in kernel space using vmap() as used for ion-cma
> >
> https://github.com/torvalds/linux/tree/master/drivers/staging/android/ion
> >   as used in function ion_heap_map_kernel().
> >
> > Please let me know if i am missing anything.
>
> If you want a kernel mapping, *don't* explicitly request not to have a
> kernel mapping in the first place. It's that simple.
>

Do you mean do not use dma-api ? because if i used dma-api it will give you
mapped virtual address.
or i have to use directly cma_alloc() in my driver. // if i used this
approach i need to reserved more vmalloc area.

Any help would be appreciated.

>
> Robin.
>

--00000000000073288e058ca23af7
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: base64

PGRpdiBkaXI9Imx0ciI+PGRpdiBkaXI9Imx0ciI+PGJyPjwvZGl2Pjxicj48YnI+PGRpdiBjbGFz
cz0iZ21haWxfcXVvdGUiPjxkaXYgZGlyPSJsdHIiIGNsYXNzPSJnbWFpbF9hdHRyIj5PbiBNb24s
IEp1bCAxLCAyMDE5IGF0IDc6MzkgUE0gUm9iaW4gTXVycGh5ICZsdDs8YSBocmVmPSJtYWlsdG86
cm9iaW4ubXVycGh5QGFybS5jb20iPnJvYmluLm11cnBoeUBhcm0uY29tPC9hPiZndDsgd3JvdGU6
PGJyPjwvZGl2PjxibG9ja3F1b3RlIGNsYXNzPSJnbWFpbF9xdW90ZSIgc3R5bGU9Im1hcmdpbjow
cHggMHB4IDBweCAwLjhleDtib3JkZXItbGVmdDoxcHggc29saWQgcmdiKDIwNCwyMDQsMjA0KTtw
YWRkaW5nLWxlZnQ6MWV4Ij5PbiAyOC8wNi8yMDE5IDE3OjI5LCBQYW5rYWogU3VyeWF3YW5zaGkg
d3JvdGU6PGJyPg0KJmd0OyBPbiBXZWQsIEp1biAyNiwgMjAxOSBhdCAxMToyMSBQTSBDaHJpc3Rv
cGggSGVsbHdpZyAmbHQ7PGEgaHJlZj0ibWFpbHRvOmhjaEBpbmZyYWRlYWQub3JnIiB0YXJnZXQ9
Il9ibGFuayI+aGNoQGluZnJhZGVhZC5vcmc8L2E+Jmd0OyB3cm90ZTo8YnI+DQomZ3Q7Jmd0Ozxi
cj4NCiZndDsmZ3Q7IE9uIFdlZCwgSnVuIDI2LCAyMDE5IGF0IDEwOjEyOjQ1UE0gKzA1MzAsIFBh
bmthaiBTdXJ5YXdhbnNoaSB3cm90ZTo8YnI+DQomZ3Q7Jmd0OyZndDsgW0NDOiBsaW51eCBrZXJu
ZWwgYW5kIFZsYXN0aW1pbCBCYWJrYV08YnI+DQomZ3Q7Jmd0Ozxicj4NCiZndDsmZ3Q7IFRoZSBy
aWdodCBsaXN0IGlzIHRoZSBsaXN0IGZvciB0aGUgRE1BIG1hcHBpbmcgc3Vic3lzdGVtLCB3aGlj
aCBpczxicj4NCiZndDsmZ3Q7IDxhIGhyZWY9Im1haWx0bzppb21tdUBsaXN0cy5saW51eC1mb3Vu
ZGF0aW9uLm9yZyIgdGFyZ2V0PSJfYmxhbmsiPmlvbW11QGxpc3RzLmxpbnV4LWZvdW5kYXRpb24u
b3JnPC9hPi7CoCBJJiMzOTt2ZSBhbHNvIGFkZGVkIHRoYXQuPGJyPg0KJmd0OyZndDs8YnI+DQom
Z3Q7Jmd0OyZndDsmZ3Q7IEkgYW0gd3JpdGluZyBkcml2ZXIgaW4gd2hpY2ggSSB1c2VkIERNQV9B
VFRSX05PX0tFUk5FTF9NQVBQSU5HIGF0dHJpYnV0ZTxicj4NCiZndDsmZ3Q7Jmd0OyZndDsgZm9y
IGNtYSBhbGxvY2F0aW9uIHVzaW5nIGRtYV9hbGxvY19hdHRyKCksIGFzIHBlciBrZXJuZWwgZG9j
czxicj4NCiZndDsmZ3Q7Jmd0OyZndDsgPGEgaHJlZj0iaHR0cHM6Ly93d3cua2VybmVsLm9yZy9k
b2MvRG9jdW1lbnRhdGlvbi9ETUEtYXR0cmlidXRlcy50eHQiIHJlbD0ibm9yZWZlcnJlciIgdGFy
Z2V0PSJfYmxhbmsiPmh0dHBzOi8vd3d3Lmtlcm5lbC5vcmcvZG9jL0RvY3VtZW50YXRpb24vRE1B
LWF0dHJpYnV0ZXMudHh0PC9hPsKgIGJ1ZmZlcnM8YnI+DQomZ3Q7Jmd0OyZndDsmZ3Q7IGFsbG9j
YXRlZCB3aXRoIHRoaXMgYXR0cmlidXRlIGNhbiBiZSBvbmx5IHBhc3NlZCB0byB1c2VyIHNwYWNl
IGJ5IGNhbGxpbmc8YnI+DQomZ3Q7Jmd0OyZndDsmZ3Q7IGRtYV9tbWFwX2F0dHJzKCkuPGJyPg0K
Jmd0OyZndDsmZ3Q7Jmd0Ozxicj4NCiZndDsmZ3Q7Jmd0OyZndDsgaG93IGNhbiBJIG1hcHBlZCBp
biBrZXJuZWwgc3BhY2UgKGFmdGVyIGRtYV9hbGxvY19hdHRyIHdpdGg8YnI+DQomZ3Q7Jmd0OyZn
dDsmZ3Q7IERNQV9BVFRSX05PX0tFUk5FTF9NQVBQSU5HICkgPzxicj4NCiZndDsmZ3Q7PGJyPg0K
Jmd0OyZndDsgWW91IGNhbiYjMzk7dC7CoCBBbmQgdGhhdCBpcyB0aGUgd2hvbGUgcG9pbnQgb2Yg
dGhhdCBBUEkuPGJyPg0KJmd0OyA8YnI+DQomZ3Q7IDEuIFdlIGNhbiBhZ2FpbiBtYXBwZWQgaW4g
a2VybmVsIHNwYWNlIHVzaW5nIGRtYV9yZW1hcCgpIGFwaSAsIGJlY2F1c2U8YnI+DQomZ3Q7IHdo
ZW4gd2UgYXJlIHVzaW5nwqAgRE1BX0FUVFJfTk9fS0VSTkVMX01BUFBJTkcgZm9yIGRtYV9hbGxv
Y19hdHRyIGl0PGJyPg0KJmd0OyByZXR1cm5zIHRoZSBwYWdlIGFzIHZpcnR1YWwgYWRkcmVzcyhp
biBjYXNlIG9mIENNQSkgc28gd2UgY2FuIG1hcHBlZDxicj4NCiZndDsgaXQgYWdhaW4gdXNpbmcg
ZG1hX3JlbWFwKCkuPGJyPg0KPGJyPg0KTm8sIHlvdSByZWFsbHkgY2FuJiMzOTt0LiBBIGNhbGxl
ciBvZiBkbWFfYWxsb2NfYXR0cnMoLi4uLCA8YnI+DQpETUFfQVRUUl9OT19LRVJORUxfTUFQUElO
RykgY2Fubm90IG1ha2UgYW55IGFzc3VtcHRpb25zIGFib3V0IHRoZSB2b2lkKiA8YnI+DQppdCBy
ZXR1cm5zLCBvdGhlciB0aGFuIHRoYXQgaXQgbXVzdCBiZSBoYW5kZWQgYmFjayB0byBkbWFfZnJl
ZV9hdHRycygpIDxicj4NCmxhdGVyLiBUaGUgaW1wbGVtZW50YXRpb24gaXMgZnJlZSB0byBpZ25v
cmUgdGhlIGZsYWcgYW5kIGdpdmUgYmFjayBhIDxicj4NCnZpcnR1YWwgbWFwcGluZyBhbnl3YXku
IEFueSBkcml2ZXIgd2hpY2ggZGVwZW5kcyBvbiBob3cgb25lIHBhcnRpY3VsYXIgPGJyPg0KaW1w
bGVtZW50YXRpb24gb24gb25lIHBhcnRpY3VsYXIgcGxhdGZvcm0gaGFwcGVucyB0byBiZWhhdmUg
dG9kYXkgaXMsIDxicj4NCmVzc2VudGlhbGx5LCB3cm9uZy48YnI+PC9ibG9ja3F1b3RlPjxkaXY+
PGJyPjwvZGl2PjxkaXY+SGVyZSBpcyB0aGUgZXhhbXBsZSB0aGF0IGkgaGF2ZSB0cmllZCBpbiBt
eSBkcml2ZXIuPGJyPjwvZGl2PjxkaXY+Ly8vLy8vLy8vLy8vLy8vY29kZSBzbmlwcGV0Ly8vLy8v
Ly8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8v
Ly8vLy8vLy8vLzwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+Rm9yIENNQSBhbGxvY2F0aW9uIHVz
aW5nIERNQSBBUEkgd2l0aCA8Zm9udCBzaXplPSIyIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjEx
cHQiPkRNQV9BVFRSX05PX0tFUk5FTF9NQVBQSU5HPC9zcGFuPjwvZm9udD7CoCA6LTwvZGl2Pjxk
aXY+PGJyPjwvZGl2PjxkaXY+PGZvbnQgc2l6ZT0iMiI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZTox
MXB0Ij4gaWYoc3RyY21wKCZxdW90O3ZpZGVvJnF1b3Q7LGluZm8tJmd0O25hbWUpID09IDApPGJy
Pg0KDQrCoMKgwqDCoMKgwqDCoCB7PGJyPg0KDQrCoMKgwqDCoMKgwqDCoCBwcmludGsoJnF1b3Q7
VGVzdGluZyBDTUEgQWxsb2MgJXNcbiZxdW90OywgaW5mby0mZ3Q7bmFtZSk7PGJyPg0KDQrCoMKg
wqDCoMKgwqDCoCBpbmZvLSZndDtkbWFfdmlydCA9IGRtYV9hbGxvY19hdHRycyhwbWFwX2Rldmlj
ZSwgaW5mby0mZ3Q7c2l6ZSwgJmFtcDtwaHlzLCBHRlBfS0VSTkVMLDxicj4NCg0KwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCBETUFfQVRUUl9XUklURV9DT01C
SU5FIHwgRE1BX0FUVFJfRk9SQ0VfQ09OVElHVU9VUyB8IERNQV9BVFRSX05PX0tFUk5FTF9NQVBQ
SU5HKTs8YnI+DQoNCsKgwqDCoMKgwqDCoMKgIGlmICghaW5mby0mZ3Q7ZG1hX3ZpcnQpIHs8YnI+
DQoNCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCBwcl9lcnIoJnF1b3Q7XHgxYlszMW0m
cXVvdDsgJnF1b3Q7cG1hcDogY21hOiBmYWlsZWQgdG8gYWxsb2MgJXMmcXVvdDsgJnF1b3Q7XHgx
YlswbVxuJnF1b3Q7LDxicj4NCg0KwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAgaW5mby0mZ3Q7bmFtZSk7PGJyPg0KDQrCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAgcmV0dXJuIDA7PGJyPg0KDQrCoMKgwqDCoMKgwqDCoCB9
PGJyPg0KDQrCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAgX19kbWFfcmVtYXAoaW5mby0m
Z3Q7ZG1hX3ZpcnQsIGluZm8tJmd0O3NpemUsIFBBR0VfS0VSTkVMKTsgLy8gcGdwcm90IHdlIHdp
bGwgdGFrZSBmcm9tIGF0dHIgPGJyPg0KDQrCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAg
dmlydCA9IHBhZ2VfYWRkcmVzcyhpbmZvLSZndDtkbWFfdmlydCk7PGJyPg0KDQrCoMKgwqDCoMKg
wqDCoCB9PC9zcGFuPjwvZm9udD48L2Rpdj48ZGl2Pjxmb250IHNpemU9IjIiPjxzcGFuIHN0eWxl
PSJmb250LXNpemU6MTFwdCI+PGJyPjwvc3Bhbj48L2ZvbnQ+PC9kaXY+PGRpdj48Zm9udCBzaXpl
PSIyIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExcHQiPkZvciBDTUEgZnJlZSB1c2luZyBETUEg
YXBpIHdpdGggPGZvbnQgc2l6ZT0iMiI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMXB0Ij5ETUFf
QVRUUl9OT19LRVJORUxfTUFQUElORzotPC9zcGFuPjwvZm9udD48L3NwYW4+PC9mb250PjwvZGl2
PjxkaXY+PGZvbnQgc2l6ZT0iMiI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMXB0Ij48Zm9udCBz
aXplPSIyIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExcHQiPjxicj48L3NwYW4+PC9mb250Pjwv
c3Bhbj48L2ZvbnQ+PC9kaXY+PGRpdj48Zm9udCBzaXplPSIyIj48c3BhbiBzdHlsZT0iZm9udC1z
aXplOjExcHQiPjxmb250IHNpemU9IjIiPjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTFwdCI+PGZv
bnQgc2l6ZT0iMiI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMXB0Ij4gaWYoc3RyY21wKCZxdW90
O3ZpZGVvJnF1b3Q7LGluZm8tJmd0O25hbWUpID09IDApPGJyPg0KDQrCoMKgwqDCoMKgwqDCoCB7
PGJyPg0KDQrCoMKgwqDCoMKgwqDCoCBwcmludGsoJnF1b3Q7VGVzdGluZyBDTUEgUmVsZWFzZVxu
JnF1b3Q7KTs8L3NwYW4+PC9mb250Pjwvc3Bhbj48L2ZvbnQ+PC9zcGFuPjwvZm9udD48L2Rpdj48
ZGl2Pjxmb250IHNpemU9IjIiPjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTFwdCI+PGZvbnQgc2l6
ZT0iMiI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMXB0Ij48Zm9udCBzaXplPSIyIj48c3BhbiBz
dHlsZT0iZm9udC1zaXplOjExcHQiPsKgwqDCoMKgwqDCoMKgIDxmb250IHNpemU9IjIiPjxzcGFu
IHN0eWxlPSJmb250LXNpemU6MTFwdCI+X19kbWFfcmVtYXAoaW5mby0mZ3Q7ZG1hX3ZpcnQsIGlu
Zm8tJmd0O3NpemUsIFBBR0VfS0VSTkVMKTs8YnI+DQoNCjwvc3Bhbj48L2ZvbnQ+wqDCoMKgwqDC
oMKgwqAgZG1hX2ZyZWVfYXR0cnMocG1hcF9kZXZpY2UsIGluZm8tJmd0O3NpemUsIGluZm8tJmd0
O2RtYV92aXJ0LCBwaHlzLDxicj4NCg0KwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoCBETUFfQVRUUl9XUklURV9DT01CSU5FIHwgRE1BX0FUVFJfRk9SQ0VfQ09O
VElHVU9VUyB8IERNQV9BVFRSX05PX0tFUk5FTF9NQVBQSU5HKTs8YnI+DQoNCsKgwqDCoMKgwqDC
oMKgIH08YnI+DQoNCjwvc3Bhbj48L2ZvbnQ+PC9zcGFuPjwvZm9udD48L3NwYW4+PC9mb250PiA8
L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2PkZsb3cgb2YgRnVuY3Rpb24gY2FsbHMgOi08L2Rpdj48
ZGl2Pjxicj48L2Rpdj48ZGl2Pjxmb250IHNpemU9IjIiPjxzcGFuIHN0eWxlPSJmb250LXNpemU6
MTFwdCI+MS4gc3RhdGljIHZvaWQgKl9fZG1hX2FsbG9jKCkgLy8gLndhbnRfdmFkZHIgPSAoKGF0
dHJzICZhbXA7IERNQV9BVFRSX05PX0tFUk5FTF9NQVBQSU5HKSA9PSAwKTwvc3Bhbj48L2ZvbnQ+
PC9kaXY+PGRpdj48Zm9udCBzaXplPSIyIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExcHQiPjxi
cj48L3NwYW4+PC9mb250PjwvZGl2PjxkaXY+PGZvbnQgc2l6ZT0iMiI+PHNwYW4gc3R5bGU9ImZv
bnQtc2l6ZToxMXB0Ij4yLmNtYV9hbGxvY2F0b3IgOi08L3NwYW4+PC9mb250PjwvZGl2PjxkaXY+
PGZvbnQgc2l6ZT0iMiI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMXB0Ij7CoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAgaS7CoCBzdGF0aWMgdm9p
ZCAqY21hX2FsbG9jYXRvcl9hbGxvYyAoKTwvc3Bhbj48L2ZvbnQ+PC9kaXY+PGRpdj48Zm9udCBz
aXplPSIyIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExcHQiPsKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCBpaS4gc3RhdGljIHZvaWQgKl9fYWxs
b2NfZnJvbV9jb250aWd1b3VzKCnCoCAvLyBmaWxlIG5hbWUgOi0gLi9hcmNoL2FybS9tbS9kbWEt
bWFwcGluZy5jPC9zcGFuPjwvZm9udD48L2Rpdj48ZGl2Pjxmb250IHNpemU9IjIiPjxzcGFuIHN0
eWxlPSJmb250LXNpemU6MTFwdCI+wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCBpZiAoIXdhbnRfdmFk
ZHIpPGJyPsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCBnb3Rv
IG91dDsgLy8gY29uZGl0aW9uIHRydWUgZm9yIDxmb250IHNpemU9IjIiPjxzcGFuIHN0eWxlPSJm
b250LXNpemU6MTFwdCI+PGZvbnQgc2l6ZT0iMiI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMXB0
Ij48Zm9udCBzaXplPSIyIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExcHQiPkRNQV9BVFRSX05P
X0tFUk5FTF9NQVBQSU5HPC9zcGFuPjwvZm9udD48L3NwYW4+PC9mb250Pjwvc3Bhbj48L2ZvbnQ+
PGJyPjxicj7CoCDCoCDCoCDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgIGlmIChQYWdlSGlnaE1lbShwYWdlKSkgezxicj7C
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqAgcHRyID0gX19kbWFfYWxsb2NfcmVtYXAocGFnZSwgc2l6ZSwgR0ZQX0tF
Uk5FTCwgcHJvdCwgY2FsbGVyKTs8YnI+wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgIGlmICghcHRyKSB7PGJyPsKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCBkbWFfcmVsZWFzZV9mcm9tX2NvbnRpZ3Vv
dXMoZGV2LCBwYWdlLCBjb3VudCk7PGJyPsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oCByZXR1cm4gTlVMTDs8YnI+wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAgfTxicj7CoCDCoCDCoCDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgIH0gZWxzZSB7IDxicj7CoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoMKgIF9fZG1hX3JlbWFwKHBhZ2UsIHNpemUsIHByb3QpOyA8YnI+wqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCBw
dHIgPSBwYWdlX2FkZHJlc3MocGFnZSk7PGJyPsKgIMKgIMKgIMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAgfTxicj48YnI+
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgIG91dDogwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqA8YnI+wqAgwqAgwqAgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCAqcmV0X3BhZ2UgPSBwYWdlOyAvLyByZXR1cm7CoCBw
YWdlIDxicj7CoCDCoCDCoCDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAgcmV0dXJuIHB0cjvCoCAvLyBub3RoaW5nIGluIHB0cjxi
cj7CoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgIH08YnI+PC9zcGFuPjwvZm9udD48L2Rpdj48ZGl2Pjxmb250IHNp
emU9IjIiPjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTFwdCI+wqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgIGlpaS4gc3RydWN0IHBhZ2UgKmRtYV9h
bGxvY19mcm9tX2NvbnRpZ3VvdXMoKTwvc3Bhbj48L2ZvbnQ+PC9kaXY+PGRpdj48Zm9udCBzaXpl
PSIyIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExcHQiPsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCBpdi4gY21hX2FsbG9jKCk8L3NwYW4+PC9m
b250PjwvZGl2PjxkaXY+PGZvbnQgc2l6ZT0iMiI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMXB0
Ij4zLiBkbWFfYWxsb2MgKCkgLy8gcmV0dXJucyA8YnI+PC9zcGFuPjwvZm9udD48L2Rpdj48ZGl2
Pjxmb250IHNpemU9IjIiPjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTFwdCI+cmV0dXJuIGFyZ3Mu
d2FudF92YWRkciA/IGFkZHIgOiBwYWdlOyAvLyByZXR1cm5zIHBhZ2Ugd2hpY2ggaXMgcmV0dXJu
IGJ5IGFsbG9jX2Zyb21fY29udGlndW91cygpLjwvc3Bhbj48L2ZvbnQ+PC9kaXY+PGRpdj48Zm9u
dCBzaXplPSIyIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExcHQiPjxicj48L3NwYW4+PC9mb250
PjwvZGl2PjxkaXY+PGZvbnQgc2l6ZT0iMiI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMXB0Ij5X
aGF0IHdyb25nIHdpdGggdGhpcyBpZiB3ZSBhbHJlYWR5IGtub3cgcGFnZSBpcyByZXR1cm5pbmcg
ZG1hX2FsbG9jX2F0dHIoKS48L3NwYW4+PC9mb250PjwvZGl2PjxkaXY+PGZvbnQgc2l6ZT0iMiI+
PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMXB0Ij53ZSBjYW4gdXNlIGRtYV9yZW1hcCBpbiBvdXIg
ZHJpdmVyIGFuZCBmcmVlIGFzIGZyZWVkIGluIHN0YXRpYyB2b2lkIF9fZnJlZV9mcm9tX2NvbnRp
Z3VvdXMgKCkuPC9zcGFuPjwvZm9udD48L2Rpdj48ZGl2Pjxmb250IHNpemU9IjIiPjxzcGFuIHN0
eWxlPSJmb250LXNpemU6MTFwdCI+UGxlYXNlIGxldCBtZSBrbm93IGlmIGkgbWlzc2luZyBhbnl0
aGluZy48YnI+PC9zcGFuPjwvZm9udD48L2Rpdj48ZGl2PiA8YnI+PC9kaXY+PGJsb2NrcXVvdGUg
Y2xhc3M9ImdtYWlsX3F1b3RlIiBzdHlsZT0ibWFyZ2luOjBweCAwcHggMHB4IDAuOGV4O2JvcmRl
ci1sZWZ0OjFweCBzb2xpZCByZ2IoMjA0LDIwNCwyMDQpO3BhZGRpbmctbGVmdDoxZXgiPg0KJmd0
OyAyLiBXZSBjYW4gbWFwcGVkIGluIGtlcm5lbCBzcGFjZSB1c2luZyB2bWFwKCkgYXMgdXNlZCBm
b3IgaW9uLWNtYTxicj4NCiZndDsgPGEgaHJlZj0iaHR0cHM6Ly9naXRodWIuY29tL3RvcnZhbGRz
L2xpbnV4L3RyZWUvbWFzdGVyL2RyaXZlcnMvc3RhZ2luZy9hbmRyb2lkL2lvbiIgcmVsPSJub3Jl
ZmVycmVyIiB0YXJnZXQ9Il9ibGFuayI+aHR0cHM6Ly9naXRodWIuY29tL3RvcnZhbGRzL2xpbnV4
L3RyZWUvbWFzdGVyL2RyaXZlcnMvc3RhZ2luZy9hbmRyb2lkL2lvbjwvYT48YnI+DQomZ3Q7wqAg
wqBhcyB1c2VkIGluIGZ1bmN0aW9uIGlvbl9oZWFwX21hcF9rZXJuZWwoKS48YnI+DQomZ3Q7IDxi
cj4NCiZndDsgUGxlYXNlIGxldCBtZSBrbm93IGlmIGkgYW0gbWlzc2luZyBhbnl0aGluZy48YnI+
DQo8YnI+DQpJZiB5b3Ugd2FudCBhIGtlcm5lbCBtYXBwaW5nLCAqZG9uJiMzOTt0KiBleHBsaWNp
dGx5IHJlcXVlc3Qgbm90IHRvIGhhdmUgYSA8YnI+DQprZXJuZWwgbWFwcGluZyBpbiB0aGUgZmly
c3QgcGxhY2UuIEl0JiMzOTtzIHRoYXQgc2ltcGxlLjxicj48L2Jsb2NrcXVvdGU+PGRpdj48YnI+
PC9kaXY+PGRpdj5EbyB5b3UgbWVhbiBkbyBub3QgdXNlIGRtYS1hcGkgPyBiZWNhdXNlIGlmIGkg
dXNlZCBkbWEtYXBpIGl0IHdpbGwgZ2l2ZSB5b3UgbWFwcGVkIHZpcnR1YWwgYWRkcmVzcy48L2Rp
dj48ZGl2Pm9yIGkgaGF2ZSB0byB1c2UgZGlyZWN0bHkgY21hX2FsbG9jKCkgaW4gbXkgZHJpdmVy
LiAvLyBpZiBpIHVzZWQgdGhpcyBhcHByb2FjaCBpIG5lZWQgdG8gcmVzZXJ2ZWQgbW9yZSB2bWFs
bG9jIGFyZWEuPC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5BbnkgaGVscCB3b3VsZCBiZSBhcHBy
ZWNpYXRlZC48YnI+PC9kaXY+PGJsb2NrcXVvdGUgY2xhc3M9ImdtYWlsX3F1b3RlIiBzdHlsZT0i
bWFyZ2luOjBweCAwcHggMHB4IDAuOGV4O2JvcmRlci1sZWZ0OjFweCBzb2xpZCByZ2IoMjA0LDIw
NCwyMDQpO3BhZGRpbmctbGVmdDoxZXgiPg0KPGJyPg0KUm9iaW4uPGJyPg0KPC9ibG9ja3F1b3Rl
PjwvZGl2PjwvZGl2Pg0K
--00000000000073288e058ca23af7--

