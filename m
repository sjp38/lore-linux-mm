Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A57546B0038
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 15:24:39 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id ey11so8539136pad.41
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 12:24:39 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id hh2si27790687pbb.80.2014.09.30.12.24.38
        for <linux-mm@kvack.org>;
        Tue, 30 Sep 2014 12:24:38 -0700 (PDT)
Date: Tue, 30 Sep 2014 15:24:28 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
Message-ID: <20140930192428.GF5098@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <15705.1412070301@turing-police.cc.vt.edu>
 <20140930144854.GA5098@wil.cx>
 <123795.1412088827@turing-police.cc.vt.edu>
 <20140930160841.GB5098@wil.cx>
 <4C30833E5CDF444D84D942543DF65BDA6E047B9B@G4W3303.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C30833E5CDF444D84D942543DF65BDA6E047B9B@G4W3303.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Zuckerman, Boris" <borisz@hp.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Sep 30, 2014 at 05:10:26PM +0000, Zuckerman, Boris wrote:
> > 
> > The more I think about this, the more I think this is a bad idea.
> > When you have a file open with O_DIRECT, your I/O has to be done in 512-byte
> > multiples, and it has to be aligned to 512-byte boundaries in memory.  If an
> > unsuspecting application has O_DIRECT forced on it, it isn't going to know to do that,
> > and so all its I/Os will fail.
> > It'll also be horribly inefficient if a program has the file mmaped.
> > 
> > What problem are you really trying to solve?  Some big files hogging the page cache?
> > --
> 
> Page cache? As another copy in RAM? 
> NV_DIMMs may be viewed as a caching device. This caching can be implemented on the level of NV block/offset or may have some hints from FS and applications. Temporary files is one example. They may not need to hit NV domain ever. Some transactional journals or DB files is another example. They may stay in RAM until power off.

Boris, you're confused.  Valdis is trying to solve an unrelated problem
(and hopes my DAX patches will do it for him).  I'm explaining to him why
what he wants to do is a bad idea.  This tangent is unrelated to NV-DIMMs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
