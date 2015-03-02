Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1626B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 04:21:44 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id vb8so29910613obc.12
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 01:21:44 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id ny8si5976462obc.54.2015.03.02.01.21.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 01:21:43 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 1/2] mem-hotplug: introduce sysfs `range' attribute
Date: Mon, 2 Mar 2015 09:17:14 +0000
Message-ID: <20150302091714.GA32186@hori1.linux.bs1.fc.nec.co.jp>
References: <1425269100-15842-1-git-send-email-shengyong1@huawei.com>
In-Reply-To: <1425269100-15842-1-git-send-email-shengyong1@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <79037CC640F9DC42AA711FE17AEB7352@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sheng Yong <shengyong1@huawei.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "nfont@austin.ibm.com" <nfont@austin.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "zhenzhang.zhang@huawei.com" <zhenzhang.zhang@huawei.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>

# Cced some people maybe interested in this topic.

On Mon, Mar 02, 2015 at 04:04:59AM +0000, Sheng Yong wrote:
> There may be memory holes in a memory section, and because of that we can
> not know the real size of the section. In order to know the physical memo=
ry
> area used int one memory section, we walks through iomem resources and
> report the memory range in /sys/devices/system/memory/memoryX/range, like=
,
>=20
> root@ivybridge:~# cat /sys/devices/system/memory/memory0/range
> 00001000-0008efff
> 00090000-0009ffff
> 00100000-07ffffff
>=20
> Signed-off-by: Sheng Yong <shengyong1@huawei.com>

About a year ago, there was a similar request/suggestion from a library
developer about exporting valid physical address range
(http://thread.gmane.org/gmane.linux.kernel.mm/115600).
Then, we tried some but didn't make it.

So if you try to solve this, please consider some points from that discussi=
on:
- interface name: just 'range' might not be friendly, if the interface retu=
rns
  physicall address range, something like 'phys_addr_range' looks better.
- prefix '0x': if you display the value range in hex, prefixing '0x' might
  be better to avoid letting every parser to add it in itself.
- supporting node range: your patch is now just for memory block interface,=
 but
  someone (like me) are interested in exporting easy "phys_addr <=3D> node =
number"
  mapping, so if your approach is easily extensible to node interface, it w=
ould
  be very nice to include node interface support too.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
