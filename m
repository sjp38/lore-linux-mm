Date: Sat, 25 Mar 2000 00:30:44 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000325003044.F3693@redhat.com>
References: <20000324170828.C3693@redhat.com> <200003241958.OAA03128@ccure.karaya.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200003241958.OAA03128@ccure.karaya.com>; from jdike@karaya.com on Fri, Mar 24, 2000 at 02:58:10PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@karaya.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, lk@tantalophile.demon.co.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Mar 24, 2000 at 02:58:10PM -0500, Jeff Dike wrote:
> 
> Everything appears to work fine, so my conclusion (without delving into the 
> i386 code too deeply) was that the upper kernel maintained them itself without 
> any particular help from the hardware.
> 
> Is this correct?  Should I be dealing with the non-protection bits in the arch 
> layer?

You probably should.  It is impossible to do MAP_SHARED, PROT_WRITE 
regions correctly without dirty bit support, and you don't get 
efficient paging without accessed bit support.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
