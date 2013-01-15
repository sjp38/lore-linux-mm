Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A8A1C8D0001
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 20:23:57 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 128A53EE0C8
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:23:55 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7CE245DEBC
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:23:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B887945DEB6
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:23:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA9E51DB8044
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:23:54 +0900 (JST)
Received: from g01jpexchkw30.g01.fujitsu.local (g01jpexchkw30.g01.fujitsu.local [10.0.193.113])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5ECBB1DB803E
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:23:54 +0900 (JST)
Message-ID: <50F4AF88.9090201@jp.fujitsu.com>
Date: Tue, 15 Jan 2013 10:23:20 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com> <50F440F5.3030006@zytor.com> <20130114143456.3962f3bd.akpm@linux-foundation.org> <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Tang Chen <tangchen@cn.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2013/01/15 7:41, Luck, Tony wrote:
>> hm, why.  Obviously SRAT support will improve things, but is it
>> actually unusable/unuseful with the command line configuration?
>

> Users will want to set these moveable zones along node boundaries
> (the whole purpose is to be able to remove a node by making sure
> the kernel won't allocate anything tricky in it, right?)

Yes

> So raw addresses
> are usable ... but to get them right the user will have to go parse the
> SRAT table manually to come up with the addresses.

I don't think so because user can easily get raw address by kernel
message in x86.

Here are kernel messages of x86 architecture.
---
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x7ffffffff]
[    0.000000] SRAT: Node 1 PXM 2 [mem 0x1000000000-0x17ffffffff]
[    0.000000] SRAT: Node 2 PXM 3 [mem 0x1800000000-0x1fffffffff]
[    0.000000] SRAT: Node 3 PXM 4 [mem 0x2000000000-0x27ffffffff]
[    0.000000] SRAT: Node 4 PXM 5 [mem 0x2800000000-0x2fffffffff]
[    0.000000] SRAT: Node 5 PXM 6 [mem 0x3000000000-0x37ffffffff]
[    0.000000] SRAT: Node 6 PXM 7 [mem 0x3800000000-0x3fffffffff]
[    0.000000] SRAT: Node 7 PXM 1 [mem 0x800000000-0xfffffffff]
---

Thanks,
Yasuaki Ishimatsu

> Any time you
> make the user go off and do some tedious calculation that the computer
> should have done for them is user-abuse.
>
> -Tony
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
