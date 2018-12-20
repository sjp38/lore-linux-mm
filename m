Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA2D8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:22:27 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id y88so2104573pfi.9
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:22:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z8si18921098pgk.183.2018.12.20.08.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 08:22:25 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBKGDpUT140149
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:22:25 -0500
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pgd2acfu6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:22:25 -0500
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 20 Dec 2018 16:22:24 -0000
Date: Thu, 20 Dec 2018 08:22:25 -0800
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
Subject: Re: Ipmi modules and linux-4.19.1
Reply-To: paulmck@linux.ibm.com
References: <CAJM9R-JWO1P_qJzw2JboMH2dgPX7K1tF49nO5ojvf=iwGddXRQ@mail.gmail.com>
 <20181220154217.GB2509588@devbig004.ftw2.facebook.com>
 <20181220160313.GB4170@linux.ibm.com>
 <20181220160408.GA23426@linux.ibm.com>
 <20181220160514.GD2509588@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220160514.GD2509588@devbig004.ftw2.facebook.com>
Message-Id: <20181220162225.GC4170@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Angel Shtilianov <angel.shtilianov@siteground.com>, linux-mm@kvack.org, dennis@kernel.org, cl@linux.com, jeyu@kernel.org, cminyard@mvista.com

On Thu, Dec 20, 2018 at 08:05:14AM -0800, Tejun Heo wrote:
> Hello,
> 
> On Thu, Dec 20, 2018 at 08:04:08AM -0800, Paul E. McKenney wrote:
> > > Yes, it is possible.  Just do something like this:
> > > 
> > > 	struct srcu_struct my_srcu_struct;
> > > 
> > > And before the first use of my_srcu_struct, do this:
> > > 
> > > 	init_srcu_struct(&my_srcu_struct);
> > > 
> > > This will result in alloc_percpu() being invoked to allocate the
> > > needed per-CPU space.
> > > 
> > > If my_srcu_struct is used in a module or some such, then to avoid memory
> > > leaks, after the last use of my_srcu_struct, do this:
> > > 
> > > 	cleanup_srcu_struct(&my_srcu_struct);
> > > 
> > > There are several places in the kernel that take this approach.
> 
> Oops, my bad.  Somehow I thought the dynamic init didn't exist (I
> checked the header but somehow completely skipped over them).  Thanks
> for the explanation!

No problem, especially given that if things go as they usually do, I
will provide you ample opportunity to return the favor.  ;-)

							Thanx, Paul
