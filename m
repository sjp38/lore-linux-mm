Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13C24C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:24:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA3892084A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:24:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HiMjmVai"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA3892084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 323BB6B0003; Wed, 19 Jun 2019 04:24:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ACE38E0002; Wed, 19 Jun 2019 04:24:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 126DA8E0001; Wed, 19 Jun 2019 04:24:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD02D6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:24:32 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u2so1027258wrr.3
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:24:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/98dZl/QYDOPqWKKOl2HaSCiOXFKyFays/J24VboxLU=;
        b=aUTfzIlboXgEJ8u+2iEwDe3UKGv5lgT4nAdukpm2GgXJSEuNOI/6TlY968Zy79DKBY
         ZhXC+ZmP9PqKJrgU19cLq2lFqtU+WYLrsE6vuyC69qJiRD4OBK6kP0JkpPcKsCahjZez
         vN9EWXSx/F0m/6El0Yx7HoLYW3O31YLUyx+V8tkDNWR4iyqT3ie9xSw7NfA3zoOCAsF0
         yzQw7MAJXNaL4+3FU8Xfcb6d6CjbygcD/hMX9Rr+CZ7XCQBQvqCcNpBLQ746URcnA1Te
         tFzPO6WfJ3Zc9MtVxtJvhoOg6qmHbVJduQblqzPMgKLjINSnniI9T8oAFd+6gTc0oCSv
         VBvw==
X-Gm-Message-State: APjAAAVhYBujYBX/EGl556p70yuwmlsvf36c3dgmRdDHEPslSzoOv6yN
	VjA5vEt8EPBRXQEUFU2OZseiqE2oJH494D5lUgiq+eJp5sE0t7rQfHMuLn5XXT2T2//vJTMo8iT
	ekIXf6F0uP8/ieBjoiat/RXLnbo4cDrbkpUvXGG7xqtH+CvmIRKTuVMpM+Clp0C+LDA==
X-Received: by 2002:a1c:4b1a:: with SMTP id y26mr7097686wma.105.1560932671962;
        Wed, 19 Jun 2019 01:24:31 -0700 (PDT)
