Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B4F66900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 15:43:59 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so29951129wiw.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 12:43:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si32376717wjx.98.2015.06.02.12.43.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 12:43:58 -0700 (PDT)
Date: Tue, 2 Jun 2015 21:43:54 +0200
From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v12 0/10] Support Write-Through mapping on x86
Message-ID: <20150602194354.GM23057@wotan.suse.de>
References: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
 <20150602162103.GL23057@wotan.suse.de>
 <1433270808.23540.155.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433270808.23540.155.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, hch@lst.de

On Tue, Jun 02, 2015 at 12:46:48PM -0600, Toshi Kani wrote:
> On Tue, 2015-06-02 at 18:21 +0200, Luis R. Rodriguez wrote:
> > On Mon, Jun 01, 2015 at 01:36:23PM -0600, Toshi Kani wrote:
> > > This patchset adds support of Write-Through (WT) mapping on x86.
> > > The study below shows that using WT mapping may be useful for
> > > non-volatile memory.
> > > 
> > > http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf
> > > 
> > > The patchset consists of the following changes.
> > >  - Patch 1/10 to 6/10 add ioremap_wt()
> > >  - Patch 7/10 adds pgprot_writethrough()
> > >  - Patch 8/10 to 9/10 add set_memory_wt()
> > >  - Patch 10/10 changes the pmem driver to call ioremap_wt()
> > > 
> > > All new/modified interfaces have been tested.
> > > 
> > > The patchset is based on:
> > > git://git.kernel.org/pub/scm/linux/kernel/git/bp/bp.git#tip-mm-2
> > 
> > While at it can you also look at:
> >
> > mcgrof@ergon ~/linux-next (git::master)$ git grep -4 "writethrough" drivers/infiniband/
> 
> Thanks for checking this.  The inifiniband driver uses WT mappings on
> powerpc without proper WT interfaces defined. 

Right.

>  They can be cleaned up by
> a separate patch series to support WT on powerpc in the same way after
> this patchset (support WT on x86) is settled.

Who's gonna do that work though? How much work is it ? Is it too much to ask
to roll it in this series?

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
