Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A8CD56B0044
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 14:23:41 -0500 (EST)
Date: Mon, 14 Jan 2013 11:23:36 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] slub: assign refcount for kmalloc_caches
Message-ID: <20130114192336.GA13038@kroah.com>
References: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com>
 <1356449082-3016-1-git-send-email-js1304@gmail.com>
 <CAAmzW4Nz6if==JjxLQGYwwQwKPDXfUbeioyPHWZQQFNu=xXUeQ@mail.gmail.com>
 <CAAvDA17eH0A_pr9siX7PTipe=Jd7WFZxR7mkUi6K0_djkH=FPA@mail.gmail.com>
 <20130111075253.GB2346@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130111075253.GB2346@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Paul Hargrove <phhargrove@lbl.gov>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Fri, Jan 11, 2013 at 04:52:54PM +0900, Joonsoo Kim wrote:
> On Thu, Jan 10, 2013 at 08:47:39PM -0800, Paul Hargrove wrote:
> > I just had a look at patch-3.7.2-rc1, and this change doesn't appear to
> > have made it in yet.
> > Am I missing something?
> > 
> > -Paul
> 
> I try to check it.
> Ccing to Greg.
> 
> Hello, Pekka and Greg.
> 
> v3.8-rcX has already fixed by another stuff, but it is not simple change.
> So I made a new patch and sent it.
> 
> How this kind of patch (only for stable v3.7) go into stable tree?
> through Pekka's slab tree? or send it to Greg, directly?
> 
> I don't know how to submit this kind of patch to stable tree exactly.
> Could anyone help me?

Please redo it, and send it to stable@vger.kernel.org, and say exactly
why it isn't in Linus's tree, and that it should only be applied to
3.7-stable.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
