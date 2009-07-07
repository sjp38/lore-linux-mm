Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DE65F6B005A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:05:38 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <8422d908-c9e9-4497-82b7-a8532a66fd22@default>
Date: Tue, 7 Jul 2009 13:07:44 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC PATCH 1/4] (Take 2): tmem: Core API between kernel and tmem
In-Reply-To: <4A538A34.7060101@redhat.com>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> From: Rik van Riel [mailto:riel@redhat.com]
> Subject: Re: [RFC PATCH 1/4] (Take 2): tmem: Core API between=20
>=20
> Dan Magenheimer wrote:
> > Tmem [PATCH 1/4] (Take 2): Core API between kernel and tmem
>=20
> I like the cleanup of your patch series.

Thanks much, but credit goes to Jeremy for suggesting this
very clean tmem_ops interface.
=20
> However, what remains is a fair bit of code.

Yes, though much of the LOC is for clean layering and
readability.  (Nearly half of the patch is now comments.)

> It would be good to have performance numbers before
> deciding whether or not to merge all this code.

On one benchmark that I will be presenting at Linux Symposium
(8 dual-VCPU guests with 384MB of initial memory and doing
self-ballooning to constrain memory, each guest compiling
Linux continually; quad-core-dual-thread Nehalem processor
with 4GB physical RAM) I am seeing savings of ~300 IO/sec
at an approximate cost of 0.1%-0.2% of one CPU.  But
I admit much more benchmarking needs to be done.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
