Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [RFC 2/3] LVHPT - Setup LVHPT
Date: Tue, 2 May 2006 08:03:16 -0700
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F066076B6@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ian Wienand <ianw@gelato.unsw.edu.au>, linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ian,

Thanks for keeping this alive.  Previous measurements on long
format VHPT were mostly close to neutral performance-wise with
short format ... so this is still waiting for the killer-app in
the form of another patch that actually uses features of the
long format VHPT to do something that can't easily be done by
the short format to give me an incentive to complicate the code
by adding yet another CONFIG option.  In fact, I'd prefer to see
a compelling use case for long format so that it would be clear
that the right thing to do would be to just remove short format
and replace it with long format, but I don't expect that things
will ever be that simple :-(

+ 	help
+ 	  The long format VHPT is an alternative hashed page table. Advantages
+ 	  of the long format VHPT are lower memory usage when there are a large
+ 	  number of processes in the system.

Is this really true?  Don't you still have all of the 3-level (or 4-level)
tree allocated to keep the machine independent code in mm/memory.c
happy in addition to the big block of memory that you are using on
each cpu for the LVHPT?  Where is the saving?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
