Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1218D0040
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 22:35:03 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p2Q2Z1TE010894
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 19:35:01 -0700
Received: from iwc10 (iwc10.prod.google.com [10.241.65.138])
	by wpaz33.hot.corp.google.com with ESMTP id p2Q2Yvkp012379
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 19:35:00 -0700
Received: by iwc10 with SMTP id 10so1834178iwc.38
        for <linux-mm@kvack.org>; Fri, 25 Mar 2011 19:34:57 -0700 (PDT)
Date: Fri, 25 Mar 2011 19:34:52 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 0/4] forkbomb killer
Message-ID: <20110326023452.GA8140@google.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
 <20110324105222.GA2625@barrios-desktop>
 <20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
 <20110325115453.82a9736d.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTim3fFe3VzvaWRwzaCT6aRd-yeyfiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTim3fFe3VzvaWRwzaCT6aRd-yeyfiQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Fri, Mar 25, 2011 at 01:05:50PM +0900, Minchan Kim wrote:
> Okay. Each approach has a pros and cons and at least, now anyone
> doesn't provide any method and comments but I agree it is needed(ex,
> careless and lazy admin could need it strongly). Let us wait a little
> bit more. Maybe google guys or redhat/suse guys would have a opinion.

I haven't heard of fork bombs being an issue for us (and it's not been
for me on my desktop, either).

Also, I want to point out that there is a classical userspace solution
for this, as implemented by killall5 for example. One can do
kill(-1, SIGSTOP) to stop all processes that they can send
signals to (except for init and itself). Target processes
can never catch or ignore the SIGSTOP. This stops the fork bomb
from causing further damage. Then, one can look at the process
tree and do whatever is appropriate - including killing by uid,
by cgroup or whatever policies one wants to implement in userspace.
Finally, the remaining processes can be restarted using SIGCONT.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
