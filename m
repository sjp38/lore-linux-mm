Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 10E576B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 00:30:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so52430269wmz.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 21:30:23 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id bd10si1118382wjc.254.2016.08.31.21.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 21:30:21 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id w2so57098298wmd.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 21:30:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
From: Wanpeng Li <kernellwp@gmail.com>
Date: Thu, 1 Sep 2016 12:30:20 +0800
Message-ID: <CANRm+Cy=p8PKg8HqRp7apU0D9X=gpnrahtXRq+S+5Gq863VO8g@mail.gmail.com>
Subject: Re: [PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm <kvm@vger.kernel.org>, "qemu-devel@nongnu.org Developers" <qemu-devel@nongnu.org>, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com

2016-08-08 14:35 GMT+08:00 Liang Li <liang.z.li@intel.com>:
> This patch set contains two parts of changes to the virtio-balloon.
>
> One is the change for speeding up the inflating & deflating process,
> the main idea of this optimization is to use bitmap to send the page
> information to host instead of the PFNs, to reduce the overhead of
> virtio data transmission, address translation and madvise(). This can
> help to improve the performance by about 85%.
>
> Another change is for speeding up live migration. By skipping process
> guest's free pages in the first round of data copy, to reduce needless
> data processing, this can help to save quite a lot of CPU cycles and
> network bandwidth. We put guest's free page information in bitmap and
> send it to host with the virt queue of virtio-balloon. For an idle 8GB
> guest, this can help to shorten the total live migration time from 2Sec
> to about 500ms in the 10Gbps network environment.

I just read the slides of this feature for recent kvm forum, the cloud
providers more care about live migration downtime to avoid customers'
perception than total time, however, this feature will increase
downtime when acquire the benefit of reducing total time, maybe it
will be more acceptable if there is no downside for downtime.

Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
