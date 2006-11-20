Date: Mon, 20 Nov 2006 08:20:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/7] Remove declaration of sighand_cachep from slab.h
In-Reply-To: <20061118172739.30538d16.sfr@canb.auug.org.au>
Message-ID: <Pine.LNX.4.64.0611200817020.16173@schroedinger.engr.sgi.com>
References: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
 <20061118054347.8884.36259.sendpatchset@schroedinger.engr.sgi.com>
 <20061118172739.30538d16.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Sat, 18 Nov 2006, Stephen Rothwell wrote:

> Is there no suitable header file to put this in?

There is only a single file that uses sighand_cachep apart from where it 
was defined. If we would add it to signal.h then we would also have to
add an include for slab.h just for this statement. I cannot imagine
any reason why one would have to use sighand_cachep outside of those two 
files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
