Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 054D66B0006
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 12:29:35 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c2-v6so5904189edi.6
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 09:29:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h20-v6si3419247edr.245.2018.11.05.09.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 09:29:33 -0800 (PST)
Date: Mon, 5 Nov 2018 18:29:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Message-ID: <20181105172931.GP4361@dhcp22.suse.cz>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On Mon 05-11-18 11:55:45, Daniel Jordan wrote:
> Michal, you mentioned that ktask should be sensitive to CPU utilization[1].
> ktask threads now run at the lowest priority on the system to avoid disturbing
> busy CPUs (more details in patches 4 and 5).  Does this address your concern?
> The plan to address your other comments is explained below.

I have only glanced through the documentation patch and it looks like it
will be much less disruptive than the previous attempts. Now the obvious
question is how does this behave on a moderately or even busy system
when you compare that to a single threaded execution. Some numbers about
best/worst case execution would be really helpful.

I will look closer later.

-- 
Michal Hocko
SUSE Labs
