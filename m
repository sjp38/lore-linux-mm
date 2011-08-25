Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BAD646B016C
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 13:53:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <75ecaef7-054a-4acd-b1c5-8041ccde3501@default>
Date: Thu, 25 Aug 2011 10:52:18 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V7 2/4] mm: frontswap: core code
References: <20110823145815.GA23190@ca-server1.us.oracle.com>
 <20110825150532.a4d282b1.kamezawa.hiroyu@jp.fujitsu.com
 4E564E4D.4030302@linux.vnet.ibm.com>
In-Reply-To: <4E564E4D.4030302@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, jackdachef@gmail.com, cyclonusj@gmail.com

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> To: KAMEZAWA Hiroyuki
>=20
> On 08/25/2011 01:05 AM, KAMEZAWA Hiroyuki wrote:
> <cut>
> >
> >
> > I'm sorry if I miss codes but.... is an implementation of frontswap.ops=
 included
> > in this patch set ? Or how to test the work ?
>=20
> The zcache driver (in drivers/staging/zcache) is the one that registers f=
rontswap ops.
>=20
> You can test frontswap by enabling CONFIG_FRONTSWAP and CONFIG_ZCACHE, an=
d putting
> "zcache" in the kernel boot parameters.

Also see Xen tmem (in drivers/xen).  I am also working on a related project
called RAMster that uses frontswap.  And someone has started code for KVM
to work with transcendent memory (including frontswap).  But for now zcache
is the only non-virtualization in-kernel user for frontswap.

Dan

P.S. A recent build fix for zcache is necessary for it to work without
manual modification to the zcache Makefile.
See 8c70aac04e01a08b7eca204312946206d1c1baac in Linus's tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
