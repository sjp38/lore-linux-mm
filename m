Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD9986B0313
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 12:51:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u110so14270739wrb.14
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 09:51:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 75si4299188wma.1.2017.06.23.09.51.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 09:51:28 -0700 (PDT)
Date: Fri, 23 Jun 2017 18:14:24 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [RFC PATCH 0/4] Support for metadata specific accounting
Message-ID: <20170623161424.GB2866@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1498141404-18807-1-git-send-email-nborisov@suse.com>
 <20170622150848.GA932@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170622150848.GA932@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Nikolay Borisov <nborisov@suse.com>, tj@kernel.org, jbacik@fb.com, jack@suse.cz, jeffm@suse.com, chandan@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, axboe@kernel.dk

On Thu, Jun 22, 2017 at 11:08:49AM -0400, Josef Bacik wrote:
> On Thu, Jun 22, 2017 at 05:23:20PM +0300, Nikolay Borisov wrote:
> > This series is a report of Josef's original posting [1]. I've included 
> > fine-grained changelog in each patch with my changes. Basically, I've forward
> > ported it to 4.12-rc6 and tried incorporating the feedback which was given to 
> > every individual patch (I've included link with that information in each 
> > individual patch). 
> > 
> > The main rationale of pushing this is to enable btrfs' subpage-blocksizes
> > patches to eventually be merged.
> > 
> > This patchset depends on patches (in listed order) which have already
> > been submitted [2] [3] [4]. But overall they don't hamper review. 
> 
> I haven't reposted these patches because they depend on the other work I'm
> doing wrt slab shrinking.  We can't do the sub page blocksize stuff until those
> patches are in, and then I have to re-evaluate this stuff to make sure it still
> makes sense.  Thanks,

What's the rough ETA for all the subpage-blocksize prerequisities? We've
agreed at LSF to postpone any major refactoring and cleanups until the
patchset lands but with more dependencies I think the current subpage
patches would need to be rewritten from scratch anyway.

Delaying for one or two more major releases still sounds doable, but
with current pace of changes I'm afraid that's unrealistic and will just
block other work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
