Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E13FA90013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 12:28:10 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p5LGS6Ec012311
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:28:06 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by wpaz9.hot.corp.google.com with ESMTP id p5LGRcLd002545
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:28:05 -0700
Received: by qwc9 with SMTP id 9so1888287qwc.41
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:28:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E00C483.5080302@5t9.de>
References: <4E00AFE6.20302@5t9.de>
	<BANLkTime3JN9-fAi3Lwx7UdXQo41eQh0iw@mail.gmail.com>
	<4E00C483.5080302@5t9.de>
Date: Tue, 21 Jun 2011 09:28:05 -0700
Message-ID: <BANLkTik50FB_CdSqr15zoyb_Pbxc2PgeBw@mail.gmail.com>
Subject: Re: "make -j" with memory.(memsw.)limit_in_bytes smaller than
 required -> livelock, even for unlimited processes
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lutz Vieweg <lvml@5t9.de>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, Jun 21, 2011 at 9:19 AM, Lutz Vieweg <lvml@5t9.de> wrote:
> On 06/21/2011 06:01 PM, Ying Han wrote:
>>
>> The following patch might not be the root-cause of livelock, but
>> should reduce the [kworker/*] in your case.
>>
>> =A0From d1372da4d3c6f8051b5b1cf7b5e8b45a8094b388 Mon Sep 17 00:00:00 200=
1
>>
>> Can you give a try?
>
> I will first need to move this test to a machine (like my Laptop)
> that I can more aggressively reboot without disturbing the
> developers on the shared hardware. Will do that asap.
>
>> I don't know which kernel you are using in case
>> you don't have this patched yet.
>
> 2.6.39.
> 5 out of 6 hunks in your patch apply to this version, 1 is rejected -
> so I guess I should upgrade to a more recent kernel, first.
> Would 2.6.39.1 be sufficient or would some non-release kernel
> (from which git repository?) be required?

Last time I tried was build on mmotm-2011-05-12-15-52 with the patch.
But I assume you can also
patch it on top of 2.6.39.

Meantime, I am trying to reproduce your livelock on my host with kernbench.

--Ying
>
> Regards,
>
> Lutz Vieweg
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
