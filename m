Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 675376B005A
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 14:16:47 -0400 (EDT)
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n61IHC5S013102
	for <linux-mm@kvack.org>; Wed, 1 Jul 2009 19:17:13 +0100
Received: from gxk21 (gxk21.prod.google.com [10.202.11.21])
	by zps36.corp.google.com with ESMTP id n61IForE028262
	for <linux-mm@kvack.org>; Wed, 1 Jul 2009 11:17:10 -0700
Received: by gxk21 with SMTP id 21so1564693gxk.7
        for <linux-mm@kvack.org>; Wed, 01 Jul 2009 11:17:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090701100412.d59122d9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830906300215q56bda5ccnc99862211dc65289@mail.gmail.com>
	 <20090630182304.8049039c.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830906300918i3e3f8611r6d6fb7873c720c70@mail.gmail.com>
	 <20090701084037.2c3f53f7.nishimura@mxp.nes.nec.co.jp>
	 <20090701090959.4cbdb03e.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830906301727wcb6b292uc3c46451f8844392@mail.gmail.com>
	 <20090701100412.d59122d9.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 1 Jul 2009 11:17:09 -0700
Message-ID: <6599ad830907011117k6cbe0696qffa36401cc23d079@mail.gmail.com>
Subject: Re: [PATCH 2/2] cgroup: exlclude release rmdir
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 6:04 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> BTW, do you have patches for NOOP/signal cgroup we discussed a half year ago ?
>

Yes - very nearly ready. They were sitting gathering dust for a while,
but I've just been polishing them up again this week and am planning
to send them out this week or next.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
