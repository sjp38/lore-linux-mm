Date: Thu, 23 Dec 2004 15:34:13 -0700 (MST)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: Prezeroing V2 [0/3]: Why and When it works
In-Reply-To: <Pine.LNX.4.58.0412231325420.2654@ppc970.osdl.org>
Message-ID: <Pine.LNX.4.61.0412231522530.7013@montezuma.fsmlabs.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
 <41C20E3E.3070209@yahoo.com.au> <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
 <16843.13418.630413.64809@cargo.ozlabs.ibm.com> <Pine.LNX.4.58.0412231325420.2654@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Paul Mackerras <paulus@samba.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Dec 2004, Linus Torvalds wrote:

> Personally, at least for a desktop usage, I think that the load average 
> would work wonderfully well. I know my machines are often at basically 
> zero load, and then having low-latency zero-pages when I sit down sounds 
> like a good idea. Whether there is _enough_ free memory around for a 
> 5-second thing to work out well, I have no idea..

Isn't the basic premise very similar to the following paper;

http://www.usenix.org/publications/library/proceedings/osdi99/full_papers/dougan/dougan_html/dougan.html

In fact i thought ppc32 did something akin to this.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
