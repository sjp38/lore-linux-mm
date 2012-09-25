Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id A1AE46B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 12:00:12 -0400 (EDT)
Received: by oagk14 with SMTP id k14so4764367oag.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 09:00:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1348581414-19103-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1348581414-19103-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 25 Sep 2012 11:59:51 -0400
Message-ID: <CAHGf_=rbyk1UFGwyQ0BSN3qM_K+5J3Q-Aj=xjNDZFrTrZ6a3dw@mail.gmail.com>
Subject: Re: [PATCH] pagemap: fix wrong KPF_THP on slab pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 25, 2012 at 9:56 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> KPF_THP can be set on non-huge compound pages like slab pages, because
> PageTransCompound only sees PG_head and PG_tail. Obviously this is a bug
> and breaks user space applications which look for thp via /proc/kpageflags.
> Currently thp is constructed only on anonymous pages, so this patch makes
> KPF_THP be set when both of PageAnon and PageTransCompound are true.

Indeed. Please add some comment too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
