Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 2D6686B0005
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 09:11:49 -0500 (EST)
Date: Thu, 7 Mar 2013 15:11:46 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] hugetlb: fix sparse warning for hugetlb_register_node
In-Reply-To: <CAEnQRZAiiJqHcEHoS+=ZMAHdQwu9yYc28or1Di7h4R7PRn6iEg@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1303071511090.28677@pobox.suse.cz>
References: <1362393975-22533-1-git-send-email-claudiu.ghioc@gmail.com> <CAEnQRZAiiJqHcEHoS+=ZMAHdQwu9yYc28or1Di7h4R7PRn6iEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Baluta <daniel.baluta@gmail.com>
Cc: Claudiu Ghioc <claudiughioc@gmail.com>, akpm@linux-foundation.org, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, dhillf@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Claudiu Ghioc <claudiu.ghioc@gmail.com>

On Thu, 7 Mar 2013, Daniel Baluta wrote:

> > Removed the following sparse warnings:
> > *  mm/hugetlb.c:1764:6: warning: symbol
> >     'hugetlb_unregister_node' was not declared.
> >     Should it be static?
> > *   mm/hugetlb.c:1808:6: warning: symbol
> >     'hugetlb_register_node' was not declared.
> >     Should it be static?
> >
> > Signed-off-by: Claudiu Ghioc <claudiu.ghioc@gmail.com>
> > ---
> >  mm/hugetlb.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 0a0be33..c65a8a5 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1761,7 +1761,7 @@ static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> >   * Unregister hstate attributes from a single node device.
> >   * No-op if no hstate attributes attached.
> >   */
> > -void hugetlb_unregister_node(struct node *node)
> > +static void hugetlb_unregister_node(struct node *node)
> >  {
> >         struct hstate *h;
> >         struct node_hstate *nhs = &node_hstates[node->dev.id];
> > @@ -1805,7 +1805,7 @@ static void hugetlb_unregister_all_nodes(void)
> >   * Register hstate attributes for a single node device.
> >   * No-op if attributes already registered.
> >   */
> > -void hugetlb_register_node(struct node *node)
> > +static void hugetlb_register_node(struct node *node)
> >  {
> >         struct hstate *h;
> >         struct node_hstate *nhs = &node_hstates[node->dev.id];
> 
> Can you pick this up via trivial tree?

Seems like sparse is correct here, as register_hugetlbfs_with_node is 
passing pointers to those functions.

Will take it.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
