Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE7A66B03A0
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 04:56:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s15so43626084pfi.1
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 01:56:27 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t68si1252794pfe.154.2017.04.14.01.56.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 01:56:27 -0700 (PDT)
Message-ID: <58F08F1F.8020904@intel.com>
Date: Fri, 14 Apr 2017 16:58:07 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 3/5] mm: function to offer a page block on the free
 list
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com> <1492076108-117229-4-git-send-email-wei.w.wang@intel.com> <20170413130217.2316b0394192d8677f5ddbdf@linux-foundation.org> <58F03443.9040202@intel.com> <20170414025824.GK784@bombadil.infradead.org>
In-Reply-To: <20170414025824.GK784@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 04/14/2017 10:58 AM, Matthew Wilcox wrote:
> On Fri, Apr 14, 2017 at 10:30:27AM +0800, Wei Wang wrote:
>> OK. What do you think if we add this:
>>
>> #if defined(CONFIG_VIRTIO_BALLOON) || defined(CONFIG_VIRTIO_BALLOON_MODULE)
> That's spelled "IS_ENABLED(CONFIG_VIRTIO_BALLOON)", FYI.

Right, thanks.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
