Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id ED7696B005C
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 05:43:59 -0400 (EDT)
Received: by qafl39 with SMTP id l39so1765522qaf.9
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 02:43:59 -0700 (PDT)
Message-ID: <4FCC835C.3010007@gmail.com>
Date: Mon, 04 Jun 2012 05:43:56 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] proc: add ARCH_PFN_OFFSET info to /proc/meminfo
References: <201206011854.17399.b.zolnierkie@samsung.com> <4FC92591.1070401@gmail.com> <201206041018.13568.b.zolnierkie@samsung.com>
In-Reply-To: <201206041018.13568.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

(6/4/12 4:18 AM), Bartlomiej Zolnierkiewicz wrote:
> On Friday 01 June 2012 22:26:57 KOSAKI Motohiro wrote:
>> (6/1/12 12:54 PM), Bartlomiej Zolnierkiewicz wrote:
>>> From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
>>> Subject: [PATCH] proc: add ARCH_PFN_OFFSET info to /proc/meminfo
>>>
>>> ARCH_PFN_OFFSET is needed for user-space to use together with
>>> /proc/kpage[count,flags] interfaces.
>>>
>>> Cc: Matt Mackall<mpm@selenic.com>
>>> Signed-off-by: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
>>> Signed-off-by: Kyungmin Park<kyungmin.park@samsung.com>
>>> ---
>>>    fs/proc/meminfo.c |    4 ++++
>>>    1 file changed, 4 insertions(+)
>>>
>>> Index: b/fs/proc/meminfo.c
>>> ===================================================================
>>> --- a/fs/proc/meminfo.c	2012-05-31 16:53:11.589706973 +0200
>>> +++ b/fs/proc/meminfo.c	2012-05-31 17:03:17.719237120 +0200
>>> @@ -168,6 +168,10 @@ static int meminfo_proc_show(struct seq_
>>>
>>>    	hugetlb_report_meminfo(m);
>>>
>>> +	seq_printf(m,
>>> +		"ArchPFNOffset:    %6lu\n",
>>> +		ARCH_PFN_OFFSET);
>>> +
>>>    	arch_report_meminfo(m);
>>
>> NAK.
>>
>> arch specific report should use arch_report_meminfo().
>
> ARCH_PFN_OFFSET is defined for all archs so I think that it makes little
> sense to duplicate it in every per-arch arch_report_meminfo()..

Incorrect. We are usually constant value for ARCH_PFN_OFFSET. so we don't need
any exporting.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
