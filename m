Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A45B56B0261
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 19:58:24 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id j6so1914508pll.4
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:58:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g2si2115577pgf.467.2017.11.29.16.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 16:58:23 -0800 (PST)
Date: Wed, 29 Nov 2017 16:58:17 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v18 01/10] idr: add #include <linux/bug.h>
Message-ID: <20171130005817.GA14785@bombadil.infradead.org>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
 <1511963726-34070-2-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511963726-34070-2-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com, Masahiro Yamada <yamada.masahiro@socionext.com>

On Wed, Nov 29, 2017 at 09:55:17PM +0800, Wei Wang wrote:
> The <linux/bug.h> was removed from radix-tree.h by the following commit:
> f5bba9d11a256ad2a1c2f8e7fc6aabe6416b7890.
> 
> Since that commit, tools/testing/radix-tree/ couldn't pass compilation
> due to: tools/testing/radix-tree/idr.c:17: undefined reference to
> WARN_ON_ONCE. This patch adds the bug.h header to idr.h to solve the
> issue.

Thanks; I sent this same patch out yesterday.

Unfortunately, you didn't cc the author of this breakage, Masahiro Yamada.
I want to highlight that these kinds of header cleanups are risky,
and very low reward.  I really don't want to see patches going all over
the tree randomly touching header files.  If we've got a real problem
to solve, then sure.  But I want to see a strong justification for any
more header file cleanups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
