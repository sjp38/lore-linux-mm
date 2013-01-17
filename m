Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 57C4B6B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 15:20:59 -0500 (EST)
Message-ID: <50F85D25.6030003@jp.fujitsu.com>
Date: Thu, 17 Jan 2013 15:20:53 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com> <50F440F5.3030006@zytor.com> <20130114143456.3962f3bd.akpm@linux-foundation.org> <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com> <20130114144601.1c40dc7e.akpm@linux-foundation.org> <50F647E8.509@jp.fujitsu.com> <20130116132953.6159b673.akpm@linux-foundation.org> <50F72F17.9030805@zytor.com> <50F758BC.5070308@cn.fujitsu.com>
In-Reply-To: <50F758BC.5070308@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tangchen@cn.fujitsu.com
Cc: hpa@zytor.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, tony.luck@intel.com, jiang.liu@huawei.com, wujianguo@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 1/16/2013 8:49 PM, Tang Chen wrote:
> On 01/17/2013 06:52 AM, H. Peter Anvin wrote:
>> On 01/16/2013 01:29 PM, Andrew Morton wrote:
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
>>>
>>
>> Yes,
> 
> Hi HPA, Andrew,
> 
> No, I don't think so. In my [PATCH v4 3/6], I checked if users specified the
> unhotpluggable memory ranges, I will remove them from movablecore_map.map[].
> So this option will not override SRAT.
> 
> It works like this:
> 
>     hotpluggable ranges:            |-----------------|
>     unhotpluggable ranges:  |-----|                      |--------|
>     user specified ranges:   |---|       |--------------------|
>     movablecore_map.map[]:               |------------|
> 
> Please refer to https://lkml.org/lkml/2012/12/19/53.
> 
> But in this v5 patch-set, I remove all SRAT related code. So this v5 users'
> option will override SRAT.

Again, boot option is often used for workaround of firmware bugs. so, if you
make a boot option, it should be override firmware info.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
