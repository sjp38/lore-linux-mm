Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5249280254
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:59:27 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so46234415wma.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:59:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id cc1si60650337wjc.168.2016.11.29.10.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 10:59:26 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uATIx0lB066040
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:59:25 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 271bxcpdxb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:59:25 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 29 Nov 2016 11:59:24 -0700
Date: Tue, 29 Nov 2016 10:59:21 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161124133019.GE3612@linux.vnet.ibm.com>
 <de88a72a-f861-b51f-9fb3-4265378702f1@kernelpanic.ru>
 <20161125212000.GI31360@linux.vnet.ibm.com>
 <20161128095825.GI14788@dhcp22.suse.cz>
 <20161128105425.GY31360@linux.vnet.ibm.com>
 <3a4242cb-0198-0a3b-97ae-536fb5ff83ec@kernelpanic.ru>
 <20161128143435.GC3924@linux.vnet.ibm.com>
 <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
 <20161128150509.GG3924@linux.vnet.ibm.com>
 <f9c76351-56a6-466d-98c0-b821c2b54a3d@kernelpanic.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f9c76351-56a6-466d-98c0-b821c2b54a3d@kernelpanic.ru>
Message-Id: <20161129185921.GA14183@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Zhmurov <bb@kernelpanic.ru>
Cc: Michal Hocko <mhocko@kernel.org>, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org

On Mon, Nov 28, 2016 at 10:16:33PM +0300, Boris Zhmurov wrote:
> Paul E. McKenney 28/11/16 18:05:
> > On Mon, Nov 28, 2016 at 05:40:48PM +0300, Boris Zhmurov wrote:
> >> Paul E. McKenney 28/11/16 17:34:
> >>
> >>
> >>>> So Paul, I've dropped "mm: Prevent shrink_node_memcg() RCU CPU stall
> >>>> warnings" patch, and stalls got back (attached).
> >>>>
> >>>> With this patch "commit 7cebc6b63bf75db48cb19a94564c39294fd40959" from
> >>>> your tree stalls gone. Looks like that.
> >>>
> >>> So with only this commit and no other commit or configuration adjustment,
> >>> everything works?  Or it the solution this commit and some other stuff?
> >>>
> >>> The reason I ask is that if just this commit does the trick, I should
> >>> drop the others.
> >>
> >> I'd like to ask for some more time to make sure this is it.
> >> Approximately 2 or 3 days.
> > 
> > Works for me!
> > 
> > 							Thanx, Paul
> 
> 
> FYI.
> Some more stalls with mm-prevent-shrink_node-RCU-CPU-stall-warning.patch
> and without mm-prevent-shrink_node_memcg-RCU-CPU-stall-warnings.patch.

Thank you for the info!  Is this one needed?  2d66cccd7343 ("mm: Prevent
__alloc_pages_nodemask() RCU CPU stall warnings")

It is causing trouble in other tests.  If it is needed, I must fix it,
if not, I can happily drop it.  ;-)

							Thanx. Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
