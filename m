Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A5DCE60021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:42:42 -0500 (EST)
MIME-Version: 1.0
Message-ID: <dfed453e-7cc5-4a17-a45a-fe1d27592615@default>
Date: Mon, 28 Dec 2009 13:41:02 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Tmem [PATCH 0/5] (Take 3): Transcendent memory
In-Reply-To: <20091228205102.GC1637@ucw.cz>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Nitin Gupta <ngupta@vflare.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, chris.mason@oracle.com, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > One feature of frontswap which is different than ramzswap is
> > that frontswap acts as a "fronting store" for all configured
> > swap devices, including SAN/NAS swap devices.  It doesn't
> > need to be separately configured as a "highest priority" swap
> > device.  In many installations and depending on how ramzswap
>=20
> Ok, I'd call it a bug, not a feature :-).
> =09=09=09=09=09=09=09=09Pavel

I agree it has little value (or might be considered a bug)
when managing Linux on a physical machine.  But when
Linux is running in a virtual machine, it's one less thing
that a sysadmin needs to understand and configure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
