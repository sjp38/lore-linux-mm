Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B5F3C9000BD
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 06:26:33 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p8NAQW6d024982
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 03:26:32 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by wpaz1.hot.corp.google.com with ESMTP id p8NAOZZL002959
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 03:26:31 -0700
Received: by qyk29 with SMTP id 29so6829240qyk.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2011 03:26:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110922161539.d947e014.akpm@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<1316230753-8693-8-git-send-email-walken@google.com>
	<20110922161539.d947e014.akpm@google.com>
Date: Fri, 23 Sep 2011 03:26:30 -0700
Message-ID: <CANN689E7GyTB7RLng9M4aF9vQNOFd8gjLr5fKoWpmOYsM3UJNA@mail.gmail.com>
Subject: Re: [PATCH 7/8] kstaled: add histogram sampling functionality
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 22, 2011 at 4:15 PM, Andrew Morton <akpm@google.com> wrote:
> On Fri, 16 Sep 2011 20:39:12 -0700
> Michel Lespinasse <walken@google.com> wrote:
>
>> add statistics for pages that have been idle for 1,2,5,15,30,60,120 or
>> 240 scan intervals into /dev/cgroup/*/memory.idle_page_stats
>
> Why? =A0What's the use case for this feature?

In the fakenuma implementation of kstaled, we were able to configure a
different scan rate for each container (which was represented in the
kernel as a set of fakenuma nodes, rather than a memory cgroup). This
was used to reclaim memory more agressively from some containers than
others, by varying the interval after which pages would be considered
idle.

In the memcg implementation, scanning is done globally so we can't
configure a per-cgroup rate. Instead, we track the number of scan
cycles that each page has been observed to be idle for. At that point,
we could have a per-cgroup configurable threshold and report pages
that have been idle for longer than that number of scans; however it
seemed nicer to provide a full histogram since the information is
actually available.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
