Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id C9CEC6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:02:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A76C83EE0C1
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 15:02:01 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 831DA45DE54
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 15:02:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A38445DE4F
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 15:02:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 44070E08002
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 15:02:01 +0900 (JST)
Received: from g01jpexchyt05.g01.fujitsu.local (g01jpexchyt05.g01.fujitsu.local [10.128.194.44])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DE0AAE08006
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 15:02:00 +0900 (JST)
Message-ID: <4FEBF342.9030303@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 15:01:38 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/12] memory-hogplug : check memory offline in offline_pages
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9DB1.7010303@jp.fujitsu.com> <4FEAC916.7030506@cn.fujitsu.com> <4FEBE646.5090801@jp.fujitsu.com> <CAHGf_=rzRthh+hpKWAVF9OyL+P_NhFw4y+W-tF3j0zB8pr0QjA@mail.gmail.com>
In-Reply-To: <CAHGf_=rzRthh+hpKWAVF9OyL+P_NhFw4y+W-tF3j0zB8pr0QjA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

Hi Kosaki-san,

2012/06/28 14:27, KOSAKI Motohiro wrote:
> On Thu, Jun 28, 2012 at 1:06 AM, Yasuaki Ishimatsu
> <isimatu.yasuaki@jp.fujitsu.com> wrote:
>> Hi Wen,
>>
>> 2012/06/27 17:49, Wen Congyang wrote:
>>> At 06/27/2012 01:44 PM, Yasuaki Ishimatsu Wrote:
>>>> When offline_pages() is called to offlined memory, the function fails since
>>>> all memory has been offlined. In this case, the function should succeed.
>>>> The patch adds the check function into offline_pages().
>>>
>>> You miss such case: some pages are online, while some pages are offline.
>>> offline_pages() will fail too in such case.
>>
>> You are right. But current code fails, when the function is called to offline
>> memory. In this case, the function should succeed. So the patch confirms
>> whether the memory was offlined or not. And if memory has already been
>> offlined, offline_pages return 0.
>
> Can you please explain why the caller can't check it? I hope to avoid
> an ignorance
> as far as we can.

Of course, caller side can check it. But there is a possibility that
offline_pages() is called by many functions. So I do not think that it
is good that all functions which call offline_pages() check it.

Thanks,
Yasuaki Ishimatsu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
