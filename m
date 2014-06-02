Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 63CE36B009C
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 19:38:26 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so4402767pad.39
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 16:38:26 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fd3si17607600pbb.179.2014.06.02.16.38.25
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 16:38:25 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 0/3] HWPOISON: improve memory error handling for
 multithread process
Date: Mon, 2 Jun 2014 23:37:58 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F328268B7@ORSMSX114.amr.corp.intel.com>
References: <53877e9c.8b2cdc0a.1604.ffffea43SMTPIN_ADDED_BROKEN@mx.google.com>
	<1401432670-24664-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<3908561D78D1C84285E8C5FCA982C28F32823225@ORSMSX114.amr.corp.intel.com>
	<5388cd0e.463edd0a.755d.6f61SMTPIN_ADDED_BROKEN@mx.google.com>
 <20140602154302.595a54190afdffd4b50f22c2@linux-foundation.org>
In-Reply-To: <20140602154302.595a54190afdffd4b50f22c2@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Kamil Iskra <iskra@mcs.anl.gov>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> I'm not sure that "[PATCH 3/3] mm/memory-failure.c: support dedicated
> thread to handle SIGBUS(BUS_MCEERR_AO)" is a -stable thing?  That's a
> feature addition more than a bugfix?

No - the old behavior was crazy - someone with a multithreaded process migh=
t
well expect that if they call prctl(PF_MCE_EARLY) in just one thread, then =
that
thread would see the SIGBUS  with si_code =3D BUS_MCEERR_A0 - even if that
thread wasn't the main thread for the process.

Perhaps the description for the commit should better reflect that?

-Tony



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
