Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 30C656B0047
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 12:30:46 -0500 (EST)
Received: by fxm8 with SMTP id 8so2992180fxm.6
        for <linux-mm@kvack.org>; Sat, 30 Jan 2010 09:30:43 -0800 (PST)
Message-ID: <4B646CBE.6050404@gmail.com>
Date: Sat, 30 Jan 2010 18:30:38 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>	<20100126151202.75bd9347.akpm@linux-foundation.org>	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>	<20100126161952.ee267d1c.akpm@linux-foundation.org>	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>	<20100128001636.2026a6bc@lxorguk.ukuu.org.uk>	<4B622AEE.3080906@gmail.com>	<20100129003547.521a1da9@lxorguk.ukuu.org.uk>	<4B62327F.3010208@gmail.com>	<20100129110321.564cb866@lxorguk.ukuu.org.uk>	<4B64272D.8020509@gmail.com> <20100130125917.600beb51@lxorguk.ukuu.org.uk>
In-Reply-To: <20100130125917.600beb51@lxorguk.ukuu.org.uk>
Content-Type: multipart/mixed;
 boundary="------------040608070602050307010304"
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040608070602050307010304
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Alan Cox wrote:

>>> So how about you go and have a complain at the people who are causing
>>> your problem, rather than the kernel.
>> That would pass completely unnoticed and ignored as long as overcommit
>> is enabled by default.
> 
> Defaults are set by the distributions. So you are still complaining to
> the wrong people.

I can't say I'm able to correctly read kernel code, but I believe
default is set by:

int sysctl_overcommit_memory = OVERCOMMIT_GUESS;  /* heuristic overcommit */
int sysctl_overcommit_ratio = 50;       /* default is 50% */
int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;

in mmap.c.

>> So, if you don't want to change the OOM algorithm why not fixing this
>> bug then? And after that change the proc(5) manpage entry for
>> /proc/sys/vm/overcommit_memory into something like:
>>
>> 0: heuristic overcommit (enable this if you have memory problems with
>>                           some buggy software)
>> 1: always overcommit, never check
>> 2: always check, never overcommit (this is the default)
> 
> Because there are a lot of systems where heuristic overcommit makes
> sense ?

Ok, I won't argue any more. Just please watch this short (~1min)
screencast I made and tell me which behavior is good and which is bad
and should be fixed:

http://vedranf.net/tmp/oom.ogv  (you can watch it using VLC for example)

Actually anyone receiving this mail should see it. What do you think,
what will customers rather choose if they see this?

Regards,
Vedran


-- 
http://vedranf.net | a8e7a7783ca0d460fee090cc584adc12

--------------040608070602050307010304
Content-Type: text/x-vcard; charset=utf-8;
 name="vedran_furac.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="vedran_furac.vcf"

YmVnaW46dmNhcmQNCmZuO3F1b3RlZC1wcmludGFibGU6VmVkcmFuIEZ1cmE9QzQ9OEQNCm47
cXVvdGVkLXByaW50YWJsZTpGdXJhPUM0PThEO1ZlZHJhbg0KYWRyOjs7Ozs7O0Nyb2F0aWEN
CmVtYWlsO2ludGVybmV0OnZlZHJhbi5mdXJhY0BnbWFpbC5jb20NCngtbW96aWxsYS1odG1s
OkZBTFNFDQp1cmw6aHR0cDovL3ZlZHJhbmYubmV0DQp2ZXJzaW9uOjIuMQ0KZW5kOnZjYXJk
DQoNCg==
--------------040608070602050307010304--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
