Date: Tue, 26 Sep 2000 17:13:46 -0400 (EDT)
From: Eric Lowe <elowe@myrile.madriver.k12.oh.us>
Subject: Re: the new VMt
In-Reply-To: <20000926180820.E1343@redhat.com>
Message-ID: <Pine.BSF.4.10.10009261710510.10968-100000@myrile.madriver.k12.oh.us>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: yodaiken@fsmlabs.com, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

> > Another approach would be to let user space turn off overcommit.  
> 
> No.  Overcommit only applies to pageable memory.  Beancounter is
> really needed for non-pageable resources such as page tables and
> mlock()ed pages.
> 

In addition to beancounter, do you think pageable page tables are
something we want to tackle in 2.5.x?  4MB page mappings on x86
could be cool too, as an option...

--
Eric Lowe
FibreChannel Software Engineer, Systran Corporation
elowe@systran.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
