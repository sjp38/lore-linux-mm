Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 84DCB6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 05:29:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so88872206pfa.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 02:29:04 -0700 (PDT)
Received: from www9186uo.sakura.ne.jp (153.121.56.200.v6.sakura.ne.jp. [2001:e42:102:1109:153:121:56:200])
        by mx.google.com with ESMTP id sl8si2429040pab.264.2016.07.20.02.29.03
        for <linux-mm@kvack.org>;
        Wed, 20 Jul 2016 02:29:03 -0700 (PDT)
Date: Wed, 20 Jul 2016 18:29:02 +0900
From: Naoya Horiguchi <nao.horiguchi@gmail.com>
Subject: Re: [PATCH v1] mm: hugetlb: remove incorrect comment
Message-ID: <20160720092901.GA15995@www9186uo.sakura.ne.jp>
References: <1468894098-12099-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160719091052.GC9490@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20160719091052.GC9490@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Zhan Chen <zhanc1@andrew.cmu.edu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 19, 2016 at 11:10:53AM +0200, Michal Hocko wrote:
> On Tue 19-07-16 11:08:18, Naoya Horiguchi wrote:
> > dequeue_hwpoisoned_huge_page() can be called without page lock hold,
> > so let's remove incorrect comment.
> 
> Could you explain why the page lock is not really needed, please? Or
> what has changed that it is not needed anymore?

The reason is that dequeue_hwpoisoned_huge_page checks page_huge_active()
inside hugetlb_lock, which allows us to avoid trying to dequeue a hugepage
that are just allocated but not linked to active list yet, even without
taking page lock.

Your question makes me aware of another comment to be removed, so let me
update this.

Thanks,
Naoya Horiguchi
---
