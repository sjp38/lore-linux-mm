Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 010FB6B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 18:21:45 -0400 (EDT)
From: Seiji Aguchi <seiji.aguchi@hds.com>
Date: Thu, 15 Mar 2012 18:10:29 -0400
Subject: RE: [PATCH 0/5] Persist printk buffer across reboots.
Message-ID: <5C4C569E8A4B9B42A84A977CF070A35B2E31C6F891@USINDEVS01.corp.hds.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
 <20120313170851.GA5218@fifo99.com>
 <20120313151049.fa33d232.akpm@linux-foundation.org>
 <20120314021906.GC5218@fifo99.com>
In-Reply-To: <20120314021906.GC5218@fifo99.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <dwalker@fifo99.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Avery Pennarun <apenwarr@gmail.com>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H.
 Peter Anvin" <hpa@linux.intel.com>, Yinghai LU <yinghai@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Luck, Tony (tony.luck@intel.com)" <tony.luck@intel.com>

Hi,

> There is also this series,
>=20
> http://lists.infradead.org/pipermail/kexec/2011-July/005258.html
>=20
> It seems awkward that pstore is in fs/pstore/ then pstore ends up as the =
"back end" where it could just be the whole solution.

I just wanted to avoid deadlocks of pstore and its drivers such as mtdoops,=
 ramoops, and efi_pstore in panic case.
That is still under discussion in lkml.

I have no objection to modifying mtdoops/ram_console to use pstore.

>pstore does seems to have the nicest user interface (might be better in de=
bugfs tho). If someone wanted to move forward with pstore they would have t=
o write some some sort of,
>
>int pstore_register_simple(unsigned long addr, unsigned long size);
>
>to cover all the memory areas that aren't transaction based, or make pstor=
e accept a platform_device.

If you would like to introduce new feature to pstore, Tony Luck is the appr=
opriate person to discuss.

Seiji

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
