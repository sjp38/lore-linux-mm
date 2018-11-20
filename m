Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1EA6B20E5
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 11:33:23 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id a14-v6so1240171ybk.23
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 08:33:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r129sor997675ywh.75.2018.11.20.08.33.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 08:33:22 -0800 (PST)
Date: Tue, 20 Nov 2018 08:33:19 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v4 05/13] workqueue, ktask: renice helper threads to
 prevent starvation
Message-ID: <20181120163319.GW2509588@devbig004.ftw2.facebook.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-6-daniel.m.jordan@oracle.com>
 <20181113163400.GK2509588@devbig004.ftw2.facebook.com>
 <20181119164554.axobolrufu26kfah@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119164554.axobolrufu26kfah@ca-dmjordan1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, vbabka@suse.cz

On Mon, Nov 19, 2018 at 08:45:54AM -0800, Daniel Jordan wrote:
> So instead of flush_work_at_nice, how about this?:
> 
> void renice_work_sync(work_struct *work, long nice);

Wouldn't renice_or_cancel make more sense?

Thanks.

-- 
tejun
