From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.7369.601459.308150@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 18:22:17 +0100 (BST)
Subject: Re: MMIO regions
In-Reply-To: <Pine.LNX.4.10.9910061633250.29637-100000@imperial.edgeglobal.com>
References: <14329.390.453805.801086@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9910061633250.29637-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 7 Oct 1999 15:40:32 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> No VM stuff. I think the better approach is with the scheduler. 

The big problem there is threads.  We simply cannot have different VM
setups for different threads of a given process --- threads are
_defined_ as being processes which share the same VM.  The only way to
achieve VM serialisation in a threaded application via the scheduler is
to serialise the threads, which is rather contrary to what you want on
an SMP machine.  CivCTP and Quake 3 are already threaded and SMP-capable
on Linux, for example, and we have a threaded version of the Mesa openGL
libraries too.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
