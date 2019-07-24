Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DD6DC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:24:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 020A8214AF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:24:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="exDKJ9fg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 020A8214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9780A8E0003; Wed, 24 Jul 2019 16:24:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 928308E0002; Wed, 24 Jul 2019 16:24:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C8CC8E0003; Wed, 24 Jul 2019 16:24:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DEB68E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:24:04 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b14so22878762wrn.8
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:24:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QhT2aDY6DDwFo4u6pSSbFcjckneqY/fJmJSPh2en2QU=;
        b=ePLqV0J/vAe+CROG374WMNpepFw1ExjKjPvzIR0vkZiWIU52srzzikGUtv64v6qDIy
         XzVInYibu1uFlAw5aEEaDs8eGOLojcZm1jgPr7tff455Ccfg+QJEFzq8lMmUXf+jrNe9
         JM2SSGBWl3nmkIbprB0DqIUJStL0jmfCAKf4vh4QAJ28jEnnPXarxhjzstJXxxxa+wBq
         GT4xV1pLTyc1EYNBe6OXW9OjFNunBmzpi5cMyk26itBfK+EF8w76ILEPs+mI79pPY/7o
         vpRYpXTHakZ/NXRr/vcxNEk+Le2nTlI4FY3rJ+J2LbXL/MXeK3EbmojJauLuMnhaNZmT
         cA+w==
X-Gm-Message-State: APjAAAVi0aqhT62vk4JBYESraY7pjPGacaMw2kS5zv2u6H0Nmk8mwxYN
	5BRl2O+4E4OReq71uMervkhJNgX9eppqvts6mSm/7ulMW8rWQ6aRZqCyfdv8oyyO3jXIjeM3C4R
	BDyiGOkm4L9tqsn8/Os3uGk8MT6USJN++m2O7kKhzQx4xkpX1I/bRzGhBsStNT4SXEQ==
X-Received: by 2002:a1c:dc07:: with SMTP id t7mr78698008wmg.164.1563999843718;
        Wed, 24 Jul 2019 13:24:03 -0700 (PDT)
