Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0436B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 05:37:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t63so20186776pfi.5
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 02:37:48 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t25si6583029pfj.353.2017.10.09.02.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 02:37:47 -0700 (PDT)
Message-ID: <59DB43DD.30409@intel.com>
Date: Mon, 09 Oct 2017 17:39:41 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v16 0/5] Virtio-balloon Enhancement
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com> <1506864327.1916.3.camel@icloud.com>
In-Reply-To: <1506864327.1916.3.camel@icloud.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Damian Tometzki <damian.tometzki@icloud.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 10/01/2017 09:25 PM, Damian Tometzki wrote:
> Hello,
>
> where i can found the patch in git.kernel.org ?
>

We don't have patches there. If you want to try this feature, you can 
get the qemu side draft code here: https://github.com/wei-w-wang/qemu-lm

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
