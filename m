Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 522A56B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 13:46:32 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C554882C36B
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 13:58:22 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XVZycLIuBvhS for <linux-mm@kvack.org>;
	Tue, 28 Apr 2009 13:58:22 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 03FF282C372
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 13:58:18 -0400 (EDT)
Date: Tue, 28 Apr 2009 13:38:01 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Memory/CPU affinity and Nehalem/QPI
In-Reply-To: <606676310904280915i3161fc90h367218482b19bbd6@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0904281337100.13862@qirst.com>
References: <606676310904280915i3161fc90h367218482b19bbd6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Dickinson <andrew@whydna.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Apr 2009, Andrew Dickinson wrote:
> I'm now testing a dual-package Nehalem system.  If I understand this
> architecture correctly, each package's memory controller is driving
> its own bank of RAM.  In my ideal world, I'd be able to provide a hint
> to kmalloc (or friends) such that my encode-table is stored close to
> one package and my decode-table is stored close to the other package.
> Is this something that I can control?  If so, how?  Does this matter
> with Intel's QPI or am I wasting my time?

You would need to configure your kernel with NUMA support. Then the
Nehalem system should boot with two NUMA nodes. The usual NUMA tools can
then be used to select memory allocation (see numactl() etc).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
