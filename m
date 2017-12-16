Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0CEE46B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 05:08:10 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f8so8654585pgs.9
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 02:08:10 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d6si6545213pln.570.2017.12.16.02.08.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 02:08:08 -0800 (PST)
Message-ID: <5A34F103.7070004@intel.com>
Date: Sat, 16 Dec 2017 18:10:11 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v19 1/7] xbitmap: Introduce xbitmap
References: <1513079759-14169-2-git-send-email-wei.w.wang@intel.com> <201712151837.MQq7hdgk%fengguang.wu@intel.com> <20171215132405.GB10348@bombadil.infradead.org>
In-Reply-To: <20171215132405.GB10348@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On 12/15/2017 09:24 PM, Matthew Wilcox wrote:
> On Fri, Dec 15, 2017 at 07:05:07PM +0800, kbuild test robot wrote:
>>      21		struct radix_tree_node *node;
>>      22		void **slot;
>                               ^^^
> missing __rcu annotation here.
>
> Wei, could you fold that change into your next round?  Thanks!
>

Sure, I'll do. Thanks for your time on this patch series.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
