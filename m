Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 694156B0068
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 23:04:02 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
Date: Tue, 15 Jan 2013 04:04:01 +0000
Message-ID: <F1CBDF84-6A96-4D07-843F-3353E9029EE6@intel.com>
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>
 <50F440F5.3030006@zytor.com>
 <20130114143456.3962f3bd.akpm@linux-foundation.org>
 <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com>
 <50F4AF88.9090201@jp.fujitsu.com>,<f0b491ad-e520-4b32-8506-1a85a15b2924@email.android.com>
In-Reply-To: <f0b491ad-e520-4b32-8506-1a85a15b2924@email.android.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


>>=20
>> I don't think so because user can easily get raw address by kernel
>> message in x86.
>>=20

Which will fail if on some subsequent boot a DIMM fails BIST and is removed=
 from the memory map by the BIOS which will then change all the mode bounda=
ries for those above the failed DIMM.

-Tony=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
