Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 311E06B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 16:22:31 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <e60ab548-f0be-4a75-a10b-1f2eb89247a7@default>
Date: Sun, 12 Jul 2009 13:39:07 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [Xen-devel] Re: [RFC PATCH 0/4] (Take 2): transcendent memory
 ("tmem") for Linux
In-Reply-To: <4A5A1A51.2080301@redhat.com>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: npiggin@suse.de, akpm@osdl.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, jeremy@goop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sunil.mushran@oracle.com, chris.mason@oracle.com, Anthony Liguori <anthony@codemonkey.ws>, Schwidefsky <schwidefsky@de.ibm.com>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> CMM2 and tmem are not any different in this regard; both require OS=20
> modification, and both make information available to the=20
> hypervisor.  In=20
> fact CMM2 is much more intrusive (but on the other hand provides much=20
> more information).
>
> > For those that believe it will be pervasive in the
> > future, finding the right balance is a critical step
> > in operating system evolution.
>=20
> You're arguing for CMM2 here IMO.

I'm arguing that both are a good thing and a step in
the right direction.  In some ways, tmem is a bigger
step and in some ways CMM2 is a bigger step.

> My take on this is that precache (predecache?) / preswap can be=20
> implemented even without tmem by using write-through backing for the=20
> virtual disk.  For swap this is actually slight;y more efficient than=20
> tmem preswap, for preuncache slightly less efficient (since=20
> there will=20
> be some double caching).  So I'm more interested in other use=20
> cases of tmem/CMM2.
>=20
> Right, the transient uses of tmem when applied to disk objects=20
> (swap/pagecache) are very similar to disk caches.  Which is=20
> why you can=20
> get a very similar effect when caching your virtual disks;=20
> this can be=20
> done without any guest modification.

Write-through backing and virtual disk cacheing offer a
similar effect, but it is far from the same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
