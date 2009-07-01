Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C77B6B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 23:39:48 -0400 (EDT)
From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] transcendent memory for Linux
References: <5331ec14-c599-4317-bd5b-55911b8ee916@default>
Date: Tue, 30 Jun 2009 20:41:01 -0700
In-Reply-To: <5331ec14-c599-4317-bd5b-55911b8ee916@default> (Dan Magenheimer's
	message of "Mon, 29 Jun 2009 07:44:50 -0700 (PDT)")
Message-ID: <aday6r9gjea.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>, linux-embedded@vger.kernel.org
List-ID: <linux-mm.kvack.org>


 > One issue though: I would guess that copying pages of memory
 > could be very slow in an inexpensive embedded processor.

And copying memory could very easily burn enough power by keeping the
CPU busy that you lose the incremental gain of turning the memory off
vs. just going to self refresh.  (And the copying latency would easily
be as bad as the transition latency to/from self-refresh).

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
