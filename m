Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4C8766B006C
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 01:03:40 -0500 (EST)
Message-ID: <50F79422.6090405@zytor.com>
Date: Wed, 16 Jan 2013 22:03:14 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com> <50F440F5.3030006@zytor.com> <20130114143456.3962f3bd.akpm@linux-foundation.org> <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com> <20130114144601.1c40dc7e.akpm@linux-foundation.org> <50F647E8.509@jp.fujitsu.com> <20130116132953.6159b673.akpm@linux-foundation.org> <50F72F17.9030805@zytor.com> <50F78750.8070403@jp.fujitsu.com>
In-Reply-To: <50F78750.8070403@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/16/2013 09:08 PM, Yasuaki Ishimatsu wrote:
>
> I thought about the method of specifying the node. But I think
> this method is inconvenience. Node number is decided by OS.
> So the number is changed easily.
>
> for example:
>
> o exmaple 1
>    System has 3 nodes:
>    node0, node1, node2
>
>    When user remove node1, the system has:
>    node0, node2
>
>    But after rebooting the system, the system has:
>    node0, node1
>
>    So node2 becomes node1.
>
> o example 2:
>    System has 2 nodes:
>    0x40000000 - 0x7fffffff : node0
>    0xc0000000 - 0xffffffff : node1
>
>    When user add a node wchih memory range is [0x80000000 - 0xbfffffff],
>    system has:
>    0x40000000 - 0x7fffffff : node0
>    0xc0000000 - 0xffffffff : node1
>    0x80000000 - 0xbfffffff : node2
>
>    But after rebooting the system, the system's node may become:
>    0x40000000 - 0x7fffffff : node0
>    0x80000000 - 0xbfffffff : node1
>    0xc0000000 - 0xffffffff : node2
>
>    So node nunber is changed.
>
> Specifying node number may be easy method than specifying memory
> range. But if user uses node number for specifying removable memory,
> user always need to care whether node number is changed or not at
> every hotplug operation.
>


Well, there are only two options:

1. The user doesn't care which nodes are movable.  In that case, the 
user may just want to specify a target as a percentage of memory to make 
movable -- effectively a "slider" on the performance vs. reliability 
spectrum.  The kernel can then assign nodes arbitrarily.

2. If the user *does* care which nodes are movable, then the user needs 
to be able to specify that *in a way that makes sense to the user*. 
This may mean involving the DMI information as well as SRAT in order to 
get "silk screen" type information out.

	-hpa



-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
