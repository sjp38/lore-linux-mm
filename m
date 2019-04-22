Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1305EC10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 16:38:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5563214AE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 16:38:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5563214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54BC96B0006; Mon, 22 Apr 2019 12:38:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D48A6B0007; Mon, 22 Apr 2019 12:38:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 376246B0008; Mon, 22 Apr 2019 12:38:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 149F36B0006
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:38:01 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id w1so56904itk.4
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 09:38:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=x2ZIiqWU/I1OpVuCFizQaPJmUnwt8MtEvuDELdX4JTY=;
        b=YSFpVd1vMeDicINYZYstQ2TZDnzLqyJP0jPOte/PcWMettF+5yFZaOdO8n6H6ghPia
         KJW9obDYCW4UADOjm0xxXE0idTAW02f18GqZ2y74t2GwP0UALDxHLWzBIGLr4+KsVpf9
         cXCh/B4DmED0YPulac4USwy4kDq546aZNt9rskiPu2zG5BLLTUymc1pm77lN76+1P+wz
         aYv0OP34uPuT4BzVEw2LxglFbZ5TbispMdpByzWZ7/jNAClie03zQ2lEoPyXjh1/mJ0k
         9TmoqHqSGiKmiA2u9NtQG357gVBlvmRmDeGqfIwzCPcKplTKQ5neufP6GxmHGrkls/Vq
         fA+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAXFGSq3OS/n8Uh8Heo+ZZQmlT3DOdEusqYDezIghsS4ZApHAGo9
	/ufoOmCRtaBgqy4BwHqKUPFYlHVwO4j+mNJpmDNINxB9AHc8awBv2Ifyw1LiTC6rryby57Q2Jvy
	y32DjJP76FCnuVMBPtTCUkUr/eGB+0DeWNFzosvUOCNdCoEgtpToV8C7EXXtHmGziIg==
X-Received: by 2002:a05:6602:20c3:: with SMTP id 3mr5758552ioz.111.1555951080828;
        Mon, 22 Apr 2019 09:38:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjs6GIg30m3Bwxukp9inT2dReTU6QeQI9GxnxFyDsPq6IdboQkYGhGm2Fv80cTXahySX5i
X-Received: by 2002:a05:6602:20c3:: with SMTP id 3mr5758499ioz.111.1555951079896;
        Mon, 22 Apr 2019 09:37:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555951079; cv=none;
        d=google.com; s=arc-20160816;
        b=E05Pbms/VovecP9LJdQ/QVjeUqgAoOROW56msDXTAJlVBE+Mmp7OEQrVvQ4OuO7ch5
         QFGUynKEh47q8BplLtcSik8TDUoVXvezwW/ne0O+6nxjnBS8dq5PUTS7G3iPoYIHd03o
         LSq0w/G+eCgERjDWegyCQbNxJrWAR57OQs8q1AhDtKpIgefu6ZgcGkh72VyosqoACCoD
         Z2WijcH23l98+dvIRrj1mYpt9pm44bkm8UthFyU2gcxjDmRLb2IznFMT9Awbsvi8weAQ
         fRi9TED/ZqIE596BNl4JyW2vpay6hSAewwE8rZ3DxF9jbFSJ2T7HGRILJysLsMJqcNGw
         skiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=x2ZIiqWU/I1OpVuCFizQaPJmUnwt8MtEvuDELdX4JTY=;
        b=IZm7w67v61VzOgC6Hl3gVEP2aw4J77E86L06SKiUCJTmauZFdw9E9K1biqvpW85w/w
         3hmDHnDVLVivFZrdkRpqIuQM9doa4DEy/zsgf3MaeeZ5VjMMYaxkitkuEF5c3DcMqgMK
         rspOyar3ci0DJ3DSjwoWAFQjuTCzkFmnVvFhNYwfKKys/DKS3aH1gSd4mE9zIQjnNMsq
         PB+//70rTq4WObuXT8N3UQ9jIDLaCvoUBQKDCN22KxpFqvsIHXl0q2Blclnn23jwMJYc
         G1yFW6Uuw3uqgiYxPe9XgKmWLFHYdpXLHqvyqK4eR5646R0K4klNOyiBCAOCwXfWcuXc
         99ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id k18si7954046itb.100.2019.04.22.09.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Apr 2019 09:37:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hIbx7-0005wS-NL; Mon, 22 Apr 2019 10:37:58 -0600
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
 Linux Doc Mailing List <linux-doc@vger.kernel.org>
