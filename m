Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 96FA76B00B8
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 01:59:42 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so1346051vcb.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 22:59:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.01.1111222145470.8000@trent.utfs.org>
References: <20111121131531.GA1679@x4.trippels.de>
	<1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111121153621.GA1678@x4.trippels.de>
	<1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111121161036.GA1679@x4.trippels.de>
	<1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111121173556.GA1673@x4.trippels.de>
	<1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111121185215.GA1673@x4.trippels.de>
	<20111121195113.GA1678@x4.trippels.de>
	<1321907275.13860.12.camel@pasglop>
	<alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
	<alpine.DEB.2.00.1111212105330.19606@router.home>
	<1321948113.27077.24.camel@edumazet-laptop>
	<1321999085.14573.2.camel@pasglop>
	<alpine.DEB.2.01.1111221511070.8000@trent.utfs.org>
	<1322007501.14573.15.camel@pasglop>
	<alpine.DEB.2.01.1111222145470.8000@trent.utfs.org>
Date: Wed, 23 Nov 2011 08:59:40 +0200
Message-ID: <CAOJsxLGWTRuwQ04Mg26fNhZEmo7yVXG5vSZgF7Q5GESCk65odA@mail.gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Kujau <lists@nerdbynature.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Eric Dumazet <eric.dumazet@gmail.com>, Christoph Lameter <cl@linux.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>

2011/11/23 Christian Kujau <lists@nerdbynature.de>:
> OK, with Christoph's patch applied, 3.2.0-rc2-00274-g6fe4c6d-dirty survives
> on this machine, with the disk & cpu workload that caused the machine to
> panic w/o the patch. Load was at 4-5 this time, which is expected for this
> box. I'll run a few more tests later on, but it seems ok for now.
>
> I couldn't resist and ran "slabinfo" anyway (after the workload!) - the
> box survived, nothing was printed in syslog either. Output attached.

Christoph, Eric, would you mind sending me the final patches that
Christian tested? Maybe CC David too for extra pair of eyes.

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
