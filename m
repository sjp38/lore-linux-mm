Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 27F536B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 13:11:23 -0500 (EST)
Message-ID: <4EF0CFA1.7010406@ah.jp.nec.com>
Date: Tue, 20 Dec 2011 13:10:41 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20111220033537.GA14270@localhost>
In-Reply-To: <20111220033537.GA14270@localhost>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Dec 20, 2011 at 11:35:37AM +0800, Wu Fengguang wrote:
> On Tue, Dec 20, 2011 at 02:38:38AM +0800, Naoya Horiguchi wrote:
> > This flag shows that a given pages is a subpage of transparent hugepage.
> > It does not care about whether it is a head page or a tail page, because
> > it's clear from pfn of the target page which you should know when you read
> > /proc/kpageflags.
> 
> OK, this is aligning with KPF_HUGE. For those who only care about
> head/tail pages, will the KPF_COMPOUND_HEAD/KPF_COMPOUND_TAIL flags be
> set automatically for thp? Which may be more convenient to test/filter
> than the page address.

Yes, both of KPF_COMPOUND_HEAD/TAIL flags are automatically set for thp.
So above patch description was wrong and should be fixed.
(I didn't notice that because page-types hid compound_head/tail flags
without --raw flag. Sorry for confusion.)

> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Thank you.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
