Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 39DFD6B0005
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 02:36:51 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3B3003EE0BC
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 16:36:49 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1367045DE5E
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 16:36:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA39F45DE58
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 16:36:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB6701DB8032
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 16:36:48 +0900 (JST)
Received: from g01jpexchkw24.g01.fujitsu.local (g01jpexchkw24.g01.fujitsu.local [10.0.193.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 79F3D1DB804B
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 16:36:48 +0900 (JST)
Message-ID: <50FCEFEC.7060004@jp.fujitsu.com>
Date: Mon, 21 Jan 2013 16:36:12 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>  <50F440F5.3030006@zytor.com>  <20130114143456.3962f3bd.akpm@linux-foundation.org>  <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com>  <20130114144601.1c40dc7e.akpm@linux-foundation.org>  <50F647E8.509@jp.fujitsu.com>  <20130116132953.6159b673.akpm@linux-foundation.org>  <50F72F17.9030805@zytor.com> <50F78750.8070403@jp.fujitsu.com>  <50F79422.6090405@zytor.com>  <3908561D78D1C84285E8C5FCA982C28F1C986D98@ORSMSX108.amr.corp.intel.com>  <50F85ED5.3010003@jp.fujitsu.com> <50F8E63F.5040401@jp.fujitsu.com>  <818a2b0a-f471-413f-9231-6167eb2d9607@email.android.com>  <50F8FBE9.6040501@jp.fujitsu.com>  <50F902F6.5010605@cn.fujitsu.com> <1358501031.22331.10.camel@liguang.fnst.cn.fujitsu.com> <3908561D78D1C84285E8C5FCA982C28F1C988096@ORSMSX108.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C988096@ORSMSX108.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: li guang <lig.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2013/01/19 3:29, Luck, Tony wrote:
>> kernel absolutely should not care much about SMBIOS(DMI info),
>> AFAIK, every BIOS vendor did not fill accurate info in SMBIOS,
>> mostly only on demand when OEMs required SMBIOS to report some
>> specific info.
>> furthermore, SMBIOS is so old and benifit nobody(in my personal
>> opinion), so maybe let's forget it.
>
> The "not having right information" flaw could be fixed by OEMs selling
> systems on which it is important for system functionality that it be right.
> They could use monetary incentives, contractual obligations, or sharp
> pointy sticks to make their BIOS vendor get the table right.
>
> BUT there is a bigger flaw - SMBIOS is a static table with no way to
> update it in response to hotplug events.  So it could in theory have the
> right information at boot time ... there is no possible way for it to be
> right as soon as somebody adds, removes or replaces hardware.

Using DMI information depends on firmware strongly. So even if we
implement boot option which uses DMI information for specifying memory
range as Movable zone, we cannot use it on our box. Other users may
hit same problem.

So we want to keep a current boot option which specifies memory range
since user can know memory address on every box.

Thanks,
Yasuaki Ishimatsu

>
> -Tony
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
