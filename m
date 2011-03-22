Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8CD88D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 23:04:51 -0400 (EDT)
Received: by pwi10 with SMTP id 10so1298900pwi.14
        for <linux-mm@kvack.org>; Mon, 21 Mar 2011 20:04:49 -0700 (PDT)
Subject: Re: [PATCH 3/3] memcg: move page-freeing code outside of lock
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <20110322085938.0691f7f4.kamezawa.hiroyu@jp.fujitsu.com>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
	 <1300452855-10194-3-git-send-email-namhyung@gmail.com>
	 <20110322085938.0691f7f4.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Mar 2011 12:04:39 +0900
Message-ID: <1300763079.1483.21.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011-03-22 (i??), 08:59 +0900, KAMEZAWA Hiroyuki:
> On Fri, 18 Mar 2011 21:54:15 +0900
> Namhyung Kim <namhyung@gmail.com> wrote:
> 
> > Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> What is the benefit of this patch ?
> 
> -Kame
> 

Oh, I just thought generally it'd better call such a (potentially)
costly function outside of locks and it could reduce few of theoretical
contentions between swapons and/or offs. If it doesn't help any
realistic cases I don't mind discarding it.

Thanks.


-- 
Regards,
Namhyung Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
