Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28F6C6B064F
	for <linux-mm@kvack.org>; Thu, 10 May 2018 21:01:27 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z78-v6so225551qkb.14
        for <linux-mm@kvack.org>; Thu, 10 May 2018 18:01:27 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 93-v6si2058000qks.350.2018.05.10.18.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 18:01:26 -0700 (PDT)
Date: Thu, 10 May 2018 20:01:22 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: mmotm 2018-05-10-16-34 uploaded (objtool)
Message-ID: <20180511010122.xvkjqgx7yye77le3@treble>
References: <20180510233519.eYStA%akpm@linux-foundation.org>
 <aa27dcd5-8121-3da9-a6d8-2108a849986e@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <aa27dcd5-8121-3da9-a6d8-2108a849986e@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>

On Thu, May 10, 2018 at 05:47:32PM -0700, Randy Dunlap wrote:
> On 05/10/2018 04:35 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2018-05-10-16-34 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> > 
> > You will need quilt to apply these patches to the latest Linus release (4.x
> > or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> > http://ozlabs.org/~akpm/mmotm/series
> > 
> > The file broken-out.tar.gz contains two datestamp files: .DATE and
> > .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> > followed by the base kernel version against which this patch series is to
> > be applied.
> > 
> > This tree is partially included in linux-next.  To see which patches are
> > included in linux-next, consult the `series' file.  Only the patches
> > within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
> > linux-next.
> > 
> > A git tree which contains the memory management portion of this tree is
> > maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> > by Michal Hocko.  It contains the patches which are between the
> > "#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> > file, http://www.ozlabs.org/~akpm/mmotm/series.
> > 
> > 
> > A full copy of the full kernel tree with the linux-next and mmotm patches
> > already applied is available through git within an hour of the mmotm
> > release.  Individual mmotm releases are tagged.  The master branch always
> > points to the latest release, so it's constantly rebasing.
> > 
> > http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/
> 
> Hi Josh, Peter:
> 
> Is this something that you already have fixes for?
> 
> 
> on x86_64:
> 
> drivers/video/fbdev/omap2/omapfb/dss/dispc.o: warning: objtool: dispc_runtime_suspend()+0xbb8: sibling call from callable instruction with modified stack frame
> drivers/video/fbdev/omap2/omapfb/dss/dispc.o: warning: objtool: dispc_runtime_resume()+0xcc5: sibling call from callable instruction with modified stack frame

I don't recall seeing that one.  Can you share the .config and/or .o
file?

-- 
Josh
