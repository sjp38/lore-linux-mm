Date: Fri, 26 Jan 2001 11:53:27 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: How do you determine PA in the X86_PAE mode.
Message-ID: <20010126115327.K11607@redhat.com>
References: <OF0A565D7B.D20E47EA-ON852569DF.00791D69@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF0A565D7B.D20E47EA-ON852569DF.00791D69@pok.ibm.com>; from abali@us.ibm.com on Thu, Jan 25, 2001 at 05:09:40PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jan 25, 2001 at 05:09:40PM -0500, Bulent Abali wrote:
> Given struct page * p, how do you determine the physical page number in the
> CONFIG_X86_PAE mode?
> Is it simply  (p - mem_map)  ?  Thanks for any suggestions.

Yes, but only on i386 machines.  There are other systems which don't
necessarily have all their physical memory arranged sequentially, so
the 2.4 VM avoids using physical page numbers in any of the high-level
code.  You're better off just using the struct page * to reference the
page, and convert that to virtual addresses as you need it.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
