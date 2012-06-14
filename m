Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 456896B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 16:43:33 -0400 (EDT)
Date: Thu, 14 Jun 2012 15:43:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] hugeltb: Mark hugelb_max_hstate __read_mostly
In-Reply-To: <20120614141257.GQ27397@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1206141538060.12773@router.home>
References: <1339682178-29059-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120614141257.GQ27397@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

On Thu, 14 Jun 2012, Michal Hocko wrote:

> On Thu 14-06-12 19:26:18, Aneesh Kumar K.V wrote:
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > ---
> >  include/linux/hugetlb.h |    2 +-
> >  mm/hugetlb.c            |    2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > index 9650bb1..0f0877e 100644
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -23,7 +23,7 @@ struct hugepage_subpool {
> >  };
> >
> >  extern spinlock_t hugetlb_lock;
> > -extern int hugetlb_max_hstate;
> > +extern int hugetlb_max_hstate __read_mostly;
>
> It should be used only for definition

And a rationale needs to be given. Since this patch had no effect, I would
think that the patch is just the expression of the belief of the patcher
that something would improve performancewise.

But there seems to no need for this patch otherwise someone would have
verified that the patch has the intended beneficial effect on performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
