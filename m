Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 56D7D9000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 14:21:18 -0400 (EDT)
Received: by ewy25 with SMTP id 25so1197414ewy.14
        for <linux-mm@kvack.org>; Mon, 19 Sep 2011 11:21:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316455395.16137.160.camel@nimitz>
References: <20110910164134.GA2442@albatros>
	<20110914192744.GC4529@outflux.net>
	<20110918170512.GA2351@albatros>
	<CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
	<20110919144657.GA5928@albatros>
	<CAOJsxLG8gW=BLOptpULsaAEwTravADKbNbXp5e9Wd7xVEfR9AQ@mail.gmail.com>
	<20110919155718.GB16272@albatros>
	<CAOJsxLGZm+npcR0YgXSE2wLC2iXCtzYyCdTDCt1LN=Z28Rm_UA@mail.gmail.com>
	<20110919161837.GA2232@albatros>
	<CAOJsxLE2od0f+6cbL2hA_31CbrqS7AUofx5DT2L9fO_7gxH+PQ@mail.gmail.com>
	<20110919173539.GA3751@albatros>
	<CAOJsxLGc0bwCkDtk2PVe7c155a9wVoDAY0CmYDTLg8_bL4qxqg@mail.gmail.com>
	<1316455395.16137.160.camel@nimitz>
Date: Mon, 19 Sep 2011 21:21:15 +0300
Message-ID: <CAOJsxLFe=i=TUbHuppHTSWPE1DXUw_fSujpR4Kn65_aXr4Hrdg@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 2011-09-19 at 20:51 +0300, Pekka Enberg wrote:
>> How is the attacker able to identify that we kmalloc()'d from ecryptfs o=
r
>> VFS based on non-root /proc/slabinfo when the slab allocator itself does
>> not have that sort of information if you mix up the allocations? Isn't t=
his
>> much stronger protection especially if you combine that with /proc/slabi=
nfo
>> restriction?

On Mon, Sep 19, 2011 at 9:03 PM, Dave Hansen <dave@linux.vnet.ibm.com> wrot=
e:
> Mixing it up just adds noise. =A0It makes the attack somewhat more
> difficult, but it still leaves open the possibility that the attacker
> can filter out the noise somehow.

So that would mean the attacker has somewhat fine-grained control over
kernel memory allocations, no? Can they use /proc/meminfo to deduce
the same kind of information? Should we close that down too?

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
