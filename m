Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 21AC26B026D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 10:29:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id t14-v6so1354633wrr.23
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 07:29:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k17-v6si1802118wrq.216.2018.06.27.07.29.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 07:29:26 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5RETC13138824
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 10:29:24 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jva4qf4n6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 10:29:23 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 27 Jun 2018 10:29:22 -0400
Date: Wed, 27 Jun 2018 07:31:25 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Reply-To: paulmck@linux.vnet.ibm.com
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
 <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
 <20180626170345.GA3593@linux.vnet.ibm.com>
 <20180627072207.GB32348@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627072207.GB32348@dhcp22.suse.cz>
Message-Id: <20180627143125.GW3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed, Jun 27, 2018 at 09:22:07AM +0200, Michal Hocko wrote:
> On Tue 26-06-18 10:03:45, Paul E. McKenney wrote:
> [...]
> > 3.	Something else?
> 
> How hard it would be to use a different API than oom notifiers? E.g. a
> shrinker which just kicks all the pending callbacks if the reclaim
> priority reaches low values (e.g. 0)?

Beats me.  What is a shrinker?  ;-)

More seriously, could you please point me at an exemplary shrinker
use case so I can see what is involved?

							Thanx, Paul
