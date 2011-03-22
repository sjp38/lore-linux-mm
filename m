Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 774E98D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 06:07:06 -0400 (EDT)
Received: by iwl42 with SMTP id 42so9982653iwl.14
        for <linux-mm@kvack.org>; Tue, 22 Mar 2011 03:07:04 -0700 (PDT)
Subject: Re: [PATCH 3/3] memcg: move page-freeing code outside of lock
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <20110322135619.90593f5d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
	 <1300452855-10194-3-git-send-email-namhyung@gmail.com>
	 <20110322085938.0691f7f4.kamezawa.hiroyu@jp.fujitsu.com>
	 <1300763079.1483.21.camel@leonhard>
	 <20110322135619.90593f5d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Mar 2011 19:06:57 +0900
Message-ID: <1300788417.1492.2.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011-03-22 (i??), 13:56 +0900, KAMEZAWA Hiroyuki:
> On Tue, 22 Mar 2011 12:04:39 +0900
> Namhyung Kim <namhyung@gmail.com> wrote:
> 
> > 2011-03-22 (i??), 08:59 +0900, KAMEZAWA Hiroyuki:
> > > On Fri, 18 Mar 2011 21:54:15 +0900
> > > Namhyung Kim <namhyung@gmail.com> wrote:
> > > 
> > > > Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> > > > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > What is the benefit of this patch ?
> > > 
> > > -Kame
> > > 
> > 
> > Oh, I just thought generally it'd better call such a (potentially)
> > costly function outside of locks and it could reduce few of theoretical
> > contentions between swapons and/or offs. If it doesn't help any
> > realistic cases I don't mind discarding it.
> > 
> 
> My point is, please write patch description which shows for what this patc is.
> All cleanup are okay to me if it reasonable. But without patch description as
> "this is just a cleanup, no functional change, and the reason is...."
> we cannot maintain patches.
> 
> Thanks,
> -Kame
> 

OK, I will do that in the future. Anyway, do you want me to resend the
patch with new description?

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
