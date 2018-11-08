Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 54AA16B0638
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 14:18:54 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id w5-v6so24732234ioj.3
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 11:18:54 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i84-v6si3266377iof.34.2018.11.08.11.18.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 11:18:52 -0800 (PST)
Date: Thu, 8 Nov 2018 11:15:53 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
Message-ID: <20181108191553.nu7yn2akmcql2vje@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-2-daniel.m.jordan@oracle.com>
 <20181108102638.3415ae0b@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108102638.3415ae0b@lwn.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz, peterz@infradead.org, dhaval.giani@oracle.com

On Thu, Nov 08, 2018 at 10:26:38AM -0700, Jonathan Corbet wrote:
> On Mon,  5 Nov 2018 11:55:46 -0500
> Daniel Jordan <daniel.m.jordan@oracle.com> wrote:
> 
> > Motivates and explains the ktask API for kernel clients.
> 
> A couple of quick thoughts:
> 
> - Agree with Peter on the use of "task"; something like "job" would be far
>   less likely to create confusion.  Maybe you could even call it a "batch
>   job" to give us old-timers warm fuzzies...:)

smp_job?  Or smp_batch, for that retro flavor?  :)

> 
> - You have kerneldoc comments for the API functions, but you don't pull
>   those into the documentation itself.  Adding some kernel-doc directives
>   could help to fill things out nicely with little effort.

I thought this part of ktask.rst handled that, or am I not doing it right?

    Interface
    =========
    
    .. kernel-doc:: include/linux/ktask.h

Thanks for the comments,
Daniel
