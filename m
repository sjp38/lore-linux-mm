Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EA6EE9000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 17:16:32 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p8ULGT2i019398
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 14:16:29 -0700
Received: from qadz30 (qadz30.prod.google.com [10.224.38.30])
	by hpaq6.eem.corp.google.com with ESMTP id p8ULG7jj004267
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 14:16:28 -0700
Received: by qadz30 with SMTP id z30so854617qad.13
        for <linux-mm@kvack.org>; Fri, 30 Sep 2011 14:16:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110930181914.GA17817@mgebm.net>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<20110929164319.GA3509@mgebm.net>
	<CANN689H1G-USQYQrOTb47Hrc7KMjLdxkppYCDKsTUy5WhuRs7w@mail.gmail.com>
	<4186d5662b3fb21af1b45f8a335414d3@mgebm.net>
	<20110930181914.GA17817@mgebm.net>
Date: Fri, 30 Sep 2011 14:16:25 -0700
Message-ID: <CANN689EN8KsBZj_9cABjJoZNou_UegZ8uqB4Lx=uM-B_4aCd7A@mail.gmail.com>
Subject: Re: [PATCH 0/9] V2: idle page tracking / working set estimation
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Fri, Sep 30, 2011 at 11:19 AM, Eric B Munson <emunson@mgebm.net> wrote:
> I am able to recreate on a second desktop I have here (same model CPU but=
 a
> different MB so I am fairly sure it isn't dying hardware). =A0It looks to=
 me like
> a CPU softlocks and it stalls the process active there, so most recently =
that
> was XOrg. =A0The machine lets me login via ssh for a few minutes, but thi=
ngs like
> ps and cat or /proc files will start to work and give some output but han=
g.
> I cannot call reboot, nor can I sync the fs and reboot via SysRq. =A0My n=
ext step
> is to setup a netconsole to see if anything comes out in the syslog that =
I
> cannot see.

I haven't had time to try & reproduce locally yet (apologies - things
have been coming up at me).

But a prime suspect would be a bad interaction with
CONFIG_MEMORY_HOTPLUG, as Kamezama remarked in his reply to patch 4. I
think this could be the most likely cause of what you're observing.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
