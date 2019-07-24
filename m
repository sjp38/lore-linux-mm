Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10A0AC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:19:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEAE421849
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:19:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="MMFhBM5P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEAE421849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 535AF6B000D; Wed, 24 Jul 2019 16:19:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E6978E0003; Wed, 24 Jul 2019 16:19:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D5BD8E0002; Wed, 24 Jul 2019 16:19:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E65226B000D
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:19:02 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id e8so22790230wrw.15
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:19:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=uCyHvJVkRZumARLm11LdjYU2wgRDrjk7Xpd2Pm/4CUM=;
        b=QA5s2jH/4+T6Zd7AGdmtKXNTwR94y+CH0MgoEMamC54li4o4R8h+IMAYrMHxCaEj1Z
         Qic4v6kmAo0YIeqvBnMDeJP6cV74QgQZPF1ksVi9Z9h30yHIdLpAg8KKOvkdWrEKiJSk
         OQ6RxoU/lQbqS2hGdSGIv3S0M7YQ18T/TbQTCt1xs9xZkLTVSIJUqEYMoMsDAZVfAaw1
         Ur76LjKDBf/7LactaAnsVMJgHnRM+3O04KjFZhHE4ezf7dNUjdylQigVM7PtAbsRg68A
         DFKQi7YyT/BC1S7IQumF+DpRaV0xPPdFRZjPBRpUTxFC2ldYFAiAXiTihpSzuwaV1RUY
         Bh2Q==
X-Gm-Message-State: APjAAAXtO1Z6cakGeQOgZwT+AU1SsdVCLYcf49xBX/fNs0G6T2ZKIRpj
	O40CQjsYwzsCSv7njKqrMwAU00HmgP/Et/jkDUe0KJmk2FnavRzd3CI7vQzEXuF/JdzdXVeESNv
	nqG/mcAf3CgSh6TeWTEJfQpcK9zDCK26c2n79DLYzNXKSB85Pl9dQiGlzkvEFgjF/dQ==
X-Received: by 2002:a05:600c:114f:: with SMTP id z15mr74878877wmz.131.1563999542407;
        Wed, 24 Jul 2019 13:19:02 -0700 (PDT)
