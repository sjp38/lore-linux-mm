Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id AF1626B0062
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 01:26:23 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D585E3EE0BC
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 15:26:21 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BCCA945DEB7
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 15:26:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A73EC45DEB2
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 15:26:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BC311DB8038
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 15:26:21 +0900 (JST)
Received: from G01JPEXCHKW21.g01.fujitsu.local (G01JPEXCHKW21.g01.fujitsu.local [10.0.193.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 52D801DB803B
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 15:26:21 +0900 (JST)
Message-ID: <50F647E8.509@jp.fujitsu.com>
Date: Wed, 16 Jan 2013 15:25:44 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com> <50F440F5.3030006@zytor.com> <20130114143456.3962f3bd.akpm@linux-foundation.org> <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com> <20130114144601.1c40dc7e.akpm@linux-foundation.org>
In-Reply-To: <20130114144601.1c40dc7e.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Tang Chen <tangchen@cn.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2013/01/15 7:46, Andrew Morton wrote:
> On Mon, 14 Jan 2013 22:41:03 +0000
> "Luck, Tony" <tony.luck@intel.com> wrote:
>
>>> hm, why.  Obviously SRAT support will improve things, but is it
>>> actually unusable/unuseful with the command line configuration?
>>
>> Users will want to set these moveable zones along node boundaries
>> (the whole purpose is to be able to remove a node by making sure
>> the kernel won't allocate anything tricky in it, right?)  So raw addresses
>> are usable ... but to get them right the user will have to go parse the
>> SRAT table manually to come up with the addresses. Any time you
>> make the user go off and do some tedious calculation that the computer
>> should have done for them is user-abuse.
>>
>
> Sure.  But SRAT configuration is in progress and the boot option is
> better than nothing?

Yes. I think boot option which specifies memory range is necessary.

>
> Things I'm wondering:
>
> - is there *really* a case for retaining the boot option if/when
>    SRAT support is available?

Yes. If SRAT support is available, all memory which enabled hotpluggable
bit are managed by ZONEMOVABLE. But performance degradation may
occur by NUMA because we can only allocate anonymous page and page-cache
from these memory.

In this case, if user cannot change SRAT information, user needs a way to
select/set removable memory manually.

Thanks,
Yasuaki Ishimatsu

>
> - will the boot option be needed for other archictectures, presumably
>    because they don't provide sufficient layout information to the
>    kernel?
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
