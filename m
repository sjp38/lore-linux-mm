Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 1F24C6B0022
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 17:41:37 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [Bug fix PATCH 1/2] acpi, movablemem_map: Exclude
 memblock.reserved ranges when parsing SRAT.
Date: Wed, 20 Feb 2013 22:41:34 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1E06B55D@ORSMSX108.amr.corp.intel.com>
References: <1361358056-1793-1-git-send-email-tangchen@cn.fujitsu.com>
 <1361358056-1793-2-git-send-email-tangchen@cn.fujitsu.com>
 <5124C22B.8030401@cn.fujitsu.com> <5124C32E.1080902@gmail.com>
In-Reply-To: <5124C32E.1080902@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "hpa@zytor.com" <hpa@zytor.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> What's the relationship between e820 map and SRAT?

The e820 map (or EFI memory map on some recent systems) provides
a list of memory ranges together with usage information (e.g. reserved
for BIOS, or available) and attributes (WB cacheable, uncacheable).

The SRAT table provides topology information for address ranges. It
tells the OS which memory is close to each cpu, and which is more
distant. If there are multiple degrees of "distant" then the SLIT table
provides a matrix of relative latencies between nodes.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
