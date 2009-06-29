Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A435A6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 16:35:20 -0400 (EDT)
Date: Mon, 29 Jun 2009 22:36:19 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] transcendent memory for Linux
Message-ID: <20090629203619.GA6611@elf.ucw.cz>
References: <20090624150420.GH1784@ucw.cz> <0dbec206-c157-4482-8fd7-4ccf9c2bdc5a@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0dbec206-c157-4482-8fd7-4ccf9c2bdc5a@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>


> It is documented currently at:
> 
> http://oss.oracle.com/projects/tmem/documentation/api/
> 
> (just noticed I still haven't posted version 0.0.2 which
> has a few minor changes).
> 
> I will add a briefer description of this API in Documentation/

Please do.

At least TMEM_NEW_POOL() looks quite ugly. Why uuid? Mixing flags into
size argument is strange.

> It is in-kernel only because some of the operations have
> a parameter that is a physical page frame number.

In-kernel API is probably better described as function prototypes.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
