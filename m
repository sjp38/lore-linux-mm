Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A82389000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:26:31 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so1218185bkb.14
        for <linux-mm@kvack.org>; Thu, 29 Sep 2011 10:26:27 -0700 (PDT)
Date: Thu, 29 Sep 2011 21:25:31 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [kernel-hardening] Re: [PATCH 2/2] mm: restrict access to
 /proc/meminfo
Message-ID: <20110929172531.GA19290@albatros>
References: <20110927175453.GA3393@albatros>
 <20110927175642.GA3432@albatros>
 <20110927193810.GA5416@albatros>
 <alpine.DEB.2.00.1109271459180.13797@router.home>
 <alpine.DEB.2.00.1109271328151.24402@chino.kir.corp.google.com>
 <20110929161848.GA16348@albatros>
 <23921.1317315452@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <23921.1317315452@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, Valdis.Kletnieks@vt.edu
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Thu, Sep 29, 2011 at 12:57 -0400, Valdis.Kletnieks@vt.edu wrote:
> But now he has to fly blind for the next 30 because the numbers will disp=
lay
> exactly the same, and he can't correct for somebody else allocating one s=
o he
> needs to only allocate 29...

You're still talking about "slabinfo", which is already restricted.


And meminfo can be still learned with the same race window (ala seq lock):

    prepare_stuff();
    fill_slabs(); // Here we know counters with KB granularity
    while (number_is_not_ok()) {
        prepare_stuff();
        fill_slabs();
    }
    do_exploit();


Thanks,

--=20
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
