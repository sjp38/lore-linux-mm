Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A12239000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 06:26:52 -0400 (EDT)
Subject: Re: [PATCH 4/9] kstaled: minimalistic implementation.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 28 Sep 2011 12:26:13 +0200
In-Reply-To: <CANN689Gtv2B1j6Z5wTk1ysne+XVV8VfU+9jepY1RV4r=B7V_Zw@mail.gmail.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	 <1317170947-17074-5-git-send-email-walken@google.com>
	 <1317195706.5781.1.camel@twins>
	 <CANN689Gtv2B1j6Z5wTk1ysne+XVV8VfU+9jepY1RV4r=B7V_Zw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317205574.20318.1.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Wed, 2011-09-28 at 01:01 -0700, Michel Lespinasse wrote:
> On Wed, Sep 28, 2011 at 12:41 AM, Peter Zijlstra <a.p.zijlstra@chello.nl>=
 wrote:
> > On Tue, 2011-09-27 at 17:49 -0700, Michel Lespinasse wrote:
> >> +static int kstaled(void *dummy)
> >> +{
> >> +       while (1) {
> >
> >> +       }
> >> +
> >> +       BUG();
> >> +       return 0;       /* NOT REACHED */
> >> +}
> >
> > So if you build with this junk (as I presume distro's will), there is n=
o
> > way to disable it?
>=20
> There will be a thread, and it'll block in wait_event_interruptible()
> until a positive value is written into
> /sys/kernel/mm/kstaled/scan_seconds

And here I though people wanted less pointless kernel threads..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
