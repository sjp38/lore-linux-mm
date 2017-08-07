Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0146B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 02:56:02 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v77so89487858pgb.15
        for <linux-mm@kvack.org>; Sun, 06 Aug 2017 23:56:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 94si5143980pla.477.2017.08.06.23.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Aug 2017 23:56:01 -0700 (PDT)
Message-ID: <59880FA5.6040703@intel.com>
Date: Mon, 07 Aug 2017 14:58:45 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v13 1/5] Introduce xbitmap
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com> <1501742299-4369-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1501742299-4369-2-git-send-email-wei.w.wang@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, mawilcox@microsoft.com, akpm@linux-foundation.org, willy@infradead.org
Cc: aarcange@redhat.com, virtio-dev@lists.oasis-open.org, liliang.opensource@gmail.com, amit.shah@redhat.com, quan.xu@aliyun.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, yang.zhang.wz@gmail.com, mgorman@techsingularity.net

On 08/03/2017 02:38 PM, Wei Wang wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> The eXtensible Bitmap is a sparse bitmap representation which is
> efficient for set bits which tend to cluster.  It supports up to
> 'unsigned long' worth of bits, and this commit adds the bare bones --
> xb_set_bit(), xb_clear_bit() and xb_test_bit().
>
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> ---
>   include/linux/radix-tree.h |   2 +
>   include/linux/xbitmap.h    |  49 ++++++++++++++++
>   lib/radix-tree.c           | 139 ++++++++++++++++++++++++++++++++++++++++++++-
>   3 files changed, 188 insertions(+), 2 deletions(-)
>   create mode 100644 include/linux/xbitmap.h
>
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 3e57350..428ccc9 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h


Hi Matthew,

Could you please help to upstream this patch?


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
