Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ABD656B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 19:56:10 -0400 (EDT)
Date: Wed, 1 Jul 2009 08:40:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/2] cgroup: exlclude release rmdir
Message-Id: <20090701084037.2c3f53f7.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <6599ad830906300918i3e3f8611r6d6fb7873c720c70@mail.gmail.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830906300215q56bda5ccnc99862211dc65289@mail.gmail.com>
	<20090630182304.8049039c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830906300918i3e3f8611r6d6fb7873c720c70@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jun 2009 09:18:03 -0700, Paul Menage <menage@google.com> wrote:
> On Tue, Jun 30, 2009 at 2:23 AM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > This patch is _not_ tested by Nishimura.
> 
> True, but it's functionally identical to, and simpler than, the one
> that was tested.
> 
I agree.
I'll test with both of these patches folded.


Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
