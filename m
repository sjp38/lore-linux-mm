Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA35C6B02BA
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 12:25:04 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id j82so64208181ybg.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 09:25:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q77si3030941qki.152.2017.01.19.09.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 09:25:04 -0800 (PST)
Subject: Re: [PATCH v6 kernel 0/5] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <2a32f616-25a8-ba5a-f74c-d619fc8ab333@redhat.com>
 <20170118173139-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <b11c5cbe-6c63-e9dc-0313-e2dff3830951@redhat.com>
Date: Thu, 19 Jan 2017 18:24:59 +0100
MIME-Version: 1.0
In-Reply-To: <20170118173139-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Liang Li <liang.z.li@intel.com>, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, amit.shah@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, aarcange@redhat.com, dgilbert@redhat.com, quintela@redhat.com


> As long as the interface is similar, it seems to make
> sense for me - why invent a completely new device that
> looks very much like the old one?

The only reason would be that this feature could be used independently
of virtio-balloon. But this would of course only be the case, if
ballooning is strictly not wanted in a configuration, or the current
balloon driver gets replaced by an alternative solution.

I don't have any strong feelings about this, just wanted to double check.

Thanks,

David

> 
> So this boils down to whether the speedup patches are merged.
> 
> 
>> -- 
>>
>> David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