Cc: Mauro Carvalho Chehab <mchehab@infradead.org>,
 linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
 Johannes Berg <johannes@sipsolutions.net>,
 Kurt Schwemmer <kurt.schwemmer@microsemi.com>,
 Bjorn Helgaas <bhelgaas@google.com>, Alasdair Kergon <agk@redhat.com>,
 Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com,
 Kishon Vijay Abraham I <kishon@ti.com>, Rob Herring <robh+dt@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>,
 Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
 David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 Maxime Ripard <maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>,
 Ning Sun <ning.sun@intel.com>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>,
 Alan Stern <stern@rowland.harvard.edu>,
 Andrea Parri <andrea.parri@amarulasolutions.com>,
 Boqun Feng <boqun.feng@gmail.com>, Nicholas Piggin <npiggin@gmail.com>,
 David Howells <dhowells@redhat.com>, Jade Alglave <j.alglave@ucl.ac.uk>,
 Luc Maranget <luc.maranget@inria.fr>,
 "Paul E. McKenney" <paulmck@linux.ibm.com>, Akira Yokosawa
 <akiyks@gmail.com>, Daniel Lustig <dlustig@nvidia.com>,
 "David S. Miller" <davem@davemloft.net>, =?UTF-8?Q?Andreas_F=c3=a4rber?=
 <afaerber@suse.de>, Manivannan Sadhasivam
 <manivannan.sadhasivam@linaro.org>, Cornelia Huck <cohuck@redhat.com>,
 Farhan Ali <alifm@linux.ibm.com>, Eric Farman <farman@linux.ibm.com>,
 Halil Pasic <pasic@linux.ibm.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, Harry Wei
 <harryxiyou@gmail.com>, Alex Shi <alex.shi@linux.alibaba.com>,
 Jerry Hoemann <jerry.hoemann@hpe.com>,
 Wim Van Sebroeck <wim@linux-watchdog.org>, Guenter Roeck
 <linux@roeck-us.net>, Thomas Gleixner <tglx@linutronix.de>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Russell King <linux@armlinux.org.uk>,
 Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
 "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
 Helge Deller <deller@gmx.de>, Yoshinori Sato <ysato@users.sourceforge.jp>,
 Rich Felker <dalias@libc.org>, Guan Xuetao <gxt@pku.edu.cn>,
 Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>,
 Arnd Bergmann <arnd@arndb.de>, Matt Mackall <mpm@selenic.com>,
 Herbert Xu <herbert@gondor.apana.org.au>, Corey Minyard <minyard@acm.org>,
 Sumit Semwal <sumit.semwal@linaro.org>,
 Linus Walleij <linus.walleij@linaro.org>,
 Bartosz Golaszewski <bgolaszewski@baylibre.com>,
 Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>,
 Stuart Hayes <stuart.w.hayes@gmail.com>, Jaroslav Kysela <perex@perex.cz>,
 Alex Williamson <alex.williamson@redhat.com>,
 Kirti Wankhede <kwankhede@nvidia.com>, Christoph Hellwig <hch@lst.de>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Robin Murphy <robin.murphy@arm.com>,
 Steffen Klassert <steffen.klassert@secunet.com>,
 Kees Cook <keescook@chromium.org>, Emese Revfy <re.emese@gmail.com>,
 James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>,
 linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org,
 devicetree@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-fbdev@vger.kernel.org, tboot-devel@lists.sourceforge.net,
 linux-arch@vger.kernel.org, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org,
 kvm@vger.kernel.org, linux-watchdog@vger.kernel.org,
 linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-block@vger.kernel.org, linux-crypto@vger.kernel.org,
 openipmi-developer@lists.sourceforge.net, linaro-mm-sig@lists.linaro.org,
 linux-gpio@vger.kernel.org, platform-driver-x86@vger.kernel.org,
 iommu@lists.linux-foundation.org, linux-mm@kvack.org,
 kernel-hardening@lists.openwall.com, linux-security-module@vger.kernel.org
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
 <cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <3e26b3a0-bcd3-93a1-d21c-ac1041f93697@deltatee.com>
