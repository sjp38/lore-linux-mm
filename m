Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE4306B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 16:49:28 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id f4so4639040wre.9
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 13:49:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b9si3858419wrh.491.2017.11.30.13.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 13:49:27 -0800 (PST)
Date: Thu, 30 Nov 2017 13:49:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v18 01/10] idr: add #include <linux/bug.h>
Message-Id: <20171130134924.e842ccd01e34eaf8834f4033@linux-foundation.org>
In-Reply-To: <20171130005817.GA14785@bombadil.infradead.org>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
	<1511963726-34070-2-git-send-email-wei.w.wang@intel.com>
	<20171130005817.GA14785@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com, Masahiro Yamada <yamada.masahiro@socionext.com>

On Wed, 29 Nov 2017 16:58:17 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> On Wed, Nov 29, 2017 at 09:55:17PM +0800, Wei Wang wrote:
> > The <linux/bug.h> was removed from radix-tree.h by the following commit:
> > f5bba9d11a256ad2a1c2f8e7fc6aabe6416b7890.
> > 
> > Since that commit, tools/testing/radix-tree/ couldn't pass compilation
> > due to: tools/testing/radix-tree/idr.c:17: undefined reference to
> > WARN_ON_ONCE. This patch adds the bug.h header to idr.h to solve the
> > issue.
> 
> Thanks; I sent this same patch out yesterday.
> 
> Unfortunately, you didn't cc the author of this breakage, Masahiro Yamada.
> I want to highlight that these kinds of header cleanups are risky,
> and very low reward.  I really don't want to see patches going all over
> the tree randomly touching header files.  If we've got a real problem
> to solve, then sure.  But I want to see a strong justification for any
> more header file cleanups.

I tend to disagree.  We accumulate more and more cruft over time so it
is good to be continually hacking away at it.  These little build
breaks happen occasionally but they are trivially and quickly fixed. 
If a small minority of these cleanups require a followup patch which
consumes a global ten person minutes then that seems an acceptable
price to pay.  Says the guy who pays most of that price :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
