Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7B48A6B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 21:25:07 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so9680663qgd.1
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 18:25:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id b7si10406202qad.174.2014.03.10.18.25.06
        for <linux-mm@kvack.org>;
        Mon, 10 Mar 2014 18:25:07 -0700 (PDT)
Date: Mon, 10 Mar 2014 21:24:55 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: oops in slab/leaks_show
Message-ID: <20140311012455.GA5151@redhat.com>
References: <20140307025703.GA30770@redhat.com>
 <alpine.DEB.2.10.1403071117230.21846@nuc>
 <20140311003459.GA25657@lge.com>
 <20140311010135.GA25845@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311010135.GA25845@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>

On Tue, Mar 11, 2014 at 10:01:35AM +0900, Joonsoo Kim wrote:
 > On Tue, Mar 11, 2014 at 09:35:00AM +0900, Joonsoo Kim wrote:
 > > On Fri, Mar 07, 2014 at 11:18:30AM -0600, Christoph Lameter wrote:
 > > > Joonsoo recently changed the handling of the freelist in SLAB. CCing him.
 > > > 
 > > > > I pretty much always use SLUB for my fuzzing boxes, but thought I'd give SLAB a try
 > > > > for a change.. It blew up when something tried to read /proc/slab_allocators
 > > > > (Just cat it, and you should see the oops below)
 > > 
 > > Hello, Dave.
 > > 
 > > Today, I did a test on v3.13 which contains all my changes on the handling of
 > > the freelist in SLAB and couldn't trigger oops by just 'cat /proc/slab_allocators'.
 > > 
 > > So I look at the code and find that there is race window if there is multiple users
 > > doing 'cat /proc/slab_allocators'. Did your test do that?
 > 
 > Opps, sorry. I am misunderstanding something. Maybe there is no race.
 > Anyway, How do you test it?

1. build kernel with CONFIG_SLAB=y.
2. boot kernel
3. cat /proc/slab_allocators

that's it.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
