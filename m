Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2D076B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 16:58:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b68so11435131wme.4
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 13:58:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q25si9607140wrc.186.2017.09.12.13.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 13:58:38 -0700 (PDT)
Date: Tue, 12 Sep 2017 13:58:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, hugetlb, soft_offline: save compound page order
 before page migration
Message-Id: <20170912135835.0b48340ead5570e50529f676@linux-foundation.org>
In-Reply-To: <20170912135448.341359676c6f8045f4a622f0@linux-foundation.org>
References: <20170912204306.GA12053@gmail.com>
	<20170912135448.341359676c6f8045f4a622f0@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>, linux-kernel@vger.kernel.org, khandual@linux.vnet.ibm.com, mhocko@suse.com, aarcange@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, shli@fb.com, rppt@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mgorman@techsingularity.net, rientjes@google.com, riel@redhat.com, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Tue, 12 Sep 2017 13:54:48 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 12 Sep 2017 22:43:06 +0200 Alexandru Moise <00moses.alexander00@gmail.com> wrote:
> 
> > This fixes a bug in madvise() where if you'd try to soft offline a
> > hugepage via madvise(), while walking the address range you'd end up,
> > using the wrong page offset due to attempting to get the compound
> > order of a former but presently not compound page, due to dissolving
> > the huge page (since c3114a8).
> 
> What are the user visible effects of the bug?  The wrong page is
> offlined?  No offlining occurs?  

This also affects MADV_HWPOISON?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
