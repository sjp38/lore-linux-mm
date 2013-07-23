Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 1E2486B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 09:47:58 -0400 (EDT)
Date: Tue, 23 Jul 2013 15:47:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm 2013-07-18-16-40 uploaded
Message-ID: <20130723134756.GF8677@dhcp22.suse.cz>
References: <20130718234123.4170F31C022@corp2gmr1-1.hot.corp.google.com>
 <51E8B34B.1070200@gmail.com>
 <20130719180035.GI17812@cmpxchg.org>
 <20130719111744.ce87390c8d8fa6b0b1c52eb6@linux-foundation.org>
 <20130719195812.GJ17812@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130719195812.GJ17812@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Bolle <paul.bollee@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Fri 19-07-13 15:58:12, Johannes Weiner wrote:
> On Fri, Jul 19, 2013 at 11:17:44AM -0700, Andrew Morton wrote:
> > On Fri, 19 Jul 2013 14:00:35 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > > >A git tree which contains the memory management portion of this tree is
> > > > >maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> > > > >by Michal Hocko.  It contains the patches which are between the
> > > > >"#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> > > > >file, http://www.ozlabs.org/~akpm/mmotm/series.
> > > > >
> > > > >
> > > > >A full copy of the full kernel tree with the linux-next and mmotm patches
> > > > >already applied is available through git within an hour of the mmotm
> > > > >release.  Individual mmotm releases are tagged.  The master branch always
> > > > >points to the latest release, so it's constantly rebasing.
> > > > >
> > > > >http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary
> > > > >
> > > > >To develop on top of mmotm git:
> > > > >
> > > > >   $ git remote add mmotm git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> > > > >   $ git remote update mmotm
> > > > >   $ git checkout -b topic mmotm/master
> > > > >   <make changes, commit>
> > > > >   $ git send-email mmotm/master.. [...]
> > > > >
> > > > >To rebase a branch with older patches to a new mmotm release:
> > > > >
> > > > >   $ git remote update mmotm
> > > > >   $ git rebase --onto mmotm/master <topic base> topic
> > > 
> > > Andrew, that workflow is actually meant for
> > > http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary, not Michal's tree
> > > (i.e. the git remote add mmotm <michal's tree> does not make much
> > > sense).  Michal's tree is append-only, so all this precision-rebasing
> > > is unnecessary.
> > 
> > Gee, I haven't looked at that text in a while...
> > 
> > Could you guys please check it, propose any fixes we should make?
> > 
> > 
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> > 
> > You will need quilt to apply these patches to the latest Linus release (3.x
> > or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
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
> 
>                                                                 ^^^
>                                                        on top of the latest
>                                                        Linus release
> 
> maybe?

Yes and also a mention that the lastest since-X.Y branch should be used.
 
[...]
> Michal started his mm.git to have a stable memory management
> development base, yet here is a long section on how to work with the
> much more awkward mmotm.git.  So I wonder if this whole section on how
> to develop against mmotm.git should be removed and only a reference to
> where it could be found left in.
> 
> However, I have actually no idea what people use as an mm development
> base these days...  

I guess Glauber was using it for his shrinker patchset. Few other random
people have asked about the tree in the past but I have no idea how many
people use the tree, to be honest.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