Date: Mon, 22 Apr 2019 10:37:35 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, platform-driver-x86@vger.kernel.org, linux-gpio@vger.kernel.org, linaro-mm-sig@lists.linaro.org, openipmi-developer@lists.sourceforge.net, linux-crypto@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linux-sh@vger.kernel.org, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-watchdog@vger.kernel.org, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-pci@vger.kernel.org, linux-wireless@vger.kernel.org, serge@hallyn.com, jmorris@namei.org, re.emese@gmail.com, keescook@chromium.org, steffen.klassert@secunet.com, robin.murphy@arm.com, m.szyprowski@samsung.com, hch@lst.de, kwankh
 ede@nvidia.com, alex.williamson@redhat.com, perex@perex.cz, stuart.w.hayes@gmail.com, andy@infradead.org, dvhart@infradead.org, bgolaszewski@baylibre.com, linus.walleij@linaro.org, sumit.semwal@linaro.org, minyard@acm.org, herbert@gondor.apana.org.au, mpm@selenic.com, arnd@arndb.de, rafael@kernel.org, gregkh@linuxfoundation.org, axboe@kernel.dk, gxt@pku.edu.cn, dalias@libc.org, ysato@users.sourceforge.jp, deller@gmx.de, James.Bottomley@HansenPartnership.com, fenghua.yu@intel.com, tony.luck@intel.com, linux@armlinux.org.uk, x86@kernel.org, hpa@zytor.com, bp@alien8.de, tglx@linutronix.de, linux@roeck-us.net, wim@linux-watchdog.org, jerry.hoemann@hpe.com, alex.shi@linux.alibaba.com, harryxiyou@gmail.com, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, pasic@linux.ibm.com, farman@linux.ibm.com, alifm@linux.ibm.com, cohuck@redhat.com, manivannan.sadhasivam@linaro.org, afaerber@suse.de, davem@davemloft.net, dlustig@nvidia.com, akiyks@gmail.com, paulmck@linux.ibm.com, luc.marang
 et@inria.fr, j.alglave@ucl.ac.uk, dhowells@redhat.com, npiggin@gmail.com, boqun.feng@gmail.com, andrea.parri@amarulasolutions.com, stern@rowland.harvard.edu, will.deacon@arm.com, mingo@redhat.com, peterz@infradead.org, ning.sun@intel.com, sean@poorly.run, maxime.ripard@bootlin.com, maarten.lankhorst@linux.intel.com, daniel@ffwll.ch, airlied@linux.ie, b.zolnierkie@samsung.com, mark.rutland@arm.com, robh+dt@kernel.org, kishon@ti.com, dm-devel@redhat.com, snitzer@redhat.com, agk@redhat.com, bhelgaas@google.com, kurt.schwemmer@microsemi.com, johannes@sipsolutions.net, corbet@lwn.net, linux-kernel@vger.kernel.org, mchehab@infradead.org, linux-doc@vger.kernel.org, mchehab+samsung@kernel.org
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [PATCH v2 56/79] docs: Documentation/*.txt: rename all ReST files
 to *.rst
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-04-22 7:27 a.m., Mauro Carvalho Chehab wrote:

> 
> Later patches will move them to a better place and remove the
> :orphan: markup.
> 
> Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> ---
>  Documentation/ABI/removed/sysfs-class-rfkill  |  2 +-
>  Documentation/ABI/stable/sysfs-class-rfkill   |  2 +-
>  Documentation/ABI/stable/sysfs-devices-node   |  2 +-
>  Documentation/ABI/testing/procfs-diskstats    |  2 +-
>  Documentation/ABI/testing/sysfs-block         |  2 +-
>  .../ABI/testing/sysfs-class-switchtec         |  2 +-
>  .../ABI/testing/sysfs-devices-system-cpu      |  4 +-
>  .../{DMA-API-HOWTO.txt => DMA-API-HOWTO.rst}  |  2 +
>  Documentation/{DMA-API.txt => DMA-API.rst}    |  8 ++-
>  .../{DMA-ISA-LPC.txt => DMA-ISA-LPC.rst}      |  4 +-
>  ...{DMA-attributes.txt => DMA-attributes.rst} |  2 +
>  Documentation/{IPMI.txt => IPMI.rst}          |  2 +
>  .../{IRQ-affinity.txt => IRQ-affinity.rst}    |  2 +
>  .../{IRQ-domain.txt => IRQ-domain.rst}        |  2 +
>  Documentation/{IRQ.txt => IRQ.rst}            |  2 +
>  .../{Intel-IOMMU.txt => Intel-IOMMU.rst}      |  2 +
>  Documentation/PCI/pci.txt                     |  8 +--
>  Documentation/{SAK.txt => SAK.rst}            |  2 +
>  Documentation/{SM501.txt => SM501.rst}        |  2 +
>  .../admin-guide/kernel-parameters.txt         |  6 +-
>  Documentation/admin-guide/l1tf.rst            |  2 +-
>  .../{atomic_bitops.txt => atomic_bitops.rst}  |  2 +
>  Documentation/block/biodoc.txt                |  2 +-
>  .../{bt8xxgpio.txt => bt8xxgpio.rst}          |  2 +
>  Documentation/{btmrvl.txt => btmrvl.rst}      |  2 +
>  ...-mapping.txt => bus-virt-phys-mapping.rst} |  4 +-
>  ...g-warn-once.txt => clearing-warn-once.rst} |  2 +
>  Documentation/{cpu-load.txt => cpu-load.rst}  |  2 +
>  .../{cputopology.txt => cputopology.rst}      |  2 +
>  Documentation/{crc32.txt => crc32.rst}        |  2 +
>  Documentation/{dcdbas.txt => dcdbas.rst}      |  2 +
>  ...ging-modules.txt => debugging-modules.rst} |  2 +
>  ...hci1394.txt => debugging-via-ohci1394.rst} |  2 +
>  Documentation/{dell_rbu.txt => dell_rbu.rst}  |  2 +
>  Documentation/device-mapper/statistics.rst    |  4 +-
>  .../devicetree/bindings/phy/phy-bindings.txt  |  2 +-
>  Documentation/{digsig.txt => digsig.rst}      |  2 +
>  Documentation/driver-api/usb/dma.rst          |  6 +-
>  Documentation/driver-model/device.rst         |  2 +-
>  Documentation/{efi-stub.txt => efi-stub.rst}  |  2 +
>  Documentation/{eisa.txt => eisa.rst}          |  2 +
>  Documentation/fb/vesafb.rst                   |  2 +-
>  Documentation/filesystems/sysfs.txt           |  2 +-
>  ...ex-requeue-pi.txt => futex-requeue-pi.rst} |  2 +
>  .../{gcc-plugins.txt => gcc-plugins.rst}      |  2 +
>  Documentation/gpu/drm-mm.rst                  |  2 +-
>  Documentation/{highuid.txt => highuid.rst}    |  2 +
>  .../{hw_random.txt => hw_random.rst}          |  2 +
>  .../{hwspinlock.txt => hwspinlock.rst}        |  2 +
>  Documentation/ia64/IRQ-redir.txt              |  2 +-
>  .../{intel_txt.txt => intel_txt.rst}          |  2 +
>  .../{io-mapping.txt => io-mapping.rst}        |  2 +
>  .../{io_ordering.txt => io_ordering.rst}      |  2 +
>  Documentation/{iostats.txt => iostats.rst}    |  2 +
>  ...flags-tracing.txt => irqflags-tracing.rst} |  2 +
>  Documentation/{isa.txt => isa.rst}            |  2 +
>  Documentation/{isapnp.txt => isapnp.rst}      |  2 +
>  ...hreads.txt => kernel-per-CPU-kthreads.rst} |  4 +-
>  Documentation/{kobject.txt => kobject.rst}    |  4 +-
>  Documentation/{kprobes.txt => kprobes.rst}    |  2 +
>  Documentation/{kref.txt => kref.rst}          |  2 +
>  Documentation/laptops/thinkpad-acpi.txt       |  6 +-
>  Documentation/{ldm.txt => ldm.rst}            |  2 +
>  Documentation/locking/rt-mutex.rst            |  2 +-
>  ...kup-watchdogs.txt => lockup-watchdogs.rst} |  2 +
>  Documentation/{lsm.txt => lsm.rst}            |  2 +
>  Documentation/{lzo.txt => lzo.rst}            |  2 +
>  Documentation/{mailbox.txt => mailbox.rst}    |  2 +
>  Documentation/memory-barriers.txt             |  6 +-
>  ...hameleon-bus.txt => men-chameleon-bus.rst} |  2 +
>  Documentation/networking/scaling.rst          |  4 +-
>  .../{nommu-mmap.txt => nommu-mmap.rst}        |  2 +
>  Documentation/{ntb.txt => ntb.rst}            |  2 +
>  Documentation/{numastat.txt => numastat.rst}  |  2 +
>  Documentation/{padata.txt => padata.rst}      |  2 +
>  ...port-lowlevel.txt => parport-lowlevel.rst} |  2 +
>  ...-semaphore.txt => percpu-rw-semaphore.rst} |  2 +
>  Documentation/{phy.txt => phy.rst}            |  2 +
>  Documentation/{pi-futex.txt => pi-futex.rst}  |  2 +
>  Documentation/{pnp.txt => pnp.rst}            |  2 +
>  ...reempt-locking.txt => preempt-locking.rst} |  2 +
>  Documentation/{pwm.txt => pwm.rst}            |  2 +
>  Documentation/{rbtree.txt => rbtree.rst}      |  2 +
>  .../{remoteproc.txt => remoteproc.rst}        |  4 +-
>  Documentation/{rfkill.txt => rfkill.rst}      |  2 +
>  ...ust-futex-ABI.txt => robust-futex-ABI.rst} |  2 +
>  ...{robust-futexes.txt => robust-futexes.rst} |  2 +
>  Documentation/{rpmsg.txt => rpmsg.rst}        |  2 +
>  Documentation/{rtc.txt => rtc.rst}            |  2 +
>  Documentation/s390/vfio-ccw.rst               |  6 +-
>  Documentation/{sgi-ioc4.txt => sgi-ioc4.rst}  |  2 +
>  Documentation/{siphash.txt => siphash.rst}    |  2 +
>  .../{smsc_ece1099.txt => smsc_ece1099.rst}    |  2 +
>  .../{speculation.txt => speculation.rst}      |  2 +
>  .../{static-keys.txt => static-keys.rst}      |  2 +
>  Documentation/{svga.txt => svga.rst}          |  2 +
>  .../{switchtec.txt => switchtec.rst}          |  4 +-

For all the switchtec changes:

Acked-by: Logan Gunthorpe <logang@deltatee.com>

Thanks,

Logan

