Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 743116B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 02:08:46 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 Jun 2012 06:02:53 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5F68Pkp64815302
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 16:08:25 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5F68P2V002298
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 16:08:25 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] hugeltb: Mark hugelb_max_hstate __read_mostly
In-Reply-To: <alpine.DEB.2.00.1206141538060.12773@router.home>
References: <1339682178-29059-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120614141257.GQ27397@tiehlicka.suse.cz> <alpine.DEB.2.00.1206141538060.12773@router.home>
Date: Fri, 15 Jun 2012 11:38:22 +0530
Message-ID: <87sjdxm7jd.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

Christoph Lameter <cl@linux.com> writes:

> On Thu, 14 Jun 2012, Michal Hocko wrote:
>
>> On Thu 14-06-12 19:26:18, Aneesh Kumar K.V wrote:
>> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> >
>> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> > ---
>> >  include/linux/hugetlb.h |    2 +-
>> >  mm/hugetlb.c            |    2 +-
>> >  2 files changed, 2 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> > index 9650bb1..0f0877e 100644
>> > --- a/include/linux/hugetlb.h
>> > +++ b/include/linux/hugetlb.h
>> > @@ -23,7 +23,7 @@ struct hugepage_subpool {
>> >  };
>> >
>> >  extern spinlock_t hugetlb_lock;
>> > -extern int hugetlb_max_hstate;
>> > +extern int hugetlb_max_hstate __read_mostly;
>>
>> It should be used only for definition
>
> And a rationale needs to be given. Since this patch had no effect, I would
> think that the patch is just the expression of the belief of the patcher
> that something would improve performancewise.
>
> But there seems to no need for this patch otherwise someone would have
> verified that the patch has the intended beneficial effect on performance.
>

The variable is never modified after boot.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
