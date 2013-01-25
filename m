Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id D4D6C6B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 22:32:35 -0500 (EST)
Date: Thu, 24 Jan 2013 22:32:32 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <371722937.9173846.1359084752319.JavaMail.root@redhat.com>
In-Reply-To: <20130114192336.GA13038@kroah.com>
Subject: Re: [PATCH] slub: assign refcount for kmalloc_caches
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Paul Hargrove <phhargrove@lbl.gov>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>



----- Original Message -----
> From: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
> To: "Joonsoo Kim" <iamjoonsoo.kim@lge.com>
> Cc: "Paul Hargrove" <phhargrove@lbl.gov>, "Pekka Enberg" <penberg@kernel.org>, linux-kernel@vger.kernel.org,
> linux-mm@kvack.org, "Christoph Lameter" <cl@linux.com>
> Sent: Tuesday, January 15, 2013 3:23:36 AM
> Subject: Re: [PATCH] slub: assign refcount for kmalloc_caches
> 
> On Fri, Jan 11, 2013 at 04:52:54PM +0900, Joonsoo Kim wrote:
> > On Thu, Jan 10, 2013 at 08:47:39PM -0800, Paul Hargrove wrote:
> > > I just had a look at patch-3.7.2-rc1, and this change doesn't
> > > appear to
> > > have made it in yet.
> > > Am I missing something?
> > > 
> > > -Paul
> > 
> > I try to check it.
> > Ccing to Greg.
> > 
> > Hello, Pekka and Greg.
> > 
> > v3.8-rcX has already fixed by another stuff, but it is not simple
> > change.
> > So I made a new patch and sent it.
> > 
> > How this kind of patch (only for stable v3.7) go into stable tree?
> > through Pekka's slab tree? or send it to Greg, directly?
> > 
> > I don't know how to submit this kind of patch to stable tree
> > exactly.
> > Could anyone help me?
> 
> Please redo it, and send it to stable@vger.kernel.org, and say
> exactly
> why it isn't in Linus's tree, and that it should only be applied to
> 3.7-stable.
I also met this during the testing, so I'll re-send it then.
> 
> thanks,
> 
> greg k-h
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
