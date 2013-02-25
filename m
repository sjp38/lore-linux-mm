Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 17C486B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 14:06:28 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [Bug fix PATCH 1/2] acpi, movablemem_map: Exclude
 memblock.reserved ranges when parsing SRAT.
Date: Mon, 25 Feb 2013 19:06:21 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1E06D776@ORSMSX108.amr.corp.intel.com>
References: <1361358056-1793-1-git-send-email-tangchen@cn.fujitsu.com>
 <1361358056-1793-2-git-send-email-tangchen@cn.fujitsu.com>
 <5124C22B.8030401@cn.fujitsu.com> <5124C32E.1080902@gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F1E06B55D@ORSMSX108.amr.corp.intel.com>
 <512ABFF7.9090207@gmail.com>
In-Reply-To: <512ABFF7.9090207@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "hpa@zytor.com" <hpa@zytor.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> What's the meaning of multiple degrees of "distant" here? Eg, there are=20
> ten nodes, can SRAT tell each node which memory on other node is more=20
> close or distant? If the answer is yes, why need SLIT since processes=20
> can use memory close to their nodes.

Small systems can have point to point link between every pair
of nodes.  E.g. a four node system where each node supports
3 links looks like a square with both diagonals drawn in. The
SLIT matrix for such a machine might look like this:

10 20 20 20
20 10 20 20
20 20 10 10
20 20 20 10

Now imagine building an eight node system from these same processors.
We still only have three links available on each node. So we arrange them
like the corners on a cube (with no diagonal lines at all).  Now the latenc=
y
from one node to another may just be one hop along a side, Or perhaps
two hops. Worst case is getting from any corner to the diagonally opposite
one which will take three hops. So the SLIT might look like (where 10 is no
hops, 20 =3D 1 hop 30 =3D2 hops and 40 - 3 hops.

10 20 30 20 30 20 30 40
20 10 20 30 20 30 40 20
30 20 10 20 30 40 30 20
20 30 20 10 40 30 20 30
30 20 30 40 10 20 30 20
20 30 40 20 20 10 30 20
30 40 30 20 30 30 10 20
40 30 20 30 20 30 20 10


> SRAT and SLIT are get from firmware or UEFI?

SRAT and SLIT are part of ACPI - so constructed by firmware. See http://acp=
i.info

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
