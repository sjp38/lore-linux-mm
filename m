Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AF9CA6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 20:04:34 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6E0VWl5010779
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Jul 2009 09:31:33 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FE1A45DE50
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 09:31:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CDDF45DE51
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 09:31:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A5A7E18004
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 09:31:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E6AA01DB8041
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 09:31:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] Memory usage limit notification feature (v3)
In-Reply-To: <6599ad830907131720j4f7e1649y4866d2ddeae862c5@mail.gmail.com>
References: <1247530581-31416-1-git-send-email-vbuzov@embeddedalley.com> <6599ad830907131720j4f7e1649y4866d2ddeae862c5@mail.gmail.com>
Message-Id: <20090714093023.6280.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 14 Jul 2009 09:31:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Vladislav Buzov <vbuzov@embeddedalley.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers Mailing List <containers@lists.linux-foundation.org>, Linux memory management list <linux-mm@kvack.org>, Dan Malek <dan@embeddedalley.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> On Mon, Jul 13, 2009 at 5:16 PM, Vladislav
> Buzov<vbuzov@embeddedalley.com> wrote:
> >
> > The following sequence of patches introduce memory usage limit notification
> > capability to the Memory Controller cgroup.
> >
> > This is v3 of the implementation. The major difference between previous
> > version is it is based on the the Resource Counter extension to notify the
> > Resource Controller when the resource usage achieves or exceeds a configurable
> > threshold.
> >
> > TODOs:
> >
> > 1. Another, more generic notification mechanism supporting different  events
> >   is preferred to use, rather than creating a dedicated file in the Memory
> >   Controller cgroup.
> 
> I think that defining the the more generic userspace-API portion of
> this TODO should come *prior* to the new feature in this patch, even
> if the kernel implementation isn't initially generic.

I fully agree this ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
