Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3DEB8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:05:18 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id l69so1339323ywb.7
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:05:18 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e131sor3060285ywh.108.2018.12.20.08.05.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 08:05:17 -0800 (PST)
Date: Thu, 20 Dec 2018 08:05:14 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: Ipmi modules and linux-4.19.1
Message-ID: <20181220160514.GD2509588@devbig004.ftw2.facebook.com>
References: <CAJM9R-JWO1P_qJzw2JboMH2dgPX7K1tF49nO5ojvf=iwGddXRQ@mail.gmail.com>
 <20181220154217.GB2509588@devbig004.ftw2.facebook.com>
 <20181220160313.GB4170@linux.ibm.com>
 <20181220160408.GA23426@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220160408.GA23426@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: Angel Shtilianov <angel.shtilianov@siteground.com>, linux-mm@kvack.org, dennis@kernel.org, cl@linux.com, jeyu@kernel.org, cminyard@mvista.com

Hello,

On Thu, Dec 20, 2018 at 08:04:08AM -0800, Paul E. McKenney wrote:
> > Yes, it is possible.  Just do something like this:
> > 
> > 	struct srcu_struct my_srcu_struct;
> > 
> > And before the first use of my_srcu_struct, do this:
> > 
> > 	init_srcu_struct(&my_srcu_struct);
> > 
> > This will result in alloc_percpu() being invoked to allocate the
> > needed per-CPU space.
> > 
> > If my_srcu_struct is used in a module or some such, then to avoid memory
> > leaks, after the last use of my_srcu_struct, do this:
> > 
> > 	cleanup_srcu_struct(&my_srcu_struct);
> > 
> > There are several places in the kernel that take this approach.

Oops, my bad.  Somehow I thought the dynamic init didn't exist (I
checked the header but somehow completely skipped over them).  Thanks
for the explanation!

-- 
tejun