X-Received: by 2002:a1c:4b1a:: with SMTP id y26mr7097592wma.105.1560932670967;
        Wed, 19 Jun 2019 01:24:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560932670; cv=none;
        d=google.com; s=arc-20160816;
        b=HSpWclD0baHj6ypvzpcWTzfDCjWiIuhpWaVZ8TtJ5YQ85HM/ExJTEj+F/ZqE4NUbna
         SOaPVyXFRCmvEd9XH3xiFhQ1PuqcSMMgXvruWxD/nouVK+saRNSDb0wEWzdi670H5X4z
         uvJIbC0p5InC7wxWLeN3RAgkrEuLtmnEwGMUgpvlz/yv0z8noh45rboWE+KoiCfRZQVc
         GEbx9zcXZupaKPUp8dR7ilwXeNo7djpVbbp6fYWJNRponI/wJtuKAlF297WI1IF7Xdiq
         s/o5n9uqd36dNtaQTBu0nn5djxYZ1uy9JaKqeZw7K9/0hDta0qexe+ZDvoJBCExqqCIk
         PLAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/98dZl/QYDOPqWKKOl2HaSCiOXFKyFays/J24VboxLU=;
        b=v121fJDbnCrzSt7dooAUgq2QG8IID3rGSrKJ3GzIgrO2g4E5NDRxyV7osIKbrypBbx
         aIvy6u+GcH6BhTlS5KsdWpGvdbAwXMCYVO/dsqtCtmH6JHu3kVKNYl6jujIJ/k5Tq9Kz
         XnUo+ByM+ch1ESR7encAwGDTOWZYksNVIUTIxULey26CMKOvC+CjdWaI7TIr8z080d4I
         whLgAs1ZR9+AHYNZqFaG8LFV0tn2TFU5lplE914n8aFG+fmf/5ps0hMlwEMO3bgAuU5A
         BXQSc0lqBzz2zlclxYNeRfyNfVHeZL2rYuYHBRTj+SYDiflv51CeayUgi0EPTWIpsVPg
         TQWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HiMjmVai;
       spf=pass (google.com: domain of thierry.reding@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=thierry.reding@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor13019222wrq.39.2019.06.19.01.24.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 01:24:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of thierry.reding@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HiMjmVai;
       spf=pass (google.com: domain of thierry.reding@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=thierry.reding@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/98dZl/QYDOPqWKKOl2HaSCiOXFKyFays/J24VboxLU=;
        b=HiMjmVaijaGwuMSPz3atmX2vClH7S8/v+xsA7HSy2EtlJUUNSLiwqavkBgfjMmx9TB
         stjQ12IGFxZvS/vKabHXUd0lsjpqCceYDRJ9CIdytHaWz1GpLj9cXo4rggvsYryCohos
         XKzp5GSTUlEdNqW3qCe3WQRLGDMsfSMTlRVimIkMdSPiDjJbmuVKwkSIlFzUCJxUo5Js
         yxy0OOneR5zf6cmoDRn0naf7zm1XAMACXCSl3gXvDlOgHsD1U7HgL5RW7/h9A9cKjDcX
         c74xWAp2oOUqrs2c8Wg91mzrxDq6tgz2aWZ2UtDJdNdHozkvBbvo7eIUTG8nTKRupX2H
         agyA==
X-Google-Smtp-Source: APXvYqzxYVPAvy8Dt6ptkYtk9+znALGifqlNvIKr1C1dC6cBg0kQdYFadAZvYmsVqdHoWNM8ga8S0g==
X-Received: by 2002:a5d:5702:: with SMTP id a2mr42959389wrv.89.1560932670425;
        Wed, 19 Jun 2019 01:24:30 -0700 (PDT)
Received: from localhost (p2E5BEF36.dip0.t-ipconnect.de. [46.91.239.54])
        by smtp.gmail.com with ESMTPSA id x6sm20001561wru.0.2019.06.19.01.24.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 01:24:29 -0700 (PDT)
Date: Wed, 19 Jun 2019 10:24:28 +0200
From: Thierry Reding <thierry.reding@gmail.com>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Kurt Schwemmer <kurt.schwemmer@microsemi.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Andrea Parri <andrea.parri@amarulasolutions.com>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Boqun Feng <boqun.feng@gmail.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	David Howells <dhowells@redhat.com>,
	Jade Alglave <j.alglave@ucl.ac.uk>,
	Luc Maranget <luc.maranget@inria.fr>,
	"Paul E. McKenney" <paulmck@linux.ibm.com>,
	Akira Yokosawa <akiyks@gmail.com>,
	Daniel Lustig <dlustig@nvidia.com>,
	Stuart Hayes <stuart.w.hayes@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Darren Hart <dvhart@infradead.org>,
	Kees Cook <keescook@chromium.org>, Emese Revfy <re.emese@gmail.com>,
	Ohad Ben-Cohen <ohad@wizery.com>,
	Bjorn Andersson <bjorn.andersson@linaro.org>,
	Corey Minyard <minyard@acm.org>,
	Marc Zyngier <marc.zyngier@arm.com>,
	William Breathitt Gray <vilhelm.gray@gmail.com>,
	Jaroslav Kysela <perex@perex.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"Naveen N. Rao" <naveen.n.rao@linux.ibm.com>,
	Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Johannes Thumshirn <morbidrsa@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Andreas =?utf-8?Q?F=C3=A4rber?= <afaerber@suse.de>,
	Manivannan Sadhasivam <manivannan.sadhasivam@linaro.org>,
	Rodolfo Giometti <giometti@enneenne.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Sumit Semwal <sumit.semwal@linaro.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Kirti Wankhede <kwankhede@nvidia.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, Farhan Ali <alifm@linux.ibm.com>,
	Eric Farman <farman@linux.ibm.com>,
	Halil Pasic <pasic@linux.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Harry Wei <harryxiyou@gmail.com>,
	Alex Shi <alex.shi@linux.alibaba.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Jerry Hoemann <jerry.hoemann@hpe.com>,
	Wim Van Sebroeck <wim@linux-watchdog.org>,
	Guenter Roeck <linux@roeck-us.net>, Guan Xuetao <gxt@pku.edu.cn>,
	Arnd Bergmann <arnd@arndb.de>,
	Linus Walleij <linus.walleij@linaro.org>,
	Bartosz Golaszewski <bgolaszewski@baylibre.com>,
	Andy Shevchenko <andy@infradead.org>, Jiri Slaby <jslaby@suse.com>,
	linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-arch@vger.kernel.org, platform-driver-x86@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-remoteproc@vger.kernel.org,
	openipmi-developer@lists.sourceforge.net,
	linux-crypto@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux-pwm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-fbdev@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-watchdog@vger.kernel.org, linaro-mm-sig@lists.linaro.org,
	linux-gpio@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main
 dir
Message-ID: <20190619082428.GK3187@ulmo>
References: <cover.1560890771.git.mchehab+samsung@kernel.org>
 <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="x1F0m3RQhDZyj8sd"
Content-Disposition: inline
In-Reply-To: <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--x1F0m3RQhDZyj8sd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 18, 2019 at 05:53:17PM -0300, Mauro Carvalho Chehab wrote:
> Those files belong to the driver-api guide. Add them to the
> driver-api book.
>=20
> Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> ---
>  Documentation/ABI/removed/sysfs-class-rfkill  |  2 +-
>  Documentation/ABI/stable/sysfs-class-rfkill   |  2 +-
>  .../ABI/testing/sysfs-class-switchtec         |  2 +-
>  Documentation/PCI/pci.rst                     |  2 +-
>  Documentation/admin-guide/hw-vuln/l1tf.rst    |  2 +-
>  .../admin-guide/kernel-parameters.txt         |  4 +-
>  .../admin-guide/kernel-per-cpu-kthreads.rst   |  2 +-
>  .../{ =3D> driver-api}/atomic_bitops.rst        |  2 -
>  Documentation/{ =3D> driver-api}/bt8xxgpio.rst  |  2 -
>  .../bus-virt-phys-mapping.rst                 |  2 -
>  .../{connector =3D> driver-api}/connector.rst   |  2 -
>  .../{console =3D> driver-api}/console.rst       |  2 -
>  Documentation/{ =3D> driver-api}/crc32.rst      |  2 -
>  Documentation/{ =3D> driver-api}/dcdbas.rst     |  2 -
>  .../{ =3D> driver-api}/debugging-modules.rst    |  2 -
>  .../debugging-via-ohci1394.rst                |  2 -
>  Documentation/{ =3D> driver-api}/dell_rbu.rst   |  2 -
>  Documentation/{ =3D> driver-api}/digsig.rst     |  2 -
>  .../{EDID/howto.rst =3D> driver-api/edid.rst}   |  2 -
>  Documentation/{ =3D> driver-api}/eisa.rst       |  2 -
>  .../{ =3D> driver-api}/futex-requeue-pi.rst     |  2 -
>  .../{ =3D> driver-api}/gcc-plugins.rst          |  2 -
>  Documentation/{ =3D> driver-api}/hwspinlock.rst |  2 -
>  Documentation/driver-api/index.rst            | 66 +++++++++++++++++++
>  Documentation/{ =3D> driver-api}/io-mapping.rst |  2 -
>  .../{ =3D> driver-api}/io_ordering.rst          |  2 -
>  .../{IPMI.rst =3D> driver-api/ipmi.rst}         |  2 -
>  .../irq-affinity.rst}                         |  2 -
>  .../irq-domain.rst}                           |  2 -
>  Documentation/{IRQ.rst =3D> driver-api/irq.rst} |  2 -
>  .../{ =3D> driver-api}/irqflags-tracing.rst     |  2 -
>  Documentation/{ =3D> driver-api}/isa.rst        |  2 -
>  Documentation/{ =3D> driver-api}/isapnp.rst     |  2 -
>  Documentation/{ =3D> driver-api}/kobject.rst    |  4 +-
>  Documentation/{ =3D> driver-api}/kprobes.rst    |  2 -
>  Documentation/{ =3D> driver-api}/kref.rst       |  2 -
>  .../pblk.txt =3D> driver-api/lightnvm-pblk.rst} |  0
>  Documentation/{ =3D> driver-api}/lzo.rst        |  2 -
>  Documentation/{ =3D> driver-api}/mailbox.rst    |  2 -
>  .../{ =3D> driver-api}/men-chameleon-bus.rst    |  2 -
>  Documentation/{ =3D> driver-api}/nommu-mmap.rst |  2 -
>  Documentation/{ =3D> driver-api}/ntb.rst        |  2 -
>  Documentation/{nvmem =3D> driver-api}/nvmem.rst |  2 -
>  Documentation/{ =3D> driver-api}/padata.rst     |  2 -
>  .../{ =3D> driver-api}/parport-lowlevel.rst     |  2 -
>  .../{ =3D> driver-api}/percpu-rw-semaphore.rst  |  2 -
>  Documentation/{ =3D> driver-api}/pi-futex.rst   |  2 -
>  Documentation/driver-api/pps.rst              |  2 -
>  .../{ =3D> driver-api}/preempt-locking.rst      |  2 -
>  .../{pti =3D> driver-api}/pti_intel_mid.rst     |  2 -
>  Documentation/driver-api/ptp.rst              |  2 -
>  Documentation/{ =3D> driver-api}/pwm.rst        |  2 -
>  Documentation/{ =3D> driver-api}/rbtree.rst     |  2 -
>  Documentation/{ =3D> driver-api}/remoteproc.rst |  4 +-
>  Documentation/{ =3D> driver-api}/rfkill.rst     |  2 -
>  .../{ =3D> driver-api}/robust-futex-ABI.rst     |  2 -
>  .../{ =3D> driver-api}/robust-futexes.rst       |  2 -
>  Documentation/{ =3D> driver-api}/rpmsg.rst      |  2 -
>  Documentation/{ =3D> driver-api}/sgi-ioc4.rst   |  2 -
>  .../{SM501.rst =3D> driver-api/sm501.rst}       |  2 -
>  .../{ =3D> driver-api}/smsc_ece1099.rst         |  2 -
>  .../{ =3D> driver-api}/speculation.rst          |  8 +--
>  .../{ =3D> driver-api}/static-keys.rst          |  2 -
>  Documentation/{ =3D> driver-api}/switchtec.rst  |  4 +-
>  Documentation/{ =3D> driver-api}/sync_file.rst  |  2 -
>  Documentation/{ =3D> driver-api}/tee.rst        |  2 -
>  .../{ =3D> driver-api}/this_cpu_ops.rst         |  2 -
>  .../unaligned-memory-access.rst               |  2 -
>  .../{ =3D> driver-api}/vfio-mediated-device.rst |  4 +-
>  Documentation/{ =3D> driver-api}/vfio.rst       |  2 -
>  Documentation/{ =3D> driver-api}/xillybus.rst   |  2 -
>  Documentation/{ =3D> driver-api}/xz.rst         |  2 -
>  Documentation/{ =3D> driver-api}/zorro.rst      |  2 -
>  Documentation/driver-model/device.rst         |  2 +-
>  Documentation/fb/fbcon.rst                    |  4 +-
>  Documentation/filesystems/sysfs.txt           |  2 +-
>  Documentation/gpu/drm-mm.rst                  |  2 +-
>  Documentation/ia64/irq-redir.rst              |  2 +-
>  Documentation/laptops/thinkpad-acpi.rst       |  6 +-
>  Documentation/locking/rt-mutex.rst            |  2 +-
>  Documentation/networking/scaling.rst          |  4 +-
>  Documentation/s390/vfio-ccw.rst               |  6 +-
>  Documentation/sysctl/kernel.rst               |  2 +-
>  Documentation/sysctl/vm.rst                   |  2 +-
>  Documentation/trace/kprobetrace.rst           |  2 +-
>  Documentation/translations/zh_CN/IRQ.txt      |  4 +-
>  .../translations/zh_CN/filesystems/sysfs.txt  |  2 +-
>  .../translations/zh_CN/io_ordering.txt        |  4 +-
>  Documentation/w1/w1.netlink                   |  2 +-
>  Documentation/watchdog/hpwdt.rst              |  2 +-
>  MAINTAINERS                                   | 46 ++++++-------
>  arch/Kconfig                                  |  4 +-
>  arch/unicore32/include/asm/io.h               |  2 +-
>  drivers/base/core.c                           |  2 +-
>  drivers/char/ipmi/Kconfig                     |  2 +-
>  drivers/char/ipmi/ipmi_si_hotmod.c            |  2 +-
>  drivers/char/ipmi/ipmi_si_intf.c              |  2 +-
>  drivers/dma-buf/Kconfig                       |  2 +-
>  drivers/gpio/Kconfig                          |  2 +-
>  drivers/gpu/drm/Kconfig                       |  2 +-
>  drivers/pci/switch/Kconfig                    |  2 +-
>  drivers/platform/x86/Kconfig                  |  4 +-
>  drivers/platform/x86/dcdbas.c                 |  2 +-
>  drivers/platform/x86/dell_rbu.c               |  2 +-
>  drivers/pnp/isapnp/Kconfig                    |  2 +-
>  drivers/tty/Kconfig                           |  2 +-
>  drivers/vfio/Kconfig                          |  2 +-
>  drivers/vfio/mdev/Kconfig                     |  2 +-
>  drivers/w1/Kconfig                            |  2 +-
>  include/asm-generic/bitops/atomic.h           |  2 +-
>  include/linux/io-mapping.h                    |  2 +-
>  include/linux/jump_label.h                    |  2 +-
>  include/linux/kobject.h                       |  2 +-
>  include/linux/kobject_ns.h                    |  2 +-
>  include/linux/rbtree.h                        |  2 +-
>  include/linux/rbtree_augmented.h              |  2 +-
>  init/Kconfig                                  |  2 +-
>  kernel/padata.c                               |  2 +-
>  lib/Kconfig                                   |  2 +-
>  lib/Kconfig.debug                             |  2 +-
>  lib/crc32.c                                   |  2 +-
>  lib/kobject.c                                 |  4 +-
>  lib/lzo/lzo1x_decompress_safe.c               |  2 +-
>  lib/xz/Kconfig                                |  2 +-
>  mm/Kconfig                                    |  2 +-
>  mm/nommu.c                                    |  2 +-
>  samples/Kconfig                               |  2 +-
>  samples/kprobes/kprobe_example.c              |  2 +-
>  samples/kprobes/kretprobe_example.c           |  2 +-
>  scripts/gcc-plugins/Kconfig                   |  2 +-
>  tools/include/linux/rbtree.h                  |  2 +-
>  tools/include/linux/rbtree_augmented.h        |  2 +-
>  132 files changed, 173 insertions(+), 235 deletions(-)
>  rename Documentation/{ =3D> driver-api}/atomic_bitops.rst (99%)
>  rename Documentation/{ =3D> driver-api}/bt8xxgpio.rst (99%)
>  rename Documentation/{ =3D> driver-api}/bus-virt-phys-mapping.rst (99%)
>  rename Documentation/{connector =3D> driver-api}/connector.rst (99%)
>  rename Documentation/{console =3D> driver-api}/console.rst (99%)
>  rename Documentation/{ =3D> driver-api}/crc32.rst (99%)
>  rename Documentation/{ =3D> driver-api}/dcdbas.rst (99%)
>  rename Documentation/{ =3D> driver-api}/debugging-modules.rst (98%)
>  rename Documentation/{ =3D> driver-api}/debugging-via-ohci1394.rst (99%)
>  rename Documentation/{ =3D> driver-api}/dell_rbu.rst (99%)
>  rename Documentation/{ =3D> driver-api}/digsig.rst (99%)
>  rename Documentation/{EDID/howto.rst =3D> driver-api/edid.rst} (99%)
>  rename Documentation/{ =3D> driver-api}/eisa.rst (99%)
>  rename Documentation/{ =3D> driver-api}/futex-requeue-pi.rst (99%)
>  rename Documentation/{ =3D> driver-api}/gcc-plugins.rst (99%)
>  rename Documentation/{ =3D> driver-api}/hwspinlock.rst (99%)
>  rename Documentation/{ =3D> driver-api}/io-mapping.rst (99%)
>  rename Documentation/{ =3D> driver-api}/io_ordering.rst (99%)
>  rename Documentation/{IPMI.rst =3D> driver-api/ipmi.rst} (99%)
>  rename Documentation/{IRQ-affinity.rst =3D> driver-api/irq-affinity.rst}=
 (99%)
