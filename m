Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 982C46B0087
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 10:17:21 -0500 (EST)
From: "Li, Haicheng" <haicheng.li@intel.com>
Date: Sun, 21 Nov 2010 23:16:57 +0800
Subject: RE: [8/8,v3] NUMA Hotplug Emulator: documentation
Message-ID: <789F9655DD1B8F43B48D77C5D30659732FE95E71@shsmsx501.ccr.corp.intel.com>
References: <20101117020759.016741414@intel.com>
 <20101117021000.985643862@intel.com> <20101121150344.GK9099@hack>
In-Reply-To: <20101121150344.GK9099@hack>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: =?iso-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>, "Zheng,
 Shaohui" <shaohui.zheng@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "shaohui.zheng@linux.intel.com" <shaohui.zheng@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Am=E9rico Wang wrote:
> On Wed, Nov 17, 2010 at 10:08:07AM +0800, shaohui.zheng@intel.com
> wrote:=20
>> +2) CPU hotplug emulation:
>> +
>> +The emulator reserve CPUs throu grub parameter, the reserved CPUs
>> can be +hot-add/hot-remove in software method, it emulates the
>> process of physical +cpu hotplug. +
>> +When hotplug a CPU with emulator, we are using a logical CPU to
>> emulate the CPU +socket hotplug process. For the CPU supported SMT,
>> some logical CPUs are in the +same socket, but it may located in
>> different NUMA node after we have emulator. +We put the logical CPU
>> into a fake CPU socket, and assign it an unique +phys_proc_id. For
>> the fake socket, we put one logical CPU in only. + + - to hide CPUs
>> +	- Using boot option "maxcpus=3DN" hide CPUs
>> +	  N is the number of initialize CPUs
>> +	- Using boot option "cpu_hpe=3Don" to enable cpu hotplug emulation
>> +      when cpu_hpe is enabled, the rest CPUs will not be
>> initialized + + - to hot-add CPU to node
>> +	$ echo nid > cpu/probe
>> +
>> + - to hot-remove CPU
>> +	$ echo nid > cpu/release
>> +
>=20
> Again, we already have software CPU hotplug,
> i.e. /sys/devices/system/cpu/cpuX/online.

online here is just for logical CPU online. what we're achieving here is to=
 emulate physical CPU hotadd.


-haicheng=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
