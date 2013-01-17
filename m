Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id B6E9F6B0069
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 20:50:33 -0500 (EST)
Message-ID: <50F758BC.5070308@cn.fujitsu.com>
Date: Thu, 17 Jan 2013 09:49:48 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com> <50F440F5.3030006@zytor.com> <20130114143456.3962f3bd.akpm@linux-foundation.org> <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com> <20130114144601.1c40dc7e.akpm@linux-foundation.org> <50F647E8.509@jp.fujitsu.com> <20130116132953.6159b673.akpm@linux-foundation.org> <50F72F17.9030805@zytor.com>
In-Reply-To: <50F72F17.9030805@zytor.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "Luck, Tony" <tony.luck@intel.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/17/2013 06:52 AM, H. Peter Anvin wrote:
> On 01/16/2013 01:29 PM, Andrew Morton wrote:
>>>
>>> Yes. If SRAT support is available, all memory which enabled hotpluggable
>>> bit are managed by ZONEMOVABLE. But performance degradation may
>>> occur by NUMA because we can only allocate anonymous page and page-cache
>>> from these memory.
>>>
>>> In this case, if user cannot change SRAT information, user needs a way to
>>> select/set removable memory manually.
>>
>> If I understand this correctly you mean that once SRAT parsing is
>> implemented, the user can use movablecore_map to override that SRAT
>> parsing, yes?  That movablecore_map will take precedence over SRAT?
>>
>
> Yes,

Hi HPA, Andrew,

No, I don't think so. In my [PATCH v4 3/6], I checked if users specified the
unhotpluggable memory ranges, I will remove them from movablecore_map.map[].
So this option will not override SRAT.

It works like this:

    hotpluggable ranges:            |-----------------|
    unhotpluggable ranges:  |-----|                      |--------|
    user specified ranges:   |---|       |--------------------|
    movablecore_map.map[]:               |------------|

Please refer to https://lkml.org/lkml/2012/12/19/53.

But in this v5 patch-set, I remove all SRAT related code. So this v5 users'
option will override SRAT.


Thanks. :)

>but we still need a higher-level user interface which specifies
> which nodes, not which memory ranges, should be movable.  That is the
> policy granularity that is actually appropriate for the administrator
> (trading off performance vs reliability.)
>
> 	-hpa
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
