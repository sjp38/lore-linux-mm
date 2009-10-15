Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 052606B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 04:50:16 -0400 (EDT)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id n9F8oBSg021841
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 01:50:12 -0700
Received: from pzk11 (pzk11.prod.google.com [10.243.19.139])
	by spaceape13.eur.corp.google.com with ESMTP id n9F8nevI016040
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 01:50:09 -0700
Received: by pzk11 with SMTP id 11so563016pzk.14
        for <linux-mm@kvack.org>; Thu, 15 Oct 2009 01:50:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6599ad830910150037j7aca0020mfbe29d6c03befbf7@mail.gmail.com>
References: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
	 <20091013135027.c60285a8.nishimura@mxp.nes.nec.co.jp>
	 <6599ad830910150037j7aca0020mfbe29d6c03befbf7@mail.gmail.com>
Date: Thu, 15 Oct 2009 01:50:08 -0700
Message-ID: <6599ad830910150150l1eb626d5t1dd3e733469277c2@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/8] cgroup: introduce cancel_attach()
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 15, 2009 at 12:37 AM, Paul Menage <menage@google.com> wrote:
>
> The problem with this API is that the subsystem doesn't know how long
> it needs to hold on to the potential rollback state for.

Sorry, I guess it does - either until the attach() or the
cancel_attach(). (Assuming that the rollback state doesn't involve
holding any spinlocks). It would still be nice to have more comments
in the code changes though.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
