Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 639166B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 21:48:09 -0400 (EDT)
Message-ID: <50650330.6000006@cn.fujitsu.com>
Date: Fri, 28 Sep 2012 09:53:52 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] memory-hotplug: clear hwpoisoned flag when onlining
 pages
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-4-git-send-email-wency@cn.fujitsu.com> <CAHGf_=qhBSvOgStSgmcKZY8qMyj_Fp=3RLMD08YM8F9NzuY28Q@mail.gmail.com>
In-Reply-To: <CAHGf_=qhBSvOgStSgmcKZY8qMyj_Fp=3RLMD08YM8F9NzuY28Q@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com

At 09/28/2012 04:17 AM, KOSAKI Motohiro Wrote:
> On Thu, Sep 27, 2012 at 1:45 AM,  <wency@cn.fujitsu.com> wrote:
>> From: Wen Congyang <wency@cn.fujitsu.com>
>>
>> hwpoisoned may set when we offline a page by the sysfs interface
>> /sys/devices/system/memory/soft_offline_page or
>> /sys/devices/system/memory/hard_offline_page. If we don't clear
>> this flag when onlining pages, this page can't be freed, and will
>> not in free list. So we can't offline these pages again. So we
>> should clear this flag when onlining pages.
> 
> This seems wrong fix to me.  After offline, memory may or may not
> change with new one. Thus we can't assume any memory status. Thus,
> we should just forget hwpoison status at _offline_ event.
> 

Yes, agree with you. I will update this patch.

Thanks for reviewing.

Wen Congyang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
