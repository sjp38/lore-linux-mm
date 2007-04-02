Date: Mon, 2 Apr 2007 15:49:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <461186A7.2020803@google.com>
Message-ID: <Pine.LNX.4.64.0704021546520.24316@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
 <1175550968.22373.122.camel@localhost.localdomain> <200704030031.24898.ak@suse.de>
 <Pine.LNX.4.64.0704021534100.25602@schroedinger.engr.sgi.com>
 <461186A7.2020803@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Andi Kleen <ak@suse.de>, Dave Hansen <hansendc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Martin Bligh wrote:

> > For 64GB you'd need 256M which would be a quarter of low mem. Probably takes
> > up too much of low mem.
> 
> Yup.

We could move whatever you currently use to handle that into i386 arch 
code. Or are there other platforms that do similar tricks with highmem?

We already have special hooks for node lookups in sparsemem. Move all of 
that off into some arch dir?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
