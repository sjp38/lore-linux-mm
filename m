Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 181D88D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 23:09:37 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so3555465gwa.14
        for <linux-mm@kvack.org>; Mon, 21 Mar 2011 20:09:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1300763079.1483.21.camel@leonhard>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
	<1300452855-10194-3-git-send-email-namhyung@gmail.com>
	<20110322085938.0691f7f4.kamezawa.hiroyu@jp.fujitsu.com>
	<1300763079.1483.21.camel@leonhard>
Date: Tue, 22 Mar 2011 08:39:35 +0530
Message-ID: <AANLkTik7r3naRV6gFfN7+sLAbgAoiMkXwKUwY6nV5FH+@mail.gmail.com>
Subject: Re: [PATCH 3/3] memcg: move page-freeing code outside of lock
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 22, 2011 at 8:34 AM, Namhyung Kim <namhyung@gmail.com> wrote:
>
> 2011-03-22 (=ED=99=94), 08:59 +0900, KAMEZAWA Hiroyuki:
> > On Fri, 18 Mar 2011 21:54:15 +0900
> > Namhyung Kim <namhyung@gmail.com> wrote:
> >
> > > Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> > > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > What is the benefit of this patch ?
> >
> > -Kame
> >
>
> Oh, I just thought generally it'd better call such a (potentially)
> costly function outside of locks and it could reduce few of theoretical
> contentions between swapons and/or offs. If it doesn't help any
> realistic cases I don't mind discarding it.

swapoff is a rare path, I would not worry about it too much at all.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
