Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA6A9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 16:25:08 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p8TKP5fT027975
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:25:05 -0700
Received: from qyc1 (qyc1.prod.google.com [10.241.81.129])
	by hpaq13.eem.corp.google.com with ESMTP id p8TKOP04007614
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:25:03 -0700
Received: by qyc1 with SMTP id 1so4530114qyc.11
        for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:25:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110929164319.GA3509@mgebm.net>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<20110929164319.GA3509@mgebm.net>
Date: Thu, 29 Sep 2011 13:25:00 -0700
Message-ID: <CANN689H1G-USQYQrOTb47Hrc7KMjLdxkppYCDKsTUy5WhuRs7w@mail.gmail.com>
Subject: Re: [PATCH 0/9] V2: idle page tracking / working set estimation
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Thu, Sep 29, 2011 at 9:43 AM, Eric B Munson <emunson@mgebm.net> wrote:
> I have been trying to test these patches since yesterday afternoon. =A0Wh=
en my
> machine is idle, they behave fine. =A0I started looking at performance to=
 make
> sure they were a big regression by testing kernel builds with the scanner
> disabled, and then enabled (set to 120 seconds). =A0The scanner disabled =
builds
> work fine, but with the scanner enabled the second time I build my kernel=
 hangs
> my machine every time. =A0Unfortunately, I do not have any more informati=
on than
> that for you at the moment. =A0My next step is to try the same tests in q=
emu to
> see if I can get more state information when the kernel hangs.

Could you please send me your .config file ? Also, did you apply the
patches on top of straight v3.0 and what is your machine like ?

Thanks,

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
