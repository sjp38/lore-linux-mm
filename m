From: Andi Kleen <ak@suse.de>
Subject: Re: [discuss] Memory performance problems on Tyan VX50
Date: Wed, 1 Feb 2006 18:16:34 +0100
References: <43DF7654.6060807@t-platforms.ru> <200602011539.40368.ak@suse.de> <Pine.LNX.4.62.0602010900200.16613@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0602010900200.16613@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602011816.35114.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: discuss@x86-64.org, Andrey Slepuhin <pooh@t-platforms.ru>, Ray Bryant <raybry@mpdtxmail.amd.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wednesday 01 February 2006 18:03, Christoph Lameter wrote:
> On Wed, 1 Feb 2006, Andi Kleen wrote:
> 
> > Looks like a bug. There were changes both in the page allocator and in
> > mempolicy in 2.6.16rc, so it might be related to that.
> > What does this wheremem program do exactly?
> > And what does numastat --hardware say on the machine?
> > 
> > Either it's generally broken in page alloc or mempolicy somehow managed to pass in
> > a NULL zonelist. 
> 
> The failure is in __rmqueue. AFAIK There is no influence of mempolicy on 
> that one.

I haven't followed it in all details, but it could be if the zonelist
is empty and rmqueue is the first to notice?

Or MPOL_BIND makes it just easier to trigger OOM
(maybe it would be a good idea to add some hack to prevent the oom
killer from running when the OOM comes from a non standard numa policy)


> Could we get an accurate pointer to the statement that is  
> causing the NULL deref?

Andrey, can you recompile the kernel with CONFIG_DEBUG_INFO and 
do a addr2line -e vmlinux <RIP from oops> ? 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
