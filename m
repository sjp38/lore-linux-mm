Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 8A8F76B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 16:54:12 -0500 (EST)
Date: Fri, 13 Jan 2012 13:54:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/6 v3] pagemap handles transparent hugepage
Message-Id: <20120113135405.15d9f69f.akpm@linux-foundation.org>
In-Reply-To: <1326396898-5579-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1326396898-5579-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Thu, 12 Jan 2012 14:34:52 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Thank you for all your reviews and comments on the previous posts.
> 
> In this version, I newly added two patches. One is to separate arch
> dependency commented by KOSAKI-san, and the other is to introduce
> new type pme_t as commented by Andrew.
> And I changed "export KPF_THP" patch to fix an unnoticed bug where
> both of KPF_THP and with KPF_HUGE are set for hugetlbfs hugepage.

The patches get a lot of rejects.  I suspect because they were prepared
against 3.2, thus ignoring all the 3.3 MM changes.  Please redo them
against current mainline.

Andrea, have you reviewed this work?  If not, could you please try to
do so?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
