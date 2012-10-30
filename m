Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id C4C086B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 22:42:33 -0400 (EDT)
Message-ID: <508F3FF2.4080503@cn.fujitsu.com>
Date: Tue, 30 Oct 2012 10:48:18 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/9] clear the memory to store struct page
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>	<1350629202-9664-5-git-send-email-wency@cn.fujitsu.com>	<508A5B66.7000309@cn.fujitsu.com>	<20121029141012.4c1c2b07.akpm@linux-foundation.org>	<508F38E9.1050604@cn.fujitsu.com> <20121029194109.9a910c11.akpm@linux-foundation.org>
In-Reply-To: <20121029194109.9a910c11.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

At 10/30/2012 10:41 AM, Andrew Morton Wrote:
> On Tue, 30 Oct 2012 10:18:17 +0800 Wen Congyang <wency@cn.fujitsu.com> wrote:
> 
>> At 10/30/2012 05:10 AM, Andrew Morton Wrote:
>>> On Fri, 26 Oct 2012 17:44:06 +0800
>>> Wen Congyang <wency@cn.fujitsu.com> wrote:
>>>
>>>> This patch has been acked by kosaki motohiro. Is it OK to be merged
>>>> into -mm tree?
>>>
>>> I'd already merged the v2 patchset when you later sent out the v3
>>> patchset which contains some of the material from v2 plus more things.
>>>
>>> I can drop all of v2 and remerge v3.  But I see from the discussion
>>> under "[PATCH v3 6/9] memory-hotplug: update mce_bad_pages when
>>> removing the memory" that you intend to send out a v4 patchset.
>>
>> OK, I will send out a v4 patchset.
> 
> Thanks.
> 
>> Do I need to resend the patch
>> which is in -mm tree and has no comment?
> 
> I wonder which patch that is!
> 
> Sure, send everything.
> 

OK, I will send everything soon.

Thanks
Wen Congyang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
