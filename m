Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E40518E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 13:02:34 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 39so140486edq.13
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 10:02:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a25si3530987edb.405.2019.01.14.10.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 10:02:33 -0800 (PST)
Date: Mon, 14 Jan 2019 19:02:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
Message-ID: <20190114180230.GN21345@dhcp22.suse.cz>
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
 <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
 <20190114135001.w2wpql53zitellus@kshutemo-mobl1>
 <MWHPR06MB2896ACD09C21B2939959C8A8EE800@MWHPR06MB2896.namprd06.prod.outlook.com>
 <20190114164004.GL21345@dhcp22.suse.cz>
 <MWHPR06MB289605B9E1B4234674CB87E2EE800@MWHPR06MB2896.namprd06.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <MWHPR06MB289605B9E1B4234674CB87E2EE800@MWHPR06MB2896.namprd06.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Harrosh, Boaz" <Boaz.Harrosh@netapp.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon 14-01-19 16:54:02, Harrosh, Boaz wrote:
> Michal Hocko <mhocko@kernel.org> wrote:
[...]
> >> We run with our own compiled Kernel on various distros, THP is configured
> >> in but mmap against /dev/shm/ never gives me Huge pages. Does it only
> >> work with unanimous mmap ? (I think it is mount dependent which is not
> >> in the application control)
> >
> > If you are talking about THP then you have to enable huge pages for the
> > mapping AFAIR.
> 
> This is exactly what I was looking to achieve but was not able to do. Most probably
> a stupid omission on my part, but just to show that it is not that trivial and strait
> out-of-the-man-page way to do it.  (Would love a code snippet if you ever wrote one?)

Have you tried
mount -t tmpfs -o huge=always none $MNT_POINT ?

It is true that man pages are silent about this but at least Documentation/admin-guide/mm/transhuge.rst
has an information. Time to send a patch to man pages I would say.
-- 
Michal Hocko
SUSE Labs
