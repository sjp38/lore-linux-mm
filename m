Date: Thu, 6 Mar 2008 13:56:24 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
In-Reply-To: <200803062253.00034.Jens.Osterkamp@gmx.de>
Message-ID: <Pine.LNX.4.64.0803061354210.15083@schroedinger.engr.sgi.com>
References: <200803061447.05797.Jens.Osterkamp@gmx.de>
 <200803062207.37654.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803061349220.15083@schroedinger.engr.sgi.com>
 <200803062253.00034.Jens.Osterkamp@gmx.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Mar 2008, Jens Osterkamp wrote:

> > Duh. So this is also in 2.6.23 and 2.6.24?
> 
> Yes, it got in with 2.6.23-rc1.

Then check 2.6.22 and specify the boot parameter "slub_debug". Make sure 
to compile the kernel with slub support. Is there any way you could get 
us further information about the problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
