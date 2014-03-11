Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id C5DB86B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 20:57:35 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so7675147qaj.7
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 17:57:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id h5si6525949qas.20.2014.03.10.17.57.34
        for <linux-mm@kvack.org>;
        Mon, 10 Mar 2014 17:57:35 -0700 (PDT)
Date: Mon, 10 Mar 2014 20:39:54 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: oops in slab/leaks_show
Message-ID: <20140311003954.GA4798@redhat.com>
References: <20140307025703.GA30770@redhat.com>
 <alpine.DEB.2.10.1403071117230.21846@nuc>
 <20140311003459.GA25657@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311003459.GA25657@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>

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

I could reproduce it with a single cat.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
