Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 427726B005A
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 21:26:19 -0400 (EDT)
Message-ID: <4A4C0D19.4060507@cn.fujitsu.com>
Date: Thu, 02 Jul 2009 09:27:53 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] cgroup: exlclude release rmdir
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>	 <20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>	 <6599ad830906300215q56bda5ccnc99862211dc65289@mail.gmail.com>	 <20090630182304.8049039c.kamezawa.hiroyu@jp.fujitsu.com>	 <6599ad830906300918i3e3f8611r6d6fb7873c720c70@mail.gmail.com>	 <20090701084037.2c3f53f7.nishimura@mxp.nes.nec.co.jp>	 <20090701090959.4cbdb03e.kamezawa.hiroyu@jp.fujitsu.com>	 <6599ad830906301727wcb6b292uc3c46451f8844392@mail.gmail.com>	 <20090701100412.d59122d9.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830907011117k6cbe0696qffa36401cc23d079@mail.gmail.com>
In-Reply-To: <6599ad830907011117k6cbe0696qffa36401cc23d079@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Tue, Jun 30, 2009 at 6:04 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> BTW, do you have patches for NOOP/signal cgroup we discussed a half year ago ?
>>
> 
> Yes - very nearly ready. They were sitting gathering dust for a while,
> but I've just been polishing them up again this week and am planning
> to send them out this week or next.
> 

Glad to hear this. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