X-Received: by 2002:a05:600c:114f:: with SMTP id z15mr74878852wmz.131.1563999541487;
        Wed, 24 Jul 2019 13:19:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563999541; cv=none;
        d=google.com; s=arc-20160816;
        b=pdgrYFFzLufMCPLzqJJlMafC+79edjlF1mSR+72OV3yTTusOxdRxbTvW7S20IvAyJQ
         UElCLEnC8NRgN3UViskcMbixdlBC3nMk3sKD115LMpAKuu2gmW/CvWkYquDtttty8SAm
         DTTjjurqIReO7A9v46inp2KeZ72Swyw5hfwVRyu2HSgQgdHfOq9mm/N7xXma/ogTUl9M
         zD11qqxFlYnB8wUWdOo2WimOx2OUqePx6d9QFS4S1lH6gIBu5pz4BWt2+vvmA0KyBtkt
         qN02jJ1NkuwBkY5/Lw5Y8rXvmrlt2NFtWmAxV8bprx+qiUKvMrYHYlR6Xxpc7gNrtfBX
         E3uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=uCyHvJVkRZumARLm11LdjYU2wgRDrjk7Xpd2Pm/4CUM=;
        b=gW3lNVASUzatC3vjJr+9TE0zelIhDlm+8d2lPLTiBevkq2ahmJvnPoT+48zvpI9Ik0
         wDS0VlTKw/tlPDUNJJBQAN/NpcXsr84VHt576ldkrax684E1s0G6fAUdMsovBbQxWJJg
         LeoCAMf7mbAkajZs38rLCiWfrkxMZpG+WtXYK+z89EtLFRzTZsLMYglrUmgyRNuiEEbm
         iA81xMeXz3DJk2r75lrfXvN2XKZNo1XPuwLGgYvXmwH0iF/zm9CSHzqjiUnvSAZ8CHj7
         CAq5dewSCGl5LAUnPXEC3UpSGsQxHhtzq629lY3YnhvvXTXvrlFYExLZ6PLcuMdMTCEa
         OdiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=MMFhBM5P;
       spf=pass (google.com: domain of john.stultz@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.stultz@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b131sor26633510wmg.27.2019.07.24.13.19.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 13:19:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.stultz@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=MMFhBM5P;
       spf=pass (google.com: domain of john.stultz@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.stultz@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uCyHvJVkRZumARLm11LdjYU2wgRDrjk7Xpd2Pm/4CUM=;
        b=MMFhBM5Pt5Bu3rS3QrPnpjTF3l1IJpk1QmQmjGaPFr5PvBQwNLRpzX+5/gr6aNSdCZ
         vvEAbsdi+zHpVh40gCBAf96lB7k/+P16YkMaax7BCa3VCjo20+sJY/pvmfXxP7jDAlzc
         AWhRW16LHsMMAlx9kYR+te6xxCZz9DYQkUb9cIX+Eig3VWNu65JSMjOmny0yf4uDVhLR
         DU2YrYMoOP8itf1qPvplk8lYCeENSprEH141M2gm8iDVRP/7Xr9nbG+sdjrPUHqfrU+6
         3k8U622iHi2XDVcsN54oFxmrEi6aL45ohjJEk/gDD0CN++uyO007eaD6Cs6hCiJ9dklQ
         2oNg==
X-Google-Smtp-Source: APXvYqzne6wuqU7LConXTs0S6lFIYeqa69IIJz0V4W6ONH7N7hOznm+a/z9PghQX0bLW04gOZC7ziRyCGieZewzto2s=
X-Received: by 2002:a1c:d10c:: with SMTP id i12mr75821649wmg.152.1563999540296;
 Wed, 24 Jul 2019 13:19:00 -0700 (PDT)
MIME-Version: 1.0
References: <3b922aa4-c6d4-e4a4-766d-f324ff77f7b5@linux.com> <40f8b7d8-fafa-ad99-34fb-9c63e34917e2@redhat.com>
In-Reply-To: <40f8b7d8-fafa-ad99-34fb-9c63e34917e2@redhat.com>
From: John Stultz <john.stultz@linaro.org>
Date: Wed, 24 Jul 2019 13:18:47 -0700
Message-ID: <CALAqxLU199ATrMFa2ARmHOZ3K6ZnOuDLSAqNrTfwOWJaYiW7Yg@mail.gmail.com>
Subject: Re: Limits for ION Memory Allocator
To: Laura Abbott <labbott@redhat.com>
Cc: alex.popov@linux.com, Sumit Semwal <sumit.semwal@linaro.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Christian Brauner <christian@brauner.io>, 
	Riley Andrews <riandrews@android.com>, driverdevel <devel@driverdev.osuosl.org>, 
	"moderated list:DMA BUFFER SHARING FRAMEWORK" <linaro-mm-sig@lists.linaro.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, 
	dri-devel <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, 
	Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, 
	Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, 
	Linux-MM <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, syzkaller <syzkaller@googlegroups.com>, 
	Hridya Valsaraju <hridya@google.com>, Alistair Delva <adelva@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 12:36 PM Laura Abbott <labbott@redhat.com> wrote:
>
> On 7/17/19 12:31 PM, Alexander Popov wrote:
> > Hello!
> >
> > The syzkaller [1] has a trouble with fuzzing the Linux kernel with ION Memory
> > Allocator.
> >
> > Syzkaller uses several methods [2] to limit memory consumption of the userspace
> > processes calling the syscalls for testing the kernel:
> >   - setrlimit(),
> >   - cgroups,
> >   - various sysctl.
> > But these methods don't work for ION Memory Allocator, so any userspace process
> > that has access to /dev/ion can bring the system to the out-of-memory state.
> >
> > An example of a program doing that:
> >
> >
> > #include <sys/types.h>
> > #include <sys/stat.h>
> > #include <fcntl.h>
> > #include <stdio.h>
> > #include <linux/types.h>
> > #include <sys/ioctl.h>
> >
> > #define ION_IOC_MAGIC         'I'
> > #define ION_IOC_ALLOC         _IOWR(ION_IOC_MAGIC, 0, \
> >                                     struct ion_allocation_data)
> >
> > struct ion_allocation_data {
> >       __u64 len;
> >       __u32 heap_id_mask;
> >       __u32 flags;
> >       __u32 fd;
> >       __u32 unused;
> > };
> >
> > int main(void)
> > {
> >       unsigned long i = 0;
> >       int fd = -1;
> >       struct ion_allocation_data data = {
> >               .len = 0x13f65d8c,
> >               .heap_id_mask = 1,
> >               .flags = 0,
> >               .fd = -1,
> >               .unused = 0
> >       };
> >
> >       fd = open("/dev/ion", 0);
> >       if (fd == -1) {
> >               perror("[-] open /dev/ion");
> >               return 1;
> >       }
> >
> >       while (1) {
> >               printf("iter %lu\n", i);
> >               ioctl(fd, ION_IOC_ALLOC, &data);
> >               i++;
> >       }
> >
> >       return 0;
> > }
> >
> >
> > I looked through the code of ion_alloc() and didn't find any limit checks.
> > Is it currently possible to limit ION kernel allocations for some process?
> >
> > If not, is it a right idea to do that?
> > Thanks!
> >
>
> Yes, I do think that's the right approach. We're working on moving Ion
> out of staging and this is something I mentioned to John Stultz. I don't
> think we've thought too hard about how to do the actual limiting so
> suggestions are welcome.

In part the dmabuf heaps allow for separate heap devices, so we can
have finer grained permissions to the specific heaps.  But that
doesn't provide any controls on how much memory one process could
allocate using the device if it has permission.

I suspect the same issue is present with any of the dmabuf exporters
(gpu/display drivers, etc), so this is less of an ION/dmabuf heap
issue and more of a dmabuf core accounting issue.

Another practical complication is that with Android these days, I
believe the gralloc code lives in the HIDL-ized
android.hardware.graphics.allocator@2.0-service HAL, which does the
buffer allocations on behalf of requests sent over the binder IPC
interface. So with all dma-buf allocations effectively going through
that single process, I'm not sure we would want to put per-process
limits on the allocator.  Instead, I suspect we'd want the memory
covered by the dmabuf to be accounted against processes that have the
dmabuf fd still open?

I know Android has some logic with their memtrack HAL to I believe try
to do accounting of gpu memory against various processes, but I've not
looked at that in detail recently.

Todd/Joel: Any input here?

thanks
-john

