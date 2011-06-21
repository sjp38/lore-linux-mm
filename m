Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B609690013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 12:35:31 -0400 (EDT)
Message-ID: <4E00C851.1090307@5t9.de>
Date: Tue, 21 Jun 2011 18:35:29 +0200
From: Lutz Vieweg <lvml@5t9.de>
MIME-Version: 1.0
Subject: Re: "make -j" with memory.(memsw.)limit_in_bytes smaller than required
 -> livelock, even for unlimited processes
References: <4E00AFE6.20302@5t9.de>	<BANLkTime3JN9-fAi3Lwx7UdXQo41eQh0iw@mail.gmail.com>	<4E00C483.5080302@5t9.de> <BANLkTik50FB_CdSqr15zoyb_Pbxc2PgeBw@mail.gmail.com>
In-Reply-To: <BANLkTik50FB_CdSqr15zoyb_Pbxc2PgeBw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On 06/21/2011 06:28 PM, Ying Han wrote:
> Last time I tried was build on mmotm-2011-05-12-15-52 with the patch.
> But I assume you can also
> patch it on top of 2.6.39.

Ok, thanks for that info.

> Meantime, I am trying to reproduce your livelock on my host with kernbench.

I'm not sure you will see a kernel-compile ever spawn enough compile jobs
in parallel to reproduce the problem.

It may be much easier to use the Makefile I attached to my initial
problem report...

Regards,

Lutz Vieweg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
