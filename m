Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 514F69000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 14:03:44 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8JI0KhC027004
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 12:00:20 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8JI3Nol179946
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 12:03:28 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8JI2voI018043
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 12:02:58 -0600
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to
 /proc/slabinfo
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <CAOJsxLGc0bwCkDtk2PVe7c155a9wVoDAY0CmYDTLg8_bL4qxqg@mail.gmail.com>
References: <20110910164134.GA2442@albatros>
	 <20110914192744.GC4529@outflux.net>	<20110918170512.GA2351@albatros>
	 <CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
	 <20110919144657.GA5928@albatros>
	 <CAOJsxLG8gW=BLOptpULsaAEwTravADKbNbXp5e9Wd7xVEfR9AQ@mail.gmail.com>
	 <20110919155718.GB16272@albatros>
	 <CAOJsxLGZm+npcR0YgXSE2wLC2iXCtzYyCdTDCt1LN=Z28Rm_UA@mail.gmail.com>
	 <20110919161837.GA2232@albatros>
	 <CAOJsxLE2od0f+6cbL2hA_31CbrqS7AUofx5DT2L9fO_7gxH+PQ@mail.gmail.com>
	 <20110919173539.GA3751@albatros>
	 <CAOJsxLGc0bwCkDtk2PVe7c155a9wVoDAY0CmYDTLg8_bL4qxqg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 19 Sep 2011 11:03:15 -0700
Message-ID: <1316455395.16137.160.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 2011-09-19 at 20:51 +0300, Pekka Enberg wrote:
> How is the attacker able to identify that we kmalloc()'d from ecryptfs or
> VFS based on non-root /proc/slabinfo when the slab allocator itself does
> not have that sort of information if you mix up the allocations? Isn't this
> much stronger protection especially if you combine that with /proc/slabinfo
> restriction? 

Mixing it up just adds noise.  It makes the attack somewhat more
difficult, but it still leaves open the possibility that the attacker
can filter out the noise somehow.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
