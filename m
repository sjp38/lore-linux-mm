Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 86B6D6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 15:32:37 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 19 Dec 2011 15:32:36 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBJKWYLG211502
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 15:32:34 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBJKWWE0006829
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 15:32:32 -0500
Message-ID: <4EEF9F3E.9000107@linux.vnet.ibm.com>
Date: Mon, 19 Dec 2011 12:31:58 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com> <4EEF8F85.9010408@gmail.com>
In-Reply-To: <4EEF8F85.9010408@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On 12/19/2011 11:24 AM, KOSAKI Motohiro wrote:
> (12/19/11 1:38 PM), Naoya Horiguchi wrote:
>> This flag shows that a given pages is a subpage of transparent hugepage.
>> It does not care about whether it is a head page or a tail page, because
>> it's clear from pfn of the target page which you should know when you read
>> /proc/kpageflags.
>>
>> Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
> 
> NAK.
> 
> The detail of transparent hugepage are hidden by design. We hope it
> keep 'transparent'.
> Until any explain why we should expose KPF_THP, we don't agree it.

Transparent shouldn't mean "undebuggable", though. :)

Let's say you profiled a application and the data shows you're missing
the TLB a bunch, but you're also using THP.  This might give you a shot
at figuring out which parts of your application are *TRULY* THP-backed
instead of just the areas you *think* are backed.

I'm not sure there's another way to figure it out at the moment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
