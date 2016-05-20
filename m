Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB976B025E
	for <linux-mm@kvack.org>; Fri, 20 May 2016 01:36:31 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id i5so195282170ige.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 22:36:31 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f65si247149itb.61.2016.05.19.22.36.29
        for <linux-mm@kvack.org>;
        Thu, 19 May 2016 22:36:30 -0700 (PDT)
Date: Fri, 20 May 2016 14:36:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: mmotm 2016-05-19-19-59 uploaded
Message-ID: <20160520053628.GB6808@bbox>
References: <573e7da6.pLi6U/36fnX6Drn0%akpm@linux-foundation.org>
 <20160520051417.GA6808@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160520051417.GA6808@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org, jack@suse.cz

Ccing Jan,

dax: Remove complete_unwritten argument

On Fri, May 20, 2016 at 02:14:17PM +0900, Minchan Kim wrote:
> On Thu, May 19, 2016 at 07:59:50PM -0700, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2016-05-19-19-59 has been uploaded to
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
> > 
> > To develop on top of mmotm git:
> > 
> >   $ git remote add mmotm git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> >   $ git remote update mmotm
> >   $ git checkout -b topic mmotm/master
> >   <make changes, commit>
> >   $ git send-email mmotm/master.. [...]
> > 
> > To rebase a branch with older patches to a new mmotm release:
> > 
> >   $ git remote update mmotm
> >   $ git rebase --onto mmotm/master <topic base> topic
> > 
> > 
> > 
> > 
> > The directory http://www.ozlabs.org/~akpm/mmots/ (mm-of-the-second)
> > contains daily snapshots of the -mm tree.  It is updated more frequently
> > than mmotm, and is untested.
> > 
> > A git copy of this tree is available at
> > 
> > 	http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/
> > 
> > and use of this tree is similar to
> > http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/, described above.
> > 
> 
> In first build, I got this.
> 
> In file included from mm/filemap.c:14:0:
> include/linux/dax.h:14:3: error: unknown type name a??dax_iodone_ta??
>    dax_iodone_t);
>    ^
> include/linux/dax.h:16:3: error: unknown type name a??dax_iodone_ta??
>    dax_iodone_t);
>    ^
> include/linux/dax.h:39:5: error: unknown type name a??dax_iodone_ta??
>      dax_iodone_t di)
>      ^
> In file included from mm/vmscan.c:49:0:
> include/linux/dax.h:14:3: error: unknown type name a??dax_iodone_ta??
>    dax_iodone_t);
>    ^
> include/linux/dax.h:16:3: error: unknown type name a??dax_iodone_ta??
>    dax_iodone_t);
>    ^
> include/linux/dax.h:39:5: error: unknown type name a??dax_iodone_ta??
>      dax_iodone_t di)
>      ^
> In file included from mm/truncate.c:12:0:
> include/linux/dax.h:14:3: error: unknown type name a??dax_iodone_ta??
>    dax_iodone_t);
>    ^
> include/linux/dax.h:16:3: error: unknown type name a??dax_iodone_ta??
>    dax_iodone_t);
>    ^
> include/linux/dax.h:39:5: error: unknown type name a??dax_iodone_ta??
>      dax_iodone_t di)
>      ^
> make[1]: *** [mm/truncate.o] Error 1
> make[1]: *** Waiting for unfinished jobs....
> make[1]: *** [mm/filemap.o] Error 1
> make[1]: *** [mm/vmscan.o] Error 1
> make: *** [mm/] Error 2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
