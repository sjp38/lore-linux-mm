Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 916786B029F
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 20:30:19 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id m198-v6so14088614itm.8
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 17:30:19 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 190-v6si483363itp.49.2018.11.05.17.30.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 17:30:18 -0800 (PST)
Date: Mon, 5 Nov 2018 17:29:55 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Message-ID: <20181106012955.br5swua3ykvolyjq@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105172931.GP4361@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105172931.GP4361@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On Mon, Nov 05, 2018 at 06:29:31PM +0100, Michal Hocko wrote:
> On Mon 05-11-18 11:55:45, Daniel Jordan wrote:
> > Michal, you mentioned that ktask should be sensitive to CPU utilization[1].
> > ktask threads now run at the lowest priority on the system to avoid disturbing
> > busy CPUs (more details in patches 4 and 5).  Does this address your concern?
> > The plan to address your other comments is explained below.
> 
> I have only glanced through the documentation patch and it looks like it
> will be much less disruptive than the previous attempts. Now the obvious
> question is how does this behave on a moderately or even busy system
> when you compare that to a single threaded execution. Some numbers about
> best/worst case execution would be really helpful.

Patches 4 and 5 have some numbers where a ktask and non-ktask workload compete
against each other.  Those show either 8 ktask threads on 8 CPUs (worst case) or no ktask threads (best case).

By single threaded execution, I guess you mean 1 ktask thread.  I'll run the
experiments that way too and post the numbers.

> I will look closer later.

Great!  Thanks for your comment.

Daniel
