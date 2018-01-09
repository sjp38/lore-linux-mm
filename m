Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0F7D6B0253
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 09:42:57 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id w196so8160000oia.17
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 06:42:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n65si1601099oih.105.2018.01.09.06.42.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Jan 2018 06:42:56 -0800 (PST)
Subject: Re: [PATCH v21 2/5 RESEND] virtio-balloon: VIRTIO_BALLOON_F_SG
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1515501687-7874-1-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1515501687-7874-1-git-send-email-wei.w.wang@intel.com>
Message-Id: <201801092342.FCH56215.LJHOMVFFFOOSQt@I-love.SAKURA.ne.jp>
Date: Tue, 9 Jan 2018 23:42:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
> - enable OOM to free inflated pages maintained in the local temporary
>   list.

I do want to see it before applying this patch.

Please carefully check how the xbitmap implementation works, and you will
find that you are adding a lot of redundant operations with a bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
