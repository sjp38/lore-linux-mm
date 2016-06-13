Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 968E96B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 09:12:03 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id jf8so50193378lbc.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 06:12:03 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id uw10si29635385wjc.242.2016.06.13.06.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 06:12:02 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id r5so14807983wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 06:12:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160613130651.GA8662@invalid>
References: <Pine.LNX.4.44L0.1606091410580.1353-100000@iolanthe.rowland.org>
 <50F437E3-85F7-4034-BAAE-B2558173A2EA@gmail.com> <20160613130651.GA8662@invalid>
From: Adam Morrison <mad@cs.technion.ac.il>
Date: Mon, 13 Jun 2016 16:11:39 +0300
Message-ID: <CAHMfzJktLSPZuLJ0R90Zaa6tj+awX9NDO2DPzjxEEJuY0CFV+g@mail.gmail.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code]
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: M G Berberich <berberic@fmi.uni-passau.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, iommu@lists.linux-foundation.org, USB list <linux-usb@vger.kernel.org>, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>

Hi,

On Mon, Jun 13, 2016 at 4:06 PM, M G Berberich
<berberic@fmi.uni-passau.de> wrote:

> Hello,
>
>> >> With 4.7-rc2, after detecting a USB Mass Storage device
>> >>
>> >>  [   11.589843] usb-storage 4-2:1.0: USB Mass Storage device detected
>> >>
>> >> a constant flow of kernel-BUGS is reported (several per second).
>
> [=E2=80=A6]
>
>> > This looks like a bug in the memory management subsystem.  It should b=
e
>> > reported on the linux-mm mailing list (CC'ed).
>>
>> This bug is IOMMU related (mailing list CC=E2=80=99ed) and IIUC already =
fixed.
>
> Not fixed in 4.7-rc3

These patches should fix the issue:

    https://lkml.org/lkml/2016/6/1/310
    https://lkml.org/lkml/2016/6/1/311

I'm not sure why they weren't applied... will ping the maintainers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
