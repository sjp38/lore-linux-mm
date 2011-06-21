Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1FBD66B0143
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 12:19:20 -0400 (EDT)
Message-ID: <4E00C483.5080302@5t9.de>
Date: Tue, 21 Jun 2011 18:19:15 +0200
From: Lutz Vieweg <lvml@5t9.de>
MIME-Version: 1.0
Subject: Re: "make -j" with memory.(memsw.)limit_in_bytes smaller than required
 -> livelock, even for unlimited processes
References: <4E00AFE6.20302@5t9.de> <BANLkTime3JN9-fAi3Lwx7UdXQo41eQh0iw@mail.gmail.com>
In-Reply-To: <BANLkTime3JN9-fAi3Lwx7UdXQo41eQh0iw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On 06/21/2011 06:01 PM, Ying Han wrote:
> The following patch might not be the root-cause of livelock, but
> should reduce the [kworker/*] in your case.
>
>  From d1372da4d3c6f8051b5b1cf7b5e8b45a8094b388 Mon Sep 17 00:00:00 2001
>
> Can you give a try?

I will first need to move this test to a machine (like my Laptop)
that I can more aggressively reboot without disturbing the
developers on the shared hardware. Will do that asap.

> I don't know which kernel you are using in case
> you don't have this patched yet.

2.6.39.
5 out of 6 hunks in your patch apply to this version, 1 is rejected -
so I guess I should upgrade to a more recent kernel, first.
Would 2.6.39.1 be sufficient or would some non-release kernel
(from which git repository?) be required?

Regards,

Lutz Vieweg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
