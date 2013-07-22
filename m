Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 280A96B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 11:39:35 -0400 (EDT)
Date: Mon, 22 Jul 2013 11:39:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2013-07-18-16-40 uploaded
Message-ID: <20130722153930.GC715@cmpxchg.org>
References: <20130718234123.4170F31C022@corp2gmr1-1.hot.corp.google.com>
 <51E8B34B.1070200@gmail.com>
 <20130719180035.GI17812@cmpxchg.org>
 <51ED28AC.4080300@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51ED28AC.4080300@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <paul.bollee@gmail.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Mon, Jul 22, 2013 at 08:42:20PM +0800, Paul Bolle wrote:
> On 07/20/2013 02:00 AM, Johannes Weiner wrote:
> >On Thu, Jul 18, 2013 at 11:32:27PM -0400, Paul Bolle wrote:
> >>On 07/18/2013 07:41 PM, akpm@linux-foundation.org wrote:
> >>>The mm-of-the-moment snapshot 2013-07-18-16-40 has been uploaded to
> >>>
> >>>    http://www.ozlabs.org/~akpm/mmotm/
> >>>
> >>>mmotm-readme.txt says
> >>>
> >>>README for mm-of-the-moment:
> >>>
> >>>http://www.ozlabs.org/~akpm/mmotm/
> >>>
> >>>This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> >>>more than once a week.
> >>>
> >>>You will need quilt to apply these patches to the latest Linus release (3.x
> >>>or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> >>>http://ozlabs.org/~akpm/mmotm/series
> >>>
> >>>The file broken-out.tar.gz contains two datestamp files: .DATE and
> >>>.DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> >>>followed by the base kernel version against which this patch series is to
> >>>be applied.
> >>>
> >>>This tree is partially included in linux-next.  To see which patches are
> >>>included in linux-next, consult the `series' file.  Only the patches
> >>>within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
> >>>linux-next.
> >>>
> >>>A git tree which contains the memory management portion of this tree is
> >>>maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> >>>by Michal Hocko.  It contains the patches which are between the
> >>>"#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
> >>>file, http://www.ozlabs.org/~akpm/mmotm/series.
> >>>
> >>>
> >>>A full copy of the full kernel tree with the linux-next and mmotm patches
> >>>already applied is available through git within an hour of the mmotm
> >>>release.  Individual mmotm releases are tagged.  The master branch always
> >>>points to the latest release, so it's constantly rebasing.
> >>>
> >>>http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary
> >>>
> >>>To develop on top of mmotm git:
> >>>
> >>>   $ git remote add mmotm git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> >>>   $ git remote update mmotm
> >>>   $ git checkout -b topic mmotm/master
> >>>   <make changes, commit>
> >>>   $ git send-email mmotm/master.. [...]
> >>>
> >>>To rebase a branch with older patches to a new mmotm release:
> >>>
> >>>   $ git remote update mmotm
> >>>   $ git rebase --onto mmotm/master <topic base> topic
> >Andrew, that workflow is actually meant for
> >http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary, not Michal's tree
> >(i.e. the git remote add mmotm <michal's tree> does not make much
> >sense).  Michal's tree is append-only, so all this precision-rebasing
> >is unnecessary.
> >
> >>The -mm tree is
> >>git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git or
> >>linux-next -mm branch?
> >It depends what you want for the base.  What's in linux-next is based
> >on linux-next, so the latest and greatest.
> >
> >Michal's -mm tree is based on the latest Linus release, and so more
> >stable.  Or at least the craziness is contained to mm stuff.
> 
> -mm branch against linux-next is newer than master branch against
> linux-next. Michal's -mm tree is newer than Linus's tree or older?

It's based on the latest release, so newer than the latest release and
usually older than what's currently in Linus's master branch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
