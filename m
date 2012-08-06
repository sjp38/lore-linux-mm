Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BF4F46B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 00:47:56 -0400 (EDT)
Date: Mon, 6 Aug 2012 13:49:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] promote zcache from staging
Message-ID: <20120806044918.GA13371@bbox>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
 <20120727205932.GA12650@localhost.localdomain>
 <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
 <20120729015428.GA16643@bbox>
 <20120731153604.GO4789@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120731153604.GO4789@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Tue, Jul 31, 2012 at 11:36:04AM -0400, Konrad Rzeszutek Wilk wrote:
> On Sun, Jul 29, 2012 at 10:54:28AM +0900, Minchan Kim wrote:
> > On Fri, Jul 27, 2012 at 02:42:14PM -0700, Dan Magenheimer wrote:
> > > > From: Konrad Rzeszutek Wilk [mailto:konrad@darnok.org]
> > > > Sent: Friday, July 27, 2012 3:00 PM
> > > > Subject: Re: [PATCH 0/4] promote zcache from staging
> > > > 
> > > > On Fri, Jul 27, 2012 at 12:21:50PM -0700, Dan Magenheimer wrote:
> > > > > > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > > > > > Subject: [PATCH 0/4] promote zcache from staging
> > > > > >
> > > > > > zcache is the remaining piece of code required to support in-kernel
> > > > > > memory compression.  The other two features, cleancache and frontswap,
> > > > > > have been promoted to mainline in 3.0 and 3.5.  This patchset
> > > > > > promotes zcache from the staging tree to mainline.
> > > > > >
> > > > > > Based on the level of activity and contributions we're seeing from a
> > > > > > diverse set of people and interests, I think zcache has matured to the
> > > > > > point where it makes sense to promote this out of staging.
> > > > >
> > > > > Hi Seth --
> > > > >
> > > > > Per offline communication, I'd like to see this delayed for three
> > > > > reasons:
> > > > >
> > > > > 1) I've completely rewritten zcache and will post the rewrite soon.
> > > > >    The redesigned code fixes many of the weaknesses in zcache that
> > > > >    makes it (IMHO) unsuitable for an enterprise distro.  (Some of
> > > > >    these previously discussed in linux-mm [1].)
> > > > > 2) zcache is truly mm (memory management) code and the fact that
> > > > >    it is in drivers at all was purely for logistical reasons
> > > > >    (e.g. the only in-tree "staging" is in the drivers directory).
> > > > >    My rewrite promotes it to (a subdirectory of) mm where IMHO it
> > > > >    belongs.
> > > > > 3) Ramster heavily duplicates code from zcache.  My rewrite resolves
> > > > >    this.  My soon-to-be-post also places the re-factored ramster
> > > > >    in mm, though with some minor work zcache could go in mm and
> > > > >    ramster could stay in staging.
> > > > >
> > > > > Let's have this discussion, but unless the community decides
> > > > > otherwise, please consider this a NACK.
> > > 
> > > Hi Konrad --
> > >  
> > > > Hold on, that is rather unfair. The zcache has been in staging
> > > > for quite some time - your code has not been posted. Part of
> > > > "unstaging" a driver is for folks to review the code - and you
> > > > just said "No, mine is better" without showing your goods.
> > > 
> > > Sorry, I'm not trying to be unfair.  However, I don't see the point
> > > of promoting zcache out of staging unless it is intended to be used
> > > by real users in a real distro.  There's been a lot of discussion,
> > > onlist and offlist, about what needs to be fixed in zcache and not
> > > much visible progress on fixing it.  But fixing it is where I've spent
> > > most of my time over the last couple of months.
> > > 
> > > If IBM or some other company or distro is eager to ship and support
> > > zcache in its current form, I agree that "promote now, improve later"
> > > is a fine approach.  But promoting zcache out of staging simply because
> > > there is urgency to promote zsmalloc+zram out of staging doesn't
> > > seem wise.  At a minimum, it distracts reviewers/effort from what IMHO
> > > is required to turn zcache into an enterprise-ready kernel feature.
> > > 
> > > I can post my "goods" anytime.  In its current form it is better
> > > than the zcache in staging (and, please remember, I wrote both so
> > > I think I am in a good position to compare the two).
> > > I have been waiting until I think the new zcache is feature complete
> > > before asking for review, especially since the newest features
> > > should demonstrate clearly why the rewrite is necessary and
> > > beneficial.  But I can post* my current bits if people don't
> > > believe they exist and/or don't mind reviewing non-final code.
> > > (* Or I can put them in a publicly available git tree.)
> > > 
> > > > There is a third option - which is to continue the promotion
> > > > of zcache from staging, get reviews, work on them ,etc, and
> > > > alongside of that you can work on fixing up (or ripping out)
> > > > zcache1 with zcache2 components as they make sense. Or even
> > > > having two of them - an enterprise and an embedded version
> > > > that will eventually get merged together. There is nothing
> > > > wrong with modifying a driver once it has left staging.
> > > 
> > > Minchan and Seth can correct me if I am wrong, but I believe
> > > zram+zsmalloc, not zcache, is the target solution for embedded.
> > 
> > NOT ture. Some embedded devices use zcache but it's not original
> > zcache but modificated one.
> 
> What kind of modifications? Would it make sense to post the patches

