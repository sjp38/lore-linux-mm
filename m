Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 68E726B004F
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 02:35:53 -0400 (EDT)
Date: Thu, 2 Jul 2009 08:38:13 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] transcendent memory for Linux
Message-ID: <20090702063813.GA18157@elf.ucw.cz>
References: <4A4A95D8.6020708@goop.org> <79a405e4-3c4c-4194-aed4-a3832c6c5d6e@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <79a405e4-3c4c-4194-aed4-a3832c6c5d6e@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>, Keir Fraser <keir.fraser@eu.citrix.com>
List-ID: <linux-mm.kvack.org>


> > Yeah, a shared namespace of accessible objects is an entirely 
> > new thing
> > in the Xen universe.  I would also drop Xen support until 
> > there's a good
> > security story about how they can be used.
> 
> While I agree that the security is not bulletproof, I wonder
> if this position might be a bit extreme.  Certainly, the NSA
> should not turn on tmem in a cluster, but that doesn't mean that
> nobody should be allowed to.  I really suspect that there are

This has more problems than "just" security, and yes, security should
be really solved at design time...
											Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