X-Received: by 2002:a1c:dc07:: with SMTP id t7mr78697971wmg.164.1563999842984;
        Wed, 24 Jul 2019 13:24:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563999842; cv=none;
        d=google.com; s=arc-20160816;
        b=xMNHMVGJKj6GR3lrLBDFI8Lx+sdneHisvOoaitp+vxZkVwd3Rk3hbXTZwa/0kNGzUI
         cabRY6UeWAlG8EZMxOS1xNC5BfJf1fJF6YGIdYCZq+9ZmIcH+eBT2IpZOxwSCLfc0zRP
         bu0ODntIGVmqq3ZK/ep/R4Y7OjZAdjOB9yvCvi6ydOaAGnIdc37VcD2m8BY50LtVRizi
         lMThH5lWIsGiwEdCmHEqD4K2JHT2ty8+sB3HjSra/Ze+I0SXhkL8Ii7iBJfKkSMjgYoh
         U1P/CAcl6k9tGVCQ4Cc7Yi+N8WzRo2uenzCKfn6Mceymo80PqchVI9RkpGVfF4VbXsUa
         9WQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QhT2aDY6DDwFo4u6pSSbFcjckneqY/fJmJSPh2en2QU=;
        b=wb3VWbgjhsYuQeysUl1H++nIpRAhhs7YfThTpgkByw/sGfhcfdYouy3fs+NMCgmJN8
         G+7LH5+AsVVLxpTY5DOEwaVcHmMcro+5iltK28D9Q4wB8ExiHNyrwjtKT5SFj0RChILE
         MQYArpbn4KvpwGP4Pi7WZ/KCzv6C2ywIzW8KyQiNithE++4V+Ufdwot66UgAsF+4/APi
         O9BfKvUrBPrPWHmVBxeGkK7pSGra0LCx6F0BhUAph3mL1JIUtOn5FPCaXMFCoFldElsb
         0lxYCXEHvP802zh3g6QFcDXlrEop5zWYkXTK7jEDa5pw8JPTWkR2bgsCDpnxiNAFdNh4
         WvWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=exDKJ9fg;
       spf=pass (google.com: domain of john.stultz@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.stultz@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor26472146wmj.22.2019.07.24.13.24.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 13:24:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.stultz@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=exDKJ9fg;
       spf=pass (google.com: domain of john.stultz@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.stultz@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QhT2aDY6DDwFo4u6pSSbFcjckneqY/fJmJSPh2en2QU=;
        b=exDKJ9fgAtICWDsB/RyvdCl1jI5YfgCIMwTNcxzkx1dyGll/JyL2AkvfnRrYbEirOB
         SEerS90nbZ0Y7uMtaafsNIrKrn2E8fDeOQgPH6N7PGG/abR8nOS6fvcaIr90v+MoUQKL
         Ya6XED0C/nS/Tu4DavDXSBDkL98MKY8aQ7cX7xm2OvAUaFe02AX21Q5ZVMnonR86zf17
         jiYfPhij00tvovhGp4mpN1FJt4aO8yIzLriVTZilkdXv0YgY3MVNNVFA64d7rNVzPt7/
         uDoAdw/I9wt7F4M+AoQ+DsbgfrLlirjsYmK30WF8s1pOpJ9mOGqbMiO76979hv3CBGmj
         6/GQ==
X-Google-Smtp-Source: APXvYqxenlGpviTUKajhjd5h70fbVtfBZYjpg7adyab446NPvnKr6jujmjoqrk0eooFifFaFDgKzniRhKNTV1qCOUmI=
X-Received: by 2002:a1c:dc07:: with SMTP id t7mr78697953wmg.164.1563999842462;
 Wed, 24 Jul 2019 13:24:02 -0700 (PDT)
MIME-Version: 1.0
References: <3b922aa4-c6d4-e4a4-766d-f324ff77f7b5@linux.com>
 <40f8b7d8-fafa-ad99-34fb-9c63e34917e2@redhat.com> <CALAqxLU199ATrMFa2ARmHOZ3K6ZnOuDLSAqNrTfwOWJaYiW7Yg@mail.gmail.com>
In-Reply-To: <CALAqxLU199ATrMFa2ARmHOZ3K6ZnOuDLSAqNrTfwOWJaYiW7Yg@mail.gmail.com>
From: John Stultz <john.stultz@linaro.org>
Date: Wed, 24 Jul 2019 13:23:50 -0700
Message-ID: <CALAqxLU0VUp=PGx5=JuVp6c5gwLqpSZJxs7ieL631QhdzNQTyA@mail.gmail.com>
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

On Wed, Jul 24, 2019 at 1:18 PM John Stultz <john.stultz@linaro.org> wrote:
>
> On Wed, Jul 24, 2019 at 12:36 PM Laura Abbott <labbott@redhat.com> wrote:
> >
> > On 7/17/19 12:31 PM, Alexander Popov wrote:
> > > Hello!
> > >
> > > The syzkaller [1] has a trouble with fuzzing the Linux kernel with ION Memory
> > > Allocator.
> > >
> > > Syzkaller uses several methods [2] to limit memory consumption of the userspace
> > > processes calling the syscalls for testing the kernel:
> > >   - setrlimit(),
> > >   - cgroups,
> > >   - various sysctl.
> > > But these methods don't work for ION Memory Allocator, so any userspace process
> > > that has access to /dev/ion can bring the system to the out-of-memory state.
> > >
> > > An example of a program doing that:
> > >
> > >
> > > #include <sys/types.h>
> > > #include <sys/stat.h>
> > > #include <fcntl.h>
> > > #include <stdio.h>
> > > #include <linux/types.h>
> > > #include <sys/ioctl.h>
> > >
> > > #define ION_IOC_MAGIC         'I'
> > > #define ION_IOC_ALLOC         _IOWR(ION_IOC_MAGIC, 0, \
> > >                                     struct ion_allocation_data)
> > >
> > > struct ion_allocation_data {
> > >       __u64 len;
> > >       __u32 heap_id_mask;
> > >       __u32 flags;
> > >       __u32 fd;
> > >       __u32 unused;
> > > };
> > >
> > > int main(void)
> > > {
> > >       unsigned long i = 0;
> > >       int fd = -1;
> > >       struct ion_allocation_data data = {
> > >               .len = 0x13f65d8c,
> > >               .heap_id_mask = 1,
> > >               .flags = 0,
> > >               .fd = -1,
> > >               .unused = 0
> > >       };
> > >
> > >       fd = open("/dev/ion", 0);
> > >       if (fd == -1) {
> > >               perror("[-] open /dev/ion");
> > >               return 1;
> > >       }
> > >
> > >       while (1) {
> > >               printf("iter %lu\n", i);
> > >               ioctl(fd, ION_IOC_ALLOC, &data);
> > >               i++;
> > >       }
> > >
> > >       return 0;
> > > }
> > >
> > >
> > > I looked through the code of ion_alloc() and didn't find any limit checks.
> > > Is it currently possible to limit ION kernel allocations for some process?
> > >
> > > If not, is it a right idea to do that?
> > > Thanks!
> > >
> >
> > Yes, I do think that's the right approach. We're working on moving Ion
> > out of staging and this is something I mentioned to John Stultz. I don't
> > think we've thought too hard about how to do the actual limiting so
> > suggestions are welcome.
>
> In part the dmabuf heaps allow for separate heap devices, so we can
> have finer grained permissions to the specific heaps.  But that
> doesn't provide any controls on how much memory one process could
> allocate using the device if it has permission.
>
> I suspect the same issue is present with any of the dmabuf exporters
> (gpu/display drivers, etc), so this is less of an ION/dmabuf heap
> issue and more of a dmabuf core accounting issue.
>

Also, do unmapped memfd buffers have similar accounting issues?

thanks
-john

