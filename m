Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6E89F6B006A
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 16:51:49 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d05df0b0-e932-4525-8c9e-93f6cb792903@default>
Date: Sun, 12 Jul 2009 14:08:36 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [Xen-devel] Re: [RFC PATCH 0/4] (Take 2): transcendent memory
 ("tmem") for Linux
In-Reply-To: <4A5A4AF2.40609@redhat.com>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org, dave.mccracken@oracle.com, linux-mm@kvack.org, sunil.mushran@oracle.com, alan@lxorguk.ukuu.org.uk, Anthony Liguori <anthony@codemonkey.ws>, Schwidefsky <schwidefsky@de.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> >> Right, the transient uses of tmem when applied to disk objects
> >> (swap/pagecache) are very similar to disk caches.  Which is
> >> why you can
> >> get a very similar effect when caching your virtual disks;
> >> this can be
> >> done without any guest modification.
> >
> > Write-through backing and virtual disk cacheing offer a
> > similar effect, but it is far from the same.
>=20
> Can you explain how it differs for the swap case?  Maybe I don't=20
> understand how tmem preswap works.

The key differences I see are the "please may I store something"
API and the fact that the reply (yes or no) can vary across time
depending on the state of the collective of guests.  Virtual
disk cacheing requires the host to always say yes and always
deliver persistence.  I can see that this is less of a concern
for KVM because the host can swap... though doesn't this hide
information from the guest and potentially have split-brain
swapping issues?

(thanks for the great discussion so far... going offline mostly now
for a few days)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
