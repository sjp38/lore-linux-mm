Date: Tue, 8 May 2007 11:07:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Get FRV to be able to run SLUB 
In-Reply-To: <11856.1178647354@redhat.com>
Message-ID: <Pine.LNX.4.64.0705081105570.9941@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705080905020.8722@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705072037030.4661@schroedinger.engr.sgi.com>
 <7950.1178620309@redhat.com>  <11856.1178647354@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 May 2007, David Howells wrote:

> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > > I've added a mostly revised patch, but it still doesn't compile:
> > 
> > How does it fail?
> 
> pgd_free() is still wrong.

Yea but Paul Mundt figured out the problem in the parameters. So does it 
work now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
