Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 14BB06B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 16:51:14 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id cm18so2318325qab.18
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 13:51:13 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id v7si17184308qgv.4.2014.07.14.13.51.13
        for <linux-mm@kvack.org>;
        Mon, 14 Jul 2014 13:51:13 -0700 (PDT)
Date: Mon, 14 Jul 2014 15:51:08 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: vmstat: On demand vmstat workers V8
In-Reply-To: <alpine.LSU.2.11.1407141306150.17828@eggly.anvils>
Message-ID: <alpine.DEB.2.11.1407141550500.29438@gentwo.org>
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org> <20140711132032.GB26045@localhost.localdomain> <alpine.DEB.2.11.1407110855030.25432@gentwo.org> <20140711135854.GD26045@localhost.localdomain> <alpine.DEB.2.11.1407111016040.26485@gentwo.org>
 <20140711151935.GE26045@localhost.localdomain> <alpine.DEB.2.11.1407111022320.26485@gentwo.org> <alpine.LSU.2.11.1407141306150.17828@eggly.anvils>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On Mon, 14 Jul 2014, Hugh Dickins wrote:

> On Fri, 11 Jul 2014, Christoph Lameter wrote:
> > On Fri, 11 Jul 2014, Frederic Weisbecker wrote:
> >
> > > Maybe just merge both? The whole looks good.
> >
> > I hope so. Andrew?
>
> I hope so, too: I know there are idle feckless^Htickless people
> eager for it.  I did take the briefest of looks, but couldn't
> really find any mm change to ack or otherwise: if Frederic is
> happy with it now, seems good to go.

No its all self containted in mm/vmstat.c now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
