Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8C0126B0085
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:29:38 -0500 (EST)
Received: by fxm8 with SMTP id 8so3732750fxm.6
        for <linux-mm@kvack.org>; Sun, 31 Jan 2010 12:29:36 -0800 (PST)
Message-ID: <4B65E82D.5010408@gmail.com>
Date: Sun, 31 Jan 2010 21:29:33 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
References: <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com> <20100129162137.79b2a6d4@lxorguk.ukuu.org.uk> <c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com> <20100129163030.1109ce78@lxorguk.ukuu.org.uk> <5a0e6098f900aa36993b2b7f2320f927.squirrel@webmail-b.css.fujitsu.com> <alpine.DEB.2.00.1001291258490.2938@chino.kir.corp.google.com> <4B642A40.1020709@gmail.com> <alpine.DEB.2.00.1001301444480.16189@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1001301444480.16189@chino.kir.corp.google.com>
Content-Type: multipart/mixed;
 boundary="------------040708000906000408070205"
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040708000906000408070205
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

David Rientjes wrote:

> On Sat, 30 Jan 2010, Vedran Furac wrote:
> 
>>> The oom killer has been doing this for years and I haven't noticed a huge 
>>> surge in complaints about it killing X specifically because of that code 
>>> in oom_kill_process().
>> Well you said it yourself, you won't see a surge because "oom killer has
>> been doing this *for years*". So you'll have a more/less constant number
>> of complains over the years. Just google for: linux, random, kill, memory;
> 
> You snipped the code segment where I demonstrated that the selected task 
> for oom kill is not necessarily the one chosen to die: if there is a child 
> with disjoint memory that is killable, it will be selected instead.  If 
> Xorg or sshd is being chosen for kill, then you should investigate why 
> that is, but there is nothing random about how the oom killer chooses 
> tasks to kill.

I know that it isn't random, but it sure looks like that to the end user
and I use it to emphasize the problem. And about me investigating, that
simply not possible as I am not a kernel hacker who understands the code
beyond the syntax level. I can only point to the problem in hope that
someone will fix it.

> The facts that you're completely ignoring are that changing the heuristic 
> baseline to rss is not going to prevent Xorg or sshd from being selected 

In my tests a simple "ps -eo rss,command --sort rss" always showed the
cuprit, but OK, find another approach in fixing the problem in hope for
a positive review. Just... I feel everything will be put under the
carpet with fingers in ears while singing everything is fine. Prove me
wrong.

Regards,
Vedran


-- 
http://vedranf.net | a8e7a7783ca0d460fee090cc584adc12

--------------040708000906000408070205
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
--------------040708000906000408070205--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
