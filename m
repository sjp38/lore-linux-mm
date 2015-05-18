Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 738B06B009D
	for <linux-mm@kvack.org>; Mon, 18 May 2015 13:42:45 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so160791863pac.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 10:42:45 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id tz6si16952702pab.216.2015.05.18.10.42.44
        for <linux-mm@kvack.org>;
        Mon, 18 May 2015 10:42:44 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC 0/3] Mirrored memory support for boot time allocations
Date: Mon, 18 May 2015 17:42:42 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A86CBC@ORSMSX114.amr.corp.intel.com>
References: <cover.1423259664.git.tony.luck@intel.com>
 <55599BAA.20204@huawei.com>
In-Reply-To: <55599BAA.20204@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Xiexiuqi <xiexiuqi@huawei.com>, Linux MM <linux-mm@kvack.org>

> Is it means that you will create a new zone to fill mirrored memory, like=
 the
> movable zone, right?=20

That's my general plan.

> I think this will change a lot of code, why not create a new migrate type=
?
> such as CMA, e.g. MIGRATE_MIRROR

I'm still exploring options ... the idea is to use mirrored memory for kern=
el allocations
(because our machine check recovery code will always crash the system for e=
rrors
in kernel memory - while we can avoid the crash for errors in application m=
emory).
I'm not familiar with CMA ... can you explain a bit how it might let me dir=
ect kernel
allocations to specific areas of memory?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
