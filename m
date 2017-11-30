Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAFD6B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 02:07:46 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a6so4303815pff.17
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 23:07:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si2607134pgn.172.2017.11.29.23.07.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 23:07:45 -0800 (PST)
Date: Thu, 30 Nov 2017 08:07:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v18 01/10] idr: add #include <linux/bug.h>
Message-ID: <20171130070738.qxtbudfdvkool6lo@dhcp22.suse.cz>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
 <1511963726-34070-2-git-send-email-wei.w.wang@intel.com>
 <20171130005817.GA14785@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130005817.GA14785@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com, Masahiro Yamada <yamada.masahiro@socionext.com>

On Wed 29-11-17 16:58:17, Matthew Wilcox wrote:
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

I agree. It usually requires unexpected combination of config options to
uncover some nasty include dependencies. So these patches might break
build while their additional value is quite questionable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
