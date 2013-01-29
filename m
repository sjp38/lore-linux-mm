Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 05ABC6B00A2
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 13:38:05 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 3/3] acpi, memory-hotplug: Support getting hotplug info
 from SRAT.
Date: Tue, 29 Jan 2013 18:38:03 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1C9909DD@ORSMSX108.amr.corp.intel.com>
References: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com>
 <1359106929-3034-4-git-send-email-tangchen@cn.fujitsu.com>
 <20130125171230.34c5a273.akpm@linux-foundation.org>
 <51033186.3000706@zytor.com> <5105DD4B.9020901@cn.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F1C98F9CB@ORSMSX108.amr.corp.intel.com>
 <51076FAC.9060605@cn.fujitsu.com>
In-Reply-To: <51076FAC.9060605@cn.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>> Node 0 (or more specifically the node that contains memory<4GB) will be
>> full of BIOS reserved holes in the memory map.

> One thing I'm not sure, is memory<4GB always on node 0 ?
> On my box, it is on node 0.

I think in practice the <4GB memory will be on node 0 ... but it all depend=
s
on how Linux decides to number the nodes ... which in turn depends on the
order of entries in various BIOS tables.  So it is theoretically possible t=
hat
we'd end up with some system on which the low memory is on some other
node. But it might require stranger than usual BIOS.

Summary: coding "node =3D=3D 0" is almost 100% certain to be right - except
on some pathological systems.  So code for node=3D=3D0 and if we ever see
a pathological machine - we can either point and laugh at the BIOS people
that set that up - or possibly fix our code.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