>  rename Documentation/{IRQ-domain.rst =3D> driver-api/irq-domain.rst} (99=
%)
>  rename Documentation/{IRQ.rst =3D> driver-api/irq.rst} (99%)
>  rename Documentation/{ =3D> driver-api}/irqflags-tracing.rst (99%)
>  rename Documentation/{ =3D> driver-api}/isa.rst (99%)
>  rename Documentation/{ =3D> driver-api}/isapnp.rst (98%)
>  rename Documentation/{ =3D> driver-api}/kobject.rst (99%)
>  rename Documentation/{ =3D> driver-api}/kprobes.rst (99%)
>  rename Documentation/{ =3D> driver-api}/kref.rst (99%)
>  rename Documentation/{lightnvm/pblk.txt =3D> driver-api/lightnvm-pblk.rs=
t} (100%)
>  rename Documentation/{ =3D> driver-api}/lzo.rst (99%)
>  rename Documentation/{ =3D> driver-api}/mailbox.rst (99%)
>  rename Documentation/{ =3D> driver-api}/men-chameleon-bus.rst (99%)
>  rename Documentation/{ =3D> driver-api}/nommu-mmap.rst (99%)
>  rename Documentation/{ =3D> driver-api}/ntb.rst (99%)
>  rename Documentation/{nvmem =3D> driver-api}/nvmem.rst (99%)
>  rename Documentation/{ =3D> driver-api}/padata.rst (99%)
>  rename Documentation/{ =3D> driver-api}/parport-lowlevel.rst (99%)
>  rename Documentation/{ =3D> driver-api}/percpu-rw-semaphore.rst (99%)
>  rename Documentation/{ =3D> driver-api}/pi-futex.rst (99%)
>  rename Documentation/{ =3D> driver-api}/preempt-locking.rst (99%)
>  rename Documentation/{pti =3D> driver-api}/pti_intel_mid.rst (99%)
>  rename Documentation/{ =3D> driver-api}/pwm.rst (99%)
>  rename Documentation/{ =3D> driver-api}/rbtree.rst (99%)
>  rename Documentation/{ =3D> driver-api}/remoteproc.rst (99%)
>  rename Documentation/{ =3D> driver-api}/rfkill.rst (99%)
>  rename Documentation/{ =3D> driver-api}/robust-futex-ABI.rst (99%)
>  rename Documentation/{ =3D> driver-api}/robust-futexes.rst (99%)
>  rename Documentation/{ =3D> driver-api}/rpmsg.rst (99%)
>  rename Documentation/{ =3D> driver-api}/sgi-ioc4.rst (99%)
>  rename Documentation/{SM501.rst =3D> driver-api/sm501.rst} (99%)
>  rename Documentation/{ =3D> driver-api}/smsc_ece1099.rst (99%)
>  rename Documentation/{ =3D> driver-api}/speculation.rst (99%)
>  rename Documentation/{ =3D> driver-api}/static-keys.rst (99%)
>  rename Documentation/{ =3D> driver-api}/switchtec.rst (97%)
>  rename Documentation/{ =3D> driver-api}/sync_file.rst (99%)
>  rename Documentation/{ =3D> driver-api}/tee.rst (99%)
>  rename Documentation/{ =3D> driver-api}/this_cpu_ops.rst (99%)
>  rename Documentation/{ =3D> driver-api}/unaligned-memory-access.rst (99%)
>  rename Documentation/{ =3D> driver-api}/vfio-mediated-device.rst (99%)
>  rename Documentation/{ =3D> driver-api}/vfio.rst (99%)
>  rename Documentation/{ =3D> driver-api}/xillybus.rst (99%)
>  rename Documentation/{ =3D> driver-api}/xz.rst (99%)
>  rename Documentation/{ =3D> driver-api}/zorro.rst (99%)

