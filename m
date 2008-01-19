Date: Fri, 18 Jan 2008 20:56:02 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <20080117202024.GA25090@aepfle.de>
Message-ID: <Pine.LNX.4.64.0801182048090.12079@schroedinger.engr.sgi.com>
References: <20080115150949.GA14089@aepfle.de>
 <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com>
 <Pine.LNX.4.64.0801170628580.19208@schroedinger.engr.sgi.com>
 <20080117181222.GA24411@aepfle.de> <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
 <20080117195456.GA24901@aepfle.de> <20080117202024.GA25090@aepfle.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olaf Hering <olaf@aepfle.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jan 2008, Olaf Hering wrote:

> On Thu, Jan 17, Olaf Hering wrote:
> 
> > Since -mm boots further, what patch should I try?
> 
> rc8-mm1 crashes as well, l3 passed to reap_alien() is NULL.

Sigh. It looks like we need alien cache structures in some cases for nodes 
that have no memory. We must allocate structures for all nodes regardless 
if they have allocatable memory or not.

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
