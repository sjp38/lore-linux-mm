Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 253E36B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:23:09 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id j127so142949383qke.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:23:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k48si15421720qtf.287.2017.03.06.05.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 05:23:07 -0800 (PST)
Subject: Re: [PATCH v7 kernel 5/5] This patch contains two parts:
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
 <1488519630-89058-6-git-send-email-wei.w.wang@intel.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <d66a8e86-0ead-90fd-b943-f69449e78349@redhat.com>
Date: Mon, 6 Mar 2017 14:23:02 +0100
MIME-Version: 1.0
In-Reply-To: <1488519630-89058-6-git-send-email-wei.w.wang@intel.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Liang Li <liang.z.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Michael S . Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Liang Li <liliang324@gmail.com>

Am 03.03.2017 um 06:40 schrieb Wei Wang:
> From: Liang Li <liang.z.li@intel.com>

I'd prefer to split this into two parts then and to create proper subjects.

If I remember correctly, the general concept was accepted by most reviewers.

> 
> One is to add a new API to mm go get the unused page information.
> The virtio balloon driver will use this new API added to get the
> unused page info and send it to hypervisor(QEMU) to speed up live
> migration. During sending the bitmap, some the pages may be modified
> and are used by the guest, this inaccuracy can be corrected by the
> dirty page logging mechanism.
> 
> One is to add support the request for vm's unused page information,
> QEMU can make use of unused page information and the dirty page
> logging mechanism to skip the transportation of some of these unused
> pages, this is very helpful to reduce the network traffic and speed
> up the live migration process.

-- 
Thanks,

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
