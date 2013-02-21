Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 61FE56B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 19:23:41 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [Bug fix PATCH 1/2] acpi, movablemem_map: Exclude
 memblock.reserved ranges when parsing SRAT.
Date: Thu, 21 Feb 2013 00:23:39 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1E06B636@ORSMSX108.amr.corp.intel.com>
References: <1361358056-1793-1-git-send-email-tangchen@cn.fujitsu.com>
 <1361358056-1793-2-git-send-email-tangchen@cn.fujitsu.com>
 <5124C22B.8030401@cn.fujitsu.com> <5124C32E.1080902@gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F1E06B55D@ORSMSX108.amr.corp.intel.com>
 <512564B1.8020008@gmail.com>
In-Reply-To: <512564B1.8020008@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "hpa@zytor.com" <hpa@zytor.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> Thanks for your clarify. What's the relationship between memory ranges=20
> and address ranges here?

The ranges in the SRAT table might cover more memory than is present on
the system.  E.g. on some large Itanium systems the SRAT table would say
that 0-1TB was on node0, 1-2TB on node1, etc.

The EFI memory map described the memory actually present (perhaps just
a handful of GB on each node).

X86 systems tend not to have such radically sparse layouts, so this may be =
less
of a distinction.

> What's the relationship between memory/address ranges and /proc/iomem?

I *think* that /proc/iomem just shows what is in e820 (for the memory entri=
es,
it also adds in I/O ranges that come from other ACPI sources).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
