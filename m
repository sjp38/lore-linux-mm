Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4117B6B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 06:31:52 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so58282661lfc.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 03:31:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lm8si24787591wjb.147.2016.05.20.03.31.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 03:31:50 -0700 (PDT)
Date: Fri, 20 May 2016 12:31:47 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: mmotm 2016-05-19-19-59 uploaded
Message-ID: <20160520103147.GB1732@quack2.suse.cz>
References: <573e7da6.pLi6U/36fnX6Drn0%akpm@linux-foundation.org>
 <20160520051417.GA6808@bbox>
 <20160520053628.GB6808@bbox>
 <20160519223926.c2a6c169287c048ee78ec151@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160519223926.c2a6c169287c048ee78ec151@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org, jack@suse.cz, "Verma, Vishal L" <vishal.l.verma@intel.com>

On Thu 19-05-16 22:39:26, Andrew Morton wrote:
> 
> Someone stuck a load of for-4.8 stuff into -next during the merge
> window.  It had better be for 4.8 anyway - it is super-late.
> 
> I intend to simply ignore it and merge the for-4.7 material.

I think it was Vishal's tree (CCed) and the conflict is just a trivial
context one. So you can merge whatever you have without concern.

								Honza

> On Fri, 20 May 2016 14:36:28 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Ccing Jan,
> > 
> > dax: Remove complete_unwritten argument
> > 
> > On Fri, May 20, 2016 at 02:14:17PM +0900, Minchan Kim wrote:
> > > On Thu, May 19, 2016 at 07:59:50PM -0700, akpm@linux-foundation.org wrote:
> > > > The mm-of-the-moment snapshot 2016-05-19-19-59 has been uploaded to
> > > > 
> > > >    http://www.ozlabs.org/~akpm/mmotm/
> > > > 
> > > > mmotm-readme.txt says
> > > > 
> > > > README for mm-of-the-moment:
> > > > 
> > > > http://www.ozlabs.org/~akpm/mmotm/
> > > > 
> > > > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > > > more than once a week.
> > > > 
> > > > You will need quilt to apply these patches to the latest Linus release (4.x
> > > > or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> > > > http://ozlabs.org/~akpm/mmotm/series
> > > > 
> > > > The file broken-out.tar.gz contains two datestamp files: .DATE and
> > > > .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> > > > followed by the base kernel version against which this patch series is to
> > > > be applied.
> > > > 
> > > > This tree is partially included in linux-next.  To see which patches are
> > > > included in linux-next, consult the `series' file.  Only the patches
> > > > within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
> > > > linux-next.
> > > > 
> > > > A git tree which contains the memory management portion of this tree is
> > > > maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> > > > by Michal Hocko.  It contains the patches which are between the
> > > > "#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> > > > file, http://www.ozlabs.org/~akpm/mmotm/series.
> > > > 
> > > > 
> > > > A full copy of the full kernel tree with the linux-next and mmotm patches
> > > > already applied is available through git within an hour of the mmotm
> > > > release.  Individual mmotm releases are tagged.  The master branch always
> > > > points to the latest release, so it's constantly rebasing.
> > > > 
> > > > http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/
> > > > 
> > > > To develop on top of mmotm git:
> > > > 
> > > >   $ git remote add mmotm git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> > > >   $ git remote update mmotm
> > > >   $ git checkout -b topic mmotm/master
> > > >   <make changes, commit>
> > > >   $ git send-email mmotm/master.. [...]
> > > > 
> > > > To rebase a branch with older patches to a new mmotm release:
> > > > 
> > > >   $ git remote update mmotm
> > > >   $ git rebase --onto mmotm/master <topic base> topic
> > > > 
> > > > 
> > > > 
> > > > 
> > > > The directory http://www.ozlabs.org/~akpm/mmots/ (mm-of-the-second)
> > > > contains daily snapshots of the -mm tree.  It is updated more frequently
> > > > than mmotm, and is untested.
> > > > 
> > > > A git copy of this tree is available at
> > > > 
> > > > 	http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/
> > > > 
> > > > and use of this tree is similar to
> > > > http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/, described above.
> > > > 
> > > 
> > > In first build, I got this.
> > > 
> > > In file included from mm/filemap.c:14:0:
> > > include/linux/dax.h:14:3: error: unknown type name ___dax_iodone_t___
> > >    dax_iodone_t);
> > >    ^
> > > include/linux/dax.h:16:3: error: unknown type name ___dax_iodone_t___
> > >    dax_iodone_t);
> > >    ^
> > > include/linux/dax.h:39:5: error: unknown type name ___dax_iodone_t___
> > >      dax_iodone_t di)
> > >      ^
> > > In file included from mm/vmscan.c:49:0:
> > > include/linux/dax.h:14:3: error: unknown type name ___dax_iodone_t___
> > >    dax_iodone_t);
> > >    ^
> > > include/linux/dax.h:16:3: error: unknown type name ___dax_iodone_t___
> > >    dax_iodone_t);
> > >    ^
> > > include/linux/dax.h:39:5: error: unknown type name ___dax_iodone_t___
> > >      dax_iodone_t di)
> > >      ^
> > > In file included from mm/truncate.c:12:0:
> > > include/linux/dax.h:14:3: error: unknown type name ___dax_iodone_t___
> > >    dax_iodone_t);
> > >    ^
> > > include/linux/dax.h:16:3: error: unknown type name ___dax_iodone_t___
> > >    dax_iodone_t);
> > >    ^
> > > include/linux/dax.h:39:5: error: unknown type name ___dax_iodone_t___
> > >      dax_iodone_t di)
> > >      ^
> > > make[1]: *** [mm/truncate.o] Error 1
> > > make[1]: *** Waiting for unfinished jobs....
> > > make[1]: *** [mm/filemap.o] Error 1
> > > make[1]: *** [mm/vmscan.o] Error 1
> > > make: *** [mm/] Error 2
> > > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