Acked-by: Thierry Reding <thierry.reding@gmail.com>

--x1F0m3RQhDZyj8sd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAl0J8TwACgkQ3SOs138+
s6FwnBAAgAw4Y4VTIu9fC7EKqGeq67QHb5tbw5DZb3z2ZbpFT2k82eX/X5PTclLE
yPDjKTqXPGwQ7MnAmYqcMZGlWdrkYXS0/n/nEQ7cpbpzVaOA7NJzs58dgr48qAb0
bWHbIpuKXs5LAQp/JjrW1bLYDZOSFf3QKpOYJ999lI6qo5peqP+Oi5kIZuob/RYe
MayT0gsMmjD39kEVWQny/DchbJj+oa4US5kw3mo3JgYdbIDGgj28urwUBCBOgBsH
IkWf/8NdCW0ypWrTonk0jxmEZy9MAhW8XkIQ/Xu5VzOWVomXOK8KF2SIczESlGSr
HpZSWhxgu1/sGitcWoPlQM6H2nFOOQIPRLAR53vzCc1KMeYfQ5uBDqsCw8im+lkw
qkXrljQ5mmFmFN0eVt38/hR/LzEofvCOF8LySe4+Ho5jZj0Fkr3istEObrFfks7l
CAhqy+UEYLxujLZ95dHPq3vvKSq56XQj4xmSZ3QCB2PJ9xAgGXywCURXN+euFk2r
JX6l+AVuQrNJy8sffyugZO1QX7AjcuDYScZsuKn6w/J1jih9NmpPe0UMbYXDHoJ/
ZSIYMZgi4RMjlmh71fAg4ClUsQ5G5UPwAlUm2CcmAfrFKZJfkUu1SnI406y0xe0Y
n/mzJsnMuPU8hgQkzfBGPpEInrOG3Bqr+G9L80TZR/7j+sBFBlA=
=iOMR
-----END PGP SIGNATURE-----

--x1F0m3RQhDZyj8sd--

