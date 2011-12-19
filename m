Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 432B16B005C
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 15:48:06 -0500 (EST)
Received: by yhgm50 with SMTP id m50so3077660yhg.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 12:48:05 -0800 (PST)
Message-ID: <4EEFA308.2090608@gmail.com>
Date: Mon, 19 Dec 2011 15:48:08 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com> <4EEF8F85.9010408@gmail.com> <4EEF9E04.1040007@ah.jp.nec.com>
In-Reply-To: <4EEF9E04.1040007@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

>> The detail of transparent hugepage are hidden by design. We hope it
>> keep 'transparent'.
>> Until any explain why we should expose KPF_THP, we don't agree it.
> 
> The reason why I want to know physical address of thp is testing.
> I'm working on memory error recovery and writing test code to confirm
> that memory recovery really works when an error occurs on thps.
> There I need to locate thps on the physical memory.

I'm sorry, I simply don't understand what you say. Why do you think
memory recovery and thp are related feature?



> 
> IMO, transparency in thp means that we need no manual setup to use
> it (as a contrast with hugetlbfs,) so it seems to me that exporting
> pageflag of thp does not break the design of thp.
> 
> Anyway, I should have written the purpose in the patch description.
> Thanks for the comment.
> 
> Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
