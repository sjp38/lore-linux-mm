Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 485926B005A
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 12:16:19 -0400 (EDT)
Received: by bwz24 with SMTP id 24so2288412bwz.10
        for <linux-mm@kvack.org>; Mon, 26 Oct 2009 09:16:16 -0700 (PDT)
Message-ID: <4AE5CB4E.4090504@gmail.com>
Date: Mon, 26 Oct 2009 17:16:14 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org>	<20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>	<hb2cfu$r08$2@ger.gmane.org>	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>	<4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

> Can I make more questions ?

Sure

>  - What's cpu ?

vendor_id       : AuthenticAMD


cpu family      : 16


model           : 4


model name      : AMD Phenom(tm) II X3 720 Processor


stepping        : 2


cpu MHz         : 3314.812


cache size      : 512 KB


>  - How much memory ?
>  - Do you have swap ?

           total       used       free     shared    buffers     cached
Mem:        3459       1452       2007          0         65        622
-/+ buffers/cache:      764       2695
Swap:          0          0          0

So, no swap. Don't need it.

>  - What's the latest kernel version you tested?

2.6.30-2-amd64 #1 SMP (on Debian)

>  - Could you show me /var/log/dmesg and /var/log/messages at OOM ?

It was catastrophe. :) X crashed (or killed) with all the programs, but
my little program was alive for 20 minutes (see timestamps). And for
that time computer was completely unusable. Couldn't even get the
console via ssh. Rally embarrassing for a modern OS to get destroyed by
a 5 lines of C run as an ordinary user. Luckily screen was still alive,
oomk usually kills it also. See for yourself:

dmesg: http://pastebin.com/f3f83738a
messages: http://pastebin.com/f2091110a

(CCing to lklm again... I just want people to see the logs.)

Regards,

Vedran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
