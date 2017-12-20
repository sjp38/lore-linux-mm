Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 96BAE6B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 13:14:17 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id o43so7626748otd.12
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:14:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i9si5362640oia.89.2017.12.20.10.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 10:14:16 -0800 (PST)
Date: Wed, 20 Dec 2017 19:14:09 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Message-ID: <20171220191409.77a8d006@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1712191855060.24885@nuc-kabylake>
References: <rao.shoaib@oracle.com>
	<1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
	<alpine.DEB.2.20.1712191332090.7876@nuc-kabylake>
	<b38f36d7-be4f-8cc4-208e-f0778077a063@oracle.com>
	<alpine.DEB.2.20.1712191855060.24885@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Rao Shoaib <rao.shoaib@oracle.com>, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, brouer@redhat.com

On Tue, 19 Dec 2017 18:56:51 -0600 (CST)
Christopher Lameter <cl@linux.com> wrote:

> On Tue, 19 Dec 2017, Rao Shoaib wrote:
> 
> > > > mm/slab_common.c  
> > > It would be great to have separate patches so that we can review it
> > > properly:
> > >
> > > 1. Move the code into slab_common.c
> > > 2. The actual code changes to the kfree rcu mechanism
> > > 3. The whitespace changes  
> 
> > I can certainly break down the patch and submit smaller patches as you have
> > suggested.
> >
> > BTW -- This is my first ever patch to Linux, so I am still learning the
> > etiquette.  
> 
> You are doing great. Keep at improving the patches and we will get your
> changes into the kernel source. If you want to sent your first patchset
> then a tool like "quilt" or "git" might be helpful.

When working with patchsets (multiple separate patches, as requested
here), I personally prefer using the tool called Stacked Git[1] (StGit)
command line 'stg', as it allows me to easily adjust patches in the
middle of the patchset "stack".  It is similar to quilt, just git based
itself.

I guess most people on this list use 'git rebase --interactive' when
updating their patchsets (?)

[1] http://procode.org/stgit/doc/tutorial.html
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
