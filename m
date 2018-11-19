Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B79E6B1B50
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 11:30:07 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id w185so70751105qka.9
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:30:07 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j7si11339715qkb.6.2018.11.19.08.30.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 08:30:06 -0800 (PST)
Date: Mon, 19 Nov 2018 08:29:42 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 11/13] mm: parallelize deferred struct page
 initialization within each node
Message-ID: <20181119162942.25qyec52mtzwe2xo@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-12-daniel.m.jordan@oracle.com>
 <AT5PR8401MB1169798EBEF1EE5EBA3ABFFFABC70@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
 <20181112165412.vizeiv6oimsuxkbk@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181112165412.vizeiv6oimsuxkbk@ca-dmjordan1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "aaron.lu@intel.com" <aaron.lu@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "bsd@redhat.com" <bsd@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "jgg@mellanox.com" <jgg@mellanox.com>, "jwadams@google.com" <jwadams@google.com>, "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>, "prasad.singamsetty@oracle.com" <prasad.singamsetty@oracle.com>, "rdunlap@infradead.org" <rdunlap@infradead.org>, "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "tim.c.chen@intel.com" <tim.c.chen@intel.com>, "tj@kernel.org" <tj@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, zwisler@google.com

On Mon, Nov 12, 2018 at 08:54:12AM -0800, Daniel Jordan wrote:
> On Sat, Nov 10, 2018 at 03:48:14AM +0000, Elliott, Robert (Persistent Memory) wrote:
> > > -----Original Message-----
> > > From: linux-kernel-owner@vger.kernel.org <linux-kernel-
> > > owner@vger.kernel.org> On Behalf Of Daniel Jordan
> > > Sent: Monday, November 05, 2018 10:56 AM
> > > Subject: [RFC PATCH v4 11/13] mm: parallelize deferred struct page
> > > initialization within each node
> > > 
> > > ...  The kernel doesn't
> > > know the memory bandwidth of a given system to get the most efficient
> > > number of threads, so there's some guesswork involved.  
> > 
> > The ACPI HMAT (Heterogeneous Memory Attribute Table) is designed to report
> > that kind of information, and could facilitate automatic tuning.
> > 
> > There was discussion last year about kernel support for it:
> > https://lore.kernel.org/lkml/20171214021019.13579-1-ross.zwisler@linux.intel.com/
> 
> Thanks for bringing this up.  I'm traveling but will take a closer look when I
> get back.

So this series would give the total bandwidth for a memory target, but there's
not a way to map that to a CPU count.  In other words, it seems we couldn't
determine how many CPUs it takes to reach the max bandwidth.  If I haven't
missed something, I'm going to remove that comment.
