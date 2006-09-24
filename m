From: Andi Kleen <ak@suse.de>
Subject: Re: One idea to free up page flags on NUMA
Date: Sun, 24 Sep 2006 09:24:42 +0200
References: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com> <200609232043.10434.ak@suse.de> <Pine.LNX.4.64.0609231845380.16383@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609231845380.16383@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609240924.42382.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Sunday 24 September 2006 03:57, Christoph Lameter wrote:
> On Sat, 23 Sep 2006, Andi Kleen wrote:
> > > I just looked at the arch code for i386 and x86_64 and it seems that
> > > both already have page tables for all of memory.
> >
> > i386 doesn't map all of memory.
>
> Hmmm... It only maps the kernel text segment?

Only lowmem (normally upto ~900MB)

But virtual memory is very scarce so I don't know where a new map for mem_map
would come from. Ok you could try to move the physical location of mem_map to 
somewhere not in lowmem I suppose.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
