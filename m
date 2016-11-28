Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6826B0253
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:05:17 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a8so215339931pfg.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:05:17 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q17si55459136pgh.96.2016.11.28.07.05.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 07:05:16 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uASF3wpA139036
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:05:15 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 270ns459em-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:05:14 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 28 Nov 2016 08:05:12 -0700
Date: Mon, 28 Nov 2016 07:05:09 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
Reply-To: paulmck@linux.vnet.ibm.com
References: <d6981bac-8e97-b482-98c0-40949db03ca3@kernelpanic.ru>
 <20161124133019.GE3612@linux.vnet.ibm.com>
 <de88a72a-f861-b51f-9fb3-4265378702f1@kernelpanic.ru>
 <20161125212000.GI31360@linux.vnet.ibm.com>
 <20161128095825.GI14788@dhcp22.suse.cz>
 <20161128105425.GY31360@linux.vnet.ibm.com>
 <3a4242cb-0198-0a3b-97ae-536fb5ff83ec@kernelpanic.ru>
 <20161128143435.GC3924@linux.vnet.ibm.com>
 <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eba1571e-f7a8-09b3-5516-c2bc35b38a83@kernelpanic.ru>
Message-Id: <20161128150509.GG3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Zhmurov <bb@kernelpanic.ru>
Cc: Michal Hocko <mhocko@kernel.org>, Paul Menzel <pmenzel@molgen.mpg.de>, Donald Buczek <buczek@molgen.mpg.de>, linux-mm@kvack.org

On Mon, Nov 28, 2016 at 05:40:48PM +0300, Boris Zhmurov wrote:
> Paul E. McKenney 28/11/16 17:34:
> 
> 
> >> So Paul, I've dropped "mm: Prevent shrink_node_memcg() RCU CPU stall
> >> warnings" patch, and stalls got back (attached).
> >>
> >> With this patch "commit 7cebc6b63bf75db48cb19a94564c39294fd40959" from
> >> your tree stalls gone. Looks like that.
> > 
> > So with only this commit and no other commit or configuration adjustment,
> > everything works?  Or it the solution this commit and some other stuff?
> > 
> > The reason I ask is that if just this commit does the trick, I should
> > drop the others.
> 
> I'd like to ask for some more time to make sure this is it.
> Approximately 2 or 3 days.

Works for me!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
