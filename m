Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 73C3D6B0093
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 19:57:41 -0500 (EST)
Received: by fxm9 with SMTP id 9so1423074fxm.10
        for <linux-mm@kvack.org>; Thu, 28 Jan 2010 16:57:37 -0800 (PST)
Message-ID: <4B62327F.3010208@gmail.com>
Date: Fri, 29 Jan 2010 01:57:35 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>	<20100126151202.75bd9347.akpm@linux-foundation.org>	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>	<20100126161952.ee267d1c.akpm@linux-foundation.org>	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>	<20100128001636.2026a6bc@lxorguk.ukuu.org.uk>	<4B622AEE.3080906@gmail.com> <20100129003547.521a1da9@lxorguk.ukuu.org.uk>
In-Reply-To: <20100129003547.521a1da9@lxorguk.ukuu.org.uk>
Content-Type: multipart/mixed;
 boundary="------------090706020006080103030803"
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090706020006080103030803
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Alan Cox wrote:

> On Fri, 29 Jan 2010 01:25:18 +0100
> Vedran FuraA? <vedran.furac@gmail.com> wrote:
> 
>> Alan Cox wrote:
>>
>>> Am I missing something fundamental here ?
>> Yes, the fact linux mm currently sucks. How else would you explain
>> possibility of killing random (often root owned) processes using a 5
>> lines program started by an ordinary user? 
> 
> If you don't want to run with overcommit you turn it off. At that point
> processes get memory allocations refused if they can overrun the

I've started this discussion with question why overcommit isn't turned
off by default. Problem is that it breaks java and some other stuff that
allocates much more memory than it needs. Very quickly Committed_AS hits
CommitLimit and one cannot allocate any more while there is plenty of
memory still unused.

> theoretical limit, but you generally need more swap (it's one of the
> reasons why things like BSD historically have a '3 * memory' rule).

Say I have 8GB of memory and there's always some free, why would I need
swap?

> So sounds to me like a problem between the keyboard and screen (coupled

Unfortunately it is not. Give me ssh access to your computer (leave
overcommit on) and I'll kill your X with anything running on it.


-- 
http://vedranf.net | a8e7a7783ca0d460fee090cc584adc12

--------------090706020006080103030803
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
--------------090706020006080103030803--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
