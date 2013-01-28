Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id D3E7A6B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 04:16:45 -0500 (EST)
Message-ID: <510641CC.9040707@cn.fujitsu.com>
Date: Mon, 28 Jan 2013 17:15:56 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] acpi, memory-hotplug: Support getting hotplug info
 from SRAT.
References: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com> <1359106929-3034-4-git-send-email-tangchen@cn.fujitsu.com> <20130125171230.34c5a273.akpm@linux-foundation.org>
In-Reply-To: <20130125171230.34c5a273.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/26/2013 09:12 AM, Andrew Morton wrote:
> On Fri, 25 Jan 2013 17:42:09 +0800
> Tang Chen<tangchen@cn.fujitsu.com>  wrote:
>
>> NOTE: Using this way will cause NUMA performance down because the whole =
node
>>        will be set as ZONE=5FMOVABLE, and kernel cannot use memory on it.
>>        If users don't want to lose NUMA performance, just don't use it.
>
> I agree with this, but it means that nobody will test any of your new cod=
e.
>
> To get improved testing coverage, can you think of any temporary
> testing-only patch which will cause testers to exercise the
> memory-hotplug changes?

Hi Andrew,

OK=EF=BC=8CI=E2=80=98ll think about it and post the testing patch. But I th=
ink a shell=20
script
may be easier because the boot option is specified by user and the code=20
only runs
when system is booting. So we need to reboot the system all the time.

Thanks. :)
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
