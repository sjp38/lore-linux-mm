Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F0BFB6B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 12:17:50 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id n5UGIH3v018702
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 17:18:18 +0100
Received: from gxk27 (gxk27.prod.google.com [10.202.11.27])
	by wpaz29.hot.corp.google.com with ESMTP id n5UGIFeG011522
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 09:18:15 -0700
Received: by gxk27 with SMTP id 27so874719gxk.10
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 09:18:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090630182304.8049039c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830906300215q56bda5ccnc99862211dc65289@mail.gmail.com>
	 <20090630182304.8049039c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 30 Jun 2009 09:18:03 -0700
Message-ID: <6599ad830906300918i3e3f8611r6d6fb7873c720c70@mail.gmail.com>
Subject: Re: [PATCH 2/2] cgroup: exlclude release rmdir
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 2:23 AM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This patch is _not_ tested by Nishimura.

True, but it's functionally identical to, and simpler than, the one
that was tested.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
