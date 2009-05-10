Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9616B00A2
	for <linux-mm@kvack.org>; Sun, 10 May 2009 09:44:31 -0400 (EDT)
Date: Sun, 10 May 2009 14:45:33 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
 class  citizen
Message-ID: <20090510144533.167010a9@lxorguk.ukuu.org.uk>
In-Reply-To: <2f11576a0905100236u15d45f7fm32d470776659cfec@mail.gmail.com>
References: <20090430181340.6f07421d.akpm@linux-foundation.org>
	<1241432635.7620.4732.camel@twins>
	<20090507121101.GB20934@localhost>
	<20090507151039.GA2413@cmpxchg.org>
	<20090507134410.0618b308.akpm@linux-foundation.org>
	<20090508081608.GA25117@localhost>
	<20090508125859.210a2a25.akpm@linux-foundation.org>
	<20090508230045.5346bd32@lxorguk.ukuu.org.uk>
	<2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
	<1241946446.6317.42.camel@laptop>
	<2f11576a0905100236u15d45f7fm32d470776659cfec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, hannes@cmpxchg.org, riel@redhat.com, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Sun, 10 May 2009 18:36:19 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> I don't oppose this policy. PROT_EXEC seems good viewpoint.

I don't think it is that simple

Not only can it be abused but some systems such as java have large
PROT_EXEC mapped environments, as do many other JIT based languages.

Secondly it moves the pressure from the storage volume holding the system
binaries and libraries to the swap device which already has to deal with
a lot of random (and thus expensive) I/O, as well as the users filestore
for mapped objects there - which may even be on a USB thumbdrive.

I still think the focus is on the wrong thing. We shouldn't be trying to
micro-optimise page replacement guesswork - we should be macro-optimising
the resulting I/O performance. My disks each do 50MBytes/second and even with the
Gnome developers finest creations that ought to be enough if the rest of
the system was working properly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
