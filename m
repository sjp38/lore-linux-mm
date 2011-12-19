Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9517D6B005A
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 14:24:54 -0500 (EST)
Received: by ghrr18 with SMTP id r18so4192014ghr.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 11:24:53 -0800 (PST)
Message-ID: <4EEF8F85.9010408@gmail.com>
Date: Mon, 19 Dec 2011 14:24:53 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

(12/19/11 1:38 PM), Naoya Horiguchi wrote:
> This flag shows that a given pages is a subpage of transparent hugepage.
> It does not care about whether it is a head page or a tail page, because
> it's clear from pfn of the target page which you should know when you read
> /proc/kpageflags.
> 
> Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>

NAK.

The detail of transparent hugepage are hidden by design. We hope it
keep 'transparent'.
Until any explain why we should expose KPF_THP, we don't agree it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
