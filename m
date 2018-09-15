Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1408E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 22:55:27 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id m19-v6so3501954uap.3
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 19:55:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6-v6sor2238479vsi.22.2018.09.14.19.55.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Sep 2018 19:55:25 -0700 (PDT)
MIME-Version: 1.0
References: <CAOuPNLj1wx4sznrtLdKjcvuTf0dECPWzPaR946FoYRXB6YAGCw@mail.gmail.com>
 <CAHbLzkojdPxgrEiPLcJUX9c4muw8eupStJ_0xPnAuFM7g4V1jA@mail.gmail.com>
In-Reply-To: <CAHbLzkojdPxgrEiPLcJUX9c4muw8eupStJ_0xPnAuFM7g4V1jA@mail.gmail.com>
From: Pintu Kumar <pintu.ping@gmail.com>
Date: Sat, 15 Sep 2018 08:25:13 +0530
Message-ID: <CAOuPNLgYYhrTf2EPG9C3K6Tqr4OqCehMKhyfFzh9Jz8ryZZbUA@mail.gmail.com>
Subject: Re: KSM not working in 4.9 Kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shy828301@gmail.com
Cc: open list <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Fri, 14 Sep 2018, 10:42 pm Yang Shi, <shy828301@gmail.com> wrote:
>
> Hi Pintu,
>
> I recall there are some ksm test cases in LTP. Did you try them out?

No. I haven't seen the LTP test. I will check out now.
But I wonder what is the problem with my test?


> On Fri, Sep 14, 2018 at 7:28 AM Pintu Kumar <pintu.ping@gmail.com> wrote:
> >
> > Hi All,
> >
> > Board: Hikey620 ARM64
> > Kernel: 4.9.20
> >
> > I am trying to verify KSM (Kernel Same Page Merging) functionality on
> > 4.9 Kernel using "mmap" and madvise user space test utility.
> > But to my observation, it seems KSM is not working for me.
> > CONFIG_KSM=y is enabled in kernel.
> > ksm_init is also called during boot up.
> >   443 ?        SN     0:00 [ksmd]
> >
> > ksmd thread is also running.
> >
> > However, when I see the sysfs, no values are written.
> > ~ # grep -H '' /sys/kernel/mm/ksm/*
> > /sys/kernel/mm/ksm/pages_hashed:0
> > /sys/kernel/mm/ksm/pages_scanned:0
> > /sys/kernel/mm/ksm/pages_shared:0
> > /sys/kernel/mm/ksm/pages_sharing:0
> > /sys/kernel/mm/ksm/pages_to_scan:200
> > /sys/kernel/mm/ksm/pages_unshared:0
> > /sys/kernel/mm/ksm/pages_volatile:0
> > /sys/kernel/mm/ksm/run:1
> > /sys/kernel/mm/ksm/sleep_millisecs:1000
> >
> > So, please let me know if I am doing any thing wrong.
> >
> > This is the test utility:
> > int main(int argc, char *argv[])
> > {
> >         int i, n, size;
> >         char *buffer;
> >         void *addr;
> >
> >         n = 100;
> >         size = 100 * getpagesize();
> >         for (i = 0; i < n; i++) {
> >                 buffer = (char *)malloc(size);
> >                 memset(buffer, 0xff, size);
> >                 addr =  mmap(NULL, size,
> >                            PROT_READ | PROT_EXEC | PROT_WRITE,
> > MAP_PRIVATE | MAP_ANONYMOUS,
> >                            -1, 0);
> >                 madvise(addr, size, MADV_MERGEABLE);
> >                 sleep(1);
> >         }
> >         printf("Done....press ^C\n");
> >
> >         pause();
> >
> >         return 0;
> > }
> >
> >
> >
> > Thanks,
> > Pintu
> >
