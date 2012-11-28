Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id E1F076B0078
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 16:34:44 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v2 0/5] Add movablecore_map boot option
Date: Wed, 28 Nov 2012 21:34:43 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com>
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com>
 <50B5CFAE.80103@huawei.com>
In-Reply-To: <50B5CFAE.80103@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>
Cc: "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

> 1. use firmware information
>   According to ACPI spec 5.0, SRAT table has memory affinity structure
>   and the structure has Hot Pluggable Filed. See "5.2.16.2 Memory
>   Affinity Structure". If we use the information, we might be able to
>   specify movable memory by firmware. For example, if Hot Pluggable
>   Filed is enabled, Linux sets the memory as movable memory.
>=20
> 2. use boot option
>   This is our proposal. New boot option can specify memory range to use
>   as movable memory.

Isn't this just moving the work to the user? To pick good values for the
movable areas, they need to know how the memory lines up across
node boundaries ... because they need to make sure to allow some
non-movable memory allocations on each node so that the kernel can
take advantage of node locality.

So the user would have to read at least the SRAT table, and perhaps
more, to figure out what to provide as arguments.

Since this is going to be used on a dynamic system where nodes might
be added an removed - the right values for these arguments might
change from one boot to the next. So even if the user gets them right
on day 1, a month later when a new node has been added, or a broken
node removed the values would be stale.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
