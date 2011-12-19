Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 682F76B005C
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 15:45:43 -0500 (EST)
Received: by yhgm50 with SMTP id m50so3076003yhg.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 12:45:42 -0800 (PST)
Message-ID: <4EEFA278.7010200@gmail.com>
Date: Mon, 19 Dec 2011 15:45:44 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com> <4EEF8F85.9010408@gmail.com> <4EEF9F3E.9000107@linux.vnet.ibm.com>
In-Reply-To: <4EEF9F3E.9000107@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

(12/19/11 3:31 PM), Dave Hansen wrote:
> On 12/19/2011 11:24 AM, KOSAKI Motohiro wrote:
>> (12/19/11 1:38 PM), Naoya Horiguchi wrote:
>>> This flag shows that a given pages is a subpage of transparent hugepage.
>>> It does not care about whether it is a head page or a tail page, because
>>> it's clear from pfn of the target page which you should know when you read
>>> /proc/kpageflags.
>>>
>>> Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
>>
>> NAK.
>>
>> The detail of transparent hugepage are hidden by design. We hope it
>> keep 'transparent'.
>> Until any explain why we should expose KPF_THP, we don't agree it.
> 
> Transparent shouldn't mean "undebuggable", though. :)
> 
> Let's say you profiled a application and the data shows you're missing
> the TLB a bunch, but you're also using THP.  This might give you a shot
> at figuring out which parts of your application are *TRULY* THP-backed
> instead of just the areas you *think* are backed.
> 
> I'm not sure there's another way to figure it out at the moment.

A snapshot status of THP doesn't help your purpose. I think you need
perf or similar profiling subsystem enhancement.

Because of, if you've seen KPF_THP at once, It has no guarantee to keep
hugepages until applications run. Opposite, If you only need rough
statistics, the best way is to add some new stat to
/sys/kernel/mm/transparent_hugepage.

I don't think your usecase and current proposal are matched.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
