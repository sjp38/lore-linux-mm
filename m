Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 4878D6B0005
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 20:07:07 -0500 (EST)
Message-ID: <50F9F186.5050204@huawei.com>
Date: Sat, 19 Jan 2013 09:06:14 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>  <50F440F5.3030006@zytor.com>  <20130114143456.3962f3bd.akpm@linux-foundation.org>  <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com>  <20130114144601.1c40dc7e.akpm@linux-foundation.org>  <50F647E8.509@jp.fujitsu.com>  <20130116132953.6159b673.akpm@linux-foundation.org>  <50F72F17.9030805@zytor.com> <50F78750.8070403@jp.fujitsu.com>  <50F79422.6090405@zytor.com>  <3908561D78D1C84285E8C5FCA982C28F1C986D98@ORSMSX108.amr.corp.intel.com>  <50F85ED5.3010003@jp.fujitsu.com> <50F8E63F.5040401@jp.fujitsu.com>  <818a2b0a-f471-413f-9231-6167eb2d9607@email.android.com>  <50F8FBE9.6040501@jp.fujitsu.com>  <50F902F6.5010605@cn.fujitsu.com> <1358501031.22331.10.camel@liguang.fnst.cn.fujitsu.com> <3908561D78D1C84285E8C5FCA982C28F1C988096@ORSMSX108.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C988096@ORSMSX108.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: li guang <lig.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2013-1-19 2:29, Luck, Tony wrote:
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

SMBIOS plays an important role when we are trying to do hardware fault
management, because OS needs information from SMBIOS to physically
identify a component/FRU. I also remember there were efforts to extend
SMBIOS specification to dynamically update the SMBIOS table when hotplug
happens.

Regards!
Gerry

> 
> -Tony


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
