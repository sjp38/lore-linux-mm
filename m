Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EEA46831FE
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 02:03:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g2so98373475pge.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 23:03:40 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h69si5579903pgc.108.2017.03.08.23.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 23:03:40 -0800 (PST)
Message-ID: <58C0FE98.3080903@intel.com>
Date: Thu, 09 Mar 2017 15:04:56 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 kernel 5/5] This patch contains two parts:
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com> <1488519630-89058-6-git-send-email-wei.w.wang@intel.com> <d66a8e86-0ead-90fd-b943-f69449e78349@redhat.com>
In-Reply-To: <d66a8e86-0ead-90fd-b943-f69449e78349@redhat.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Michael S . Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Liang Li <liliang.opensource@gmail.com>

On 03/06/2017 09:23 PM, David Hildenbrand wrote:Am 03.03.2017 um 06:40 
schrieb Wei Wang:
>> From: Liang Li <liang.z.li@intel.com>
Sorry, I just saw the message due to an email issue.

> I'd prefer to split this into two parts then and to create proper subjects.
Agree, will do.

>
> If I remember correctly, the general concept was accepted by most reviewers.
>

Yes, that's also what I was told.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
