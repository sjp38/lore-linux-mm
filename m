Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA16477
	for <linux-mm@kvack.org>; Wed, 9 Oct 2002 20:05:17 -0700 (PDT)
Message-ID: <3DA4EE6C.6B4184CC@digeo.com>
Date: Wed, 09 Oct 2002 20:05:16 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch] Memory Binding API v0.3 2.5.41
References: <3DA4D3E4.6080401@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE <lse-tech@lists.sourceforge.net>, Martin Bligh <mjbligh@us.ibm.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Matthew Dobson wrote:
> 
> Greetings & Salutations,
>         Here's a wonderful patch that I know you're all dying for...  Memory
> Binding!


Seems reasonable to me.

Could you tell us a bit about the operator's view of this?

I assume that a typical usage scenario would be to bind a process
to a bunch of CPUs and to then bind that process to a bunch of
memblks as well? 

If so, then how does the operator know how to identify those
memblks?  To perform the (cpu list) <-> (memblk list) mapping?

Also, what advantage does this provide over the current node-local
allocation policy?  I'd have thought that once you'd bound a 
process to a CPU (or to a node's CPUs) that as long as the zone
fallback list was right, that process would be getting local memory
pretty much all the time anyway?

Last but not least: you got some benchmark numbers for this?

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
