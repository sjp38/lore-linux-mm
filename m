Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF1D76B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 17:54:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b80so21114573wme.1
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 14:54:30 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id b11si7170900wjs.147.2016.10.04.14.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 14:54:29 -0700 (PDT)
Subject: Re: Frequent ext4 oopses with 4.4.0 on Intel NUC6i3SYB
References: <fcb653b9-cd9e-5cec-1036-4b4c9e1d3e7b@gmx.de>
 <20161004084136.GD17515@quack2.suse.cz>
 <90dfe18f-9fe7-819d-c410-cdd160644ab7@gmx.de>
 <2b7d6bd6-7d16-3c60-1b84-a172ba378402@gmx.de>
 <CABYiri-UUT6zVGyNENp-aBJDj6Oikodc5ZA27Gzq5-bVDqjZ4g@mail.gmail.com>
 <087b53e5-b23b-d3c2-6b8e-980bdcbf75c1@gmx.de>
 <CABYiri_3qS6XgT04hCeF1AMuxY6W0k7QVEO-N0ZodeJTdG=xsw@mail.gmail.com>
From: Johannes Bauer <dfnsonfsduifb@gmx.de>
Message-ID: <26892620-eac1-eed4-da46-da9f183d52b1@gmx.de>
Date: Tue, 4 Oct 2016 23:54:24 +0200
MIME-Version: 1.0
In-Reply-To: <CABYiri_3qS6XgT04hCeF1AMuxY6W0k7QVEO-N0ZodeJTdG=xsw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Korolyov <andrey@xdel.ru>
Cc: Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, linux-mm@kvack.org

On 04.10.2016 22:17, Andrey Korolyov wrote:
>> I'm super puzzled right now :-(
>>
> 
> There are three strawman` ideas out of head, down by a level of
> naiveness increase:
> - disk controller corrupts DMA chunks themselves, could be tested
> against usb stick/sd card with same fs or by switching disk controller
> to a legacy mode if possible, but cascading failure shown previously
> should be rather unusual for this,

I'll check out if this is possible somehow tomorrow.

> - SMP could be partially broken in such manner that it would cause
> overlapped accesses under certain conditions, may be checked with
> 'nosmp',

Unfortunately not:

  CC [M]  drivers/infiniband/core/multicast.o
  CC [M]  drivers/infiniband/core/mad.o
drivers/infiniband/core/mad.c: In function a??ib_mad_port_closea??:
drivers/infiniband/core/mad.c:3252:1: internal compiler error: Bus error
 }
 ^

nuc [~]: cat /proc/cmdline
BOOT_IMAGE=/vmlinuz-4.8.0 root=UUID=f6a792b3-3027-4293-a118-f0df1de9b25c
ro ip=:::::eno1:dhcp nosmp

> - disk accesses and corresponding power spikes are causing partial
> undervoltage condition somewhere where bits are relatively freely
> flipping on paths without parity checking, though this could be
> addressed only to an onboard power distributor, not to power source
> itself.

Huh that sounds like "defective hardware" to me, wouldn't it?

Cheers and thank you for your help,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