It's for contiguos memory allocation.
For it, it uses only clencache, not frontswap so it could zap ephemeral pages
without latency for getting big contiguos memory.

> for those modifications?

It's another story so at the moment, let's not consider it.
After we got some cleanup, I will revisit it.

> 
> > Anyway, although embedded people use modified zcache, I am biased to Dan.
> > I admit I don't spend lots of time to look zcache but as looking the
> > code, it wasn't good shape and even had a bug found during code review
> > and I felt strongly we should clean up it for promoting it to mm/.
> 
> Do you recall what the bugs where?

From: Minchan Kim <minchan@kernel.org>
Date: Fri, 27 Jul 2012 10:10:31 +0900
Subject: [PATCH] zcache: initialize idr

!CONFIG_FRONTSWAP doesn't initialize idr.
This patch always initialize idr.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zcache/zcache-main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 564873f..a635ee2 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -968,7 +968,7 @@ static void zcache_put_pool(struct tmem_pool *pool)
        atomic_dec(&cli->refcount);
 }
 
-int zcache_new_client(uint16_t cli_id)
+static int zcache_new_client(uint16_t cli_id)
 {
        struct zcache_client *cli;
        int ret = -1; 
@@ -980,11 +980,11 @@ int zcache_new_client(uint16_t cli_id)
        if (cli->zspool)
                goto out;
 
+       idr_init(&cli->tmem_pools);
 #ifdef CONFIG_FRONTSWAP
        cli->zspool = zs_create_pool("zcache", ZCACHE_GFP_MASK);
        if (cli->zspool == NULL)
                goto out;
-       idr_init(&cli->tmem_pools);
 #endif
        ret = 0;
 out:
-- 
1.7.9.5


> 
> > So I would like to wait Dan's posting if you guys are not urgent.
> > (And I am not sure akpm allow it with current shape of zcache code.)
> > But the concern is about adding new feature. I guess there might be some
> > debate for long time and it can prevent promoting again.
> > I think It's not what Seth want.
> > I hope Dan doesn't mix clean up series and new feature series and
> > post clean up series as soon as possible so let's clean up first and
> > try to promote it and later, adding new feature or changing algorithm
> > is desirable.
> > 
> > 
> > > The limitations of zsmalloc aren't an issue for zram but they are
> > > for zcache, and this deficiency was one of the catalysts for the
> > > rewrite.  The issues are explained in more detail in [1],
> > > but if any point isn't clear, I'd be happy to explain further.
> > > 
> > > However, I have limited time for this right now and I'd prefer
> > > to spend it finishing the code. :-}
> > > 
> > > So, as I said, I am still a NACK, but if there are good reasons
> > > to duplicate effort and pursue the "third option", let's discuss
> > > them.
> > > 
> > > Thanks,
> > > Dan
> > > 
> > > [1] http://marc.info/?t=133886706700002&r=1&w=2
> > > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> > -- 
> > Kind regards,
> > Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
