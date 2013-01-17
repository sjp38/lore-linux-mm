Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 104E86B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 15:27:30 -0500 (EST)
Message-ID: <50F85EAE.20206@jp.fujitsu.com>
Date: Thu, 17 Jan 2013 15:27:26 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com> <50F440F5.3030006@zytor.com> <20130114143456.3962f3bd.akpm@linux-foundation.org> <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com> <20130114144601.1c40dc7e.akpm@linux-foundation.org> <50F647E8.509@jp.fujitsu.com> <20130116132953.6159b673.akpm@linux-foundation.org> <50F72333.60200@jp.fujitsu.com> <50F73111.40009@zytor.com>
In-Reply-To: <50F73111.40009@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, tony.luck@intel.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com, wujianguo@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, rob@landley.net, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 1/16/2013 6:00 PM, H. Peter Anvin wrote:
> On 01/16/2013 02:01 PM, KOSAKI Motohiro wrote:
>>>>>
>>>>> Things I'm wondering:
>>>>>
>>>>> - is there *really* a case for retaining the boot option if/when
>>>>>    SRAT support is available?
>>>>
>>>> Yes. If SRAT support is available, all memory which enabled hotpluggable
>>>> bit are managed by ZONEMOVABLE. But performance degradation may
>>>> occur by NUMA because we can only allocate anonymous page and page-cache
>>>> from these memory.
>>>>
>>>> In this case, if user cannot change SRAT information, user needs a way to
>>>> select/set removable memory manually.
>>>
>>> If I understand this correctly you mean that once SRAT parsing is
>>> implemented, the user can use movablecore_map to override that SRAT
>>> parsing, yes?  That movablecore_map will take precedence over SRAT?
>>
>> I think movablecore_map (I prefer movablemem than it, btw) should behave so.
>> because of, for past three years, almost all memory hotplug bug was handled
>> only I and kamezawa-san and, afaik, both don't have hotremove aware specific
>> hardware.
>>
>> So, if the new feature require specific hardware, we can't maintain this area
>> any more.
>>  
> 
> It is more so than that: the design principle should always be that
> lower-level directives, if present, take precedence over higher-level
> directives.  The reason for that should be pretty obvious: one of the
> main uses of the low-level directives is to override the high-level
> directives due to bugs or debugging needs.

My opinion is close to Kani-san@HP. automatic configuration (i.e. reading
firmware infomation) is best for regular user and low level tunable parameter
is best for developer and workaround of firmware bugs.

Perhaps higher level interface may help some corner case but perhaps not. I mean
I don't put any objection to create higher level interface. I only said I myself
haven't observed such use case. so then i have no opinion about that. So, I wouldn't
join interface discussion even though I don't dislike it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
