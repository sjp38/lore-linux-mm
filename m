Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 1ED706B009E
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 12:19:54 -0500 (EST)
Message-ID: <4F145AC8.7040307@ah.jp.nec.com>
Date: Mon, 16 Jan 2012 12:13:44 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6 v3] pagemap handles transparent hugepage
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Fri, Jan 13, 2012 at 01:54:05PM -0800, Andrew Morton wrote:
> On Thu, 12 Jan 2012 14:34:52 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > Thank you for all your reviews and comments on the previous posts.
> > 
> > In this version, I newly added two patches. One is to separate arch
> > dependency commented by KOSAKI-san, and the other is to introduce
> > new type pme_t as commented by Andrew.
> > And I changed "export KPF_THP" patch to fix an unnoticed bug where
> > both of KPF_THP and with KPF_HUGE are set for hugetlbfs hugepage.
> 
> The patches get a lot of rejects.  I suspect because they were prepared
> against 3.2, thus ignoring all the 3.3 MM changes.  Please redo them
> against current mainline.

OK, I'll post the next version with rebased to 3.3-rc1 (maybe it will be
released later this week.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
