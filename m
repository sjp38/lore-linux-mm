Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 86F0A6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 15:08:44 -0400 (EDT)
Received: by qyk29 with SMTP id 29so5123980qyk.12
        for <linux-mm@kvack.org>; Mon, 29 Jun 2009 12:08:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2f11576a0906291154j727165e0nebdc3813d7af3158@mail.gmail.com>
References: <2f11576a0906290048t29667ae0sd75c96d023b113e2@mail.gmail.com>
	 <26537.1246086769@redhat.com> <20090627125412.GA1667@cmpxchg.org>
	 <20090628113246.GA18409@localhost>
	 <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com>
	 <2f11576a0906280749v25ab725dn8f98fbc1d2e5a5fd@mail.gmail.com>
	 <28c262360906280947o6f9358ddh20ab549e875282a9@mail.gmail.com>
	 <17087.1246279435@redhat.com>
	 <20090629095729.cc9f183c.akpm@linux-foundation.org>
	 <2f11576a0906291154j727165e0nebdc3813d7af3158@mail.gmail.com>
Date: Tue, 30 Jun 2009 04:08:58 +0900
Message-ID: <2f11576a0906291208q4e924258w589c8017ae8a0b6e@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

typo.

> OK. we need learn testcase more.
>
> [read test program source code... ]
>
> this program makes `cat /proc/sys/kernel/msgmni` * 10 processes.
> At least, one process creation need one userland stack page (i.e. one ano=
n)
> + one kernel stack page (i.e. one unaccount page) + one pagetable page.
>
> In my 1GB box environment, =A0default msgmni is 11969.
> Oh well, the system physical ram (255744) is less than needed pages (1196=
9 * 3).

wrong) 11969 * 3
correct) 119690 * 3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
