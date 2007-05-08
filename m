From: David Howells <dhowells@redhat.com>
In-Reply-To: <20070508115933.GA15074@linux-sh.org> 
References: <20070508115933.GA15074@linux-sh.org>  <Pine.LNX.4.64.0705072037030.4661@schroedinger.engr.sgi.com> <7950.1178620309@redhat.com> 
Subject: Re: Get FRV to be able to run SLUB 
Date: Tue, 08 May 2007 13:04:13 +0100
Message-ID: <9777.1178625853@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Paul Mundt <lethal@linux-sh.org> wrote:

> > That function is void, and is should be passed pgd or something, but I'm not
> > sure what.  No other arch seems to use this.
> > 
> sparc64 uses it now, and others are moving over to it gradually (I just
> converted SH earlier).

Yeah...  I found that after I'd sent the message.  The usage is in the header
files not the arch/ dir.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
