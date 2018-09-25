Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 002B98E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 15:56:01 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r130-v6so10702892pgr.13
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 12:56:00 -0700 (PDT)
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700067.outbound.protection.outlook.com. [40.107.70.67])
        by mx.google.com with ESMTPS id 7-v6si2994867pgw.401.2018.09.25.12.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Sep 2018 12:55:59 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v2 00/20] vmw_balloon: compaction, shrinker, 64-bit, etc.
Date: Tue, 25 Sep 2018 19:55:56 +0000
Message-ID: <4E03488E-E9EC-4676-A008-C89BC61CD05A@vmware.com>
References: <20180920173026.141333-1-namit@vmware.com>
 <20180925181548.GB25458@kroah.com>
In-Reply-To: <20180925181548.GB25458@kroah.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <38E03D8D6F3DB242B54FC7FA56F287BA@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Xavier Deguillard <xdeguillard@vmware.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>

at 11:15 AM, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:

> On Thu, Sep 20, 2018 at 10:30:06AM -0700, Nadav Amit wrote:
>> This patch-set adds the following enhancements to the VMware balloon
>> driver:
>>=20
>> 1. Balloon compaction support.
>> 2. Report the number of inflated/deflated ballooned pages through vmstat=
.
>> 3. Memory shrinker to avoid balloon over-inflation (and OOM).
>> 4. Support VMs with memory limit that is greater than 16TB.
>> 5. Faster and more aggressive inflation.
>>=20
>> To support compaction we wish to use the existing infrastructure.
>> However, we need to make slight adaptions for it. We add a new list
>> interface to balloon-compaction, which is more generic and efficient,
>> since it does not require as many IRQ save/restore operations. We leave
>> the old interface that is used by the virtio balloon.
>>=20
>> Big parts of this patch-set are cleanup and documentation. Patches 1-13
>> simplify the balloon code, document its behavior and allow the balloon
>> code to run concurrently. The support for concurrency is required for
>> compaction and the shrinker interface.
>>=20
>> For documentation we use the kernel-doc format. We are aware that the
>> balloon interface is not public, but following the kernel-doc format may
>> be useful one day.
>=20
> I applied the first 16 patches.  Please fix up 17 and resend.

Thanks. I will update it and resend later today.

Regards,
Nadav
