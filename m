Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A4A8B6B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 21:01:36 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so8054625pad.35
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 18:01:36 -0700 (PDT)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id mp8si18380554pbc.202.2014.03.10.18.01.34
        for <linux-mm@kvack.org>;
        Mon, 10 Mar 2014 18:01:35 -0700 (PDT)
Date: Tue, 11 Mar 2014 10:01:35 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: oops in slab/leaks_show
Message-ID: <20140311010135.GA25845@lge.com>
References: <20140307025703.GA30770@redhat.com>
 <alpine.DEB.2.10.1403071117230.21846@nuc>
 <20140311003459.GA25657@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311003459.GA25657@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Dave Jones <davej@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>

On Tue, Mar 11, 2014 at 09:35:00AM +0900, Joonsoo Kim wrote:
> On Fri, Mar 07, 2014 at 11:18:30AM -0600, Christoph Lameter wrote:
> > Joonsoo recently changed the handling of the freelist in SLAB. CCing him.
> > 
> > On Thu, 6 Mar 2014, Dave Jones wrote:
> > 
> > > I pretty much always use SLUB for my fuzzing boxes, but thought I'd give SLAB a try
> > > for a change.. It blew up when something tried to read /proc/slab_allocators
> > > (Just cat it, and you should see the oops below)
> 
> Hello, Dave.
> 
> Today, I did a test on v3.13 which contains all my changes on the handling of
> the freelist in SLAB and couldn't trigger oops by just 'cat /proc/slab_allocators'.
> 
> So I look at the code and find that there is race window if there is multiple users
> doing 'cat /proc/slab_allocators'. Did your test do that?

Opps, sorry. I am misunderstanding something. Maybe there is no race.
Anyway, How do you test it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
