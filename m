From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 3 May 2006 07:29:15 +1000
Subject: Re: [RFC 2/3] LVHPT - Setup LVHPT
Message-ID: <20060502212915.GA12900@cse.unsw.EDU.AU>
References: <B8E391BBE9FE384DAA4C5C003888BE6F066076B6@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F066076B6@scsmsx401.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 02, 2006 at 08:03:16AM -0700, Luck, Tony wrote:
> + 	help
> + 	  The long format VHPT is an alternative hashed page table. Advantages
> + 	  of the long format VHPT are lower memory usage when there are a large
> + 	  number of processes in the system.
> 
> Is this really true?  Don't you still have all of the 3-level (or 4-level)
> tree allocated to keep the machine independent code in mm/memory.c
> happy in addition to the big block of memory that you are using on
> each cpu for the LVHPT?  Where is the saving?

Yes that does seem a bit miss-leading.  I guess the point was that
with short format you dedicate the top areas of your region to page
tables for each process, with long format it is static.

-i

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
