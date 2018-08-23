Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8916B2AB4
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 11:16:01 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id s1-v6so4936676qte.19
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 08:16:01 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i37-v6si4719667qvd.67.2018.08.23.08.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 08:16:00 -0700 (PDT)
Date: Thu, 23 Aug 2018 17:15:55 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC v8 PATCH 2/5] uprobes: introduce has_uprobes helper
Message-ID: <20180823151554.GC10652@redhat.com>
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-3-git-send-email-yang.shi@linux.alibaba.com>
 <e7147e14-bc38-03d0-90a4-5e0ca7e40050@suse.cz>
 <20180822150718.GB52756@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822150718.GB52756@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, liu.song.a23@gmail.com, ravi.bangoria@linux.ibm.com, linux-kernel@vger.kernel.org

On 08/22, Srikar Dronamraju wrote:
>
> * Vlastimil Babka <vbabka@suse.cz> [2018-08-22 12:55:59]:
>
> > On 08/15/2018 08:49 PM, Yang Shi wrote:
> > > We need check if mm or vma has uprobes in the following patch to check
> > > if a vma could be unmapped with holding read mmap_sem.

Confused... why can't we call uprobe_munmap() under read_lock(mmap_sem) ?

OK, it can race with find_active_uprobe() but I do not see anything really
wrong, and a false-positive MMF_RECALC_UPROBES is fine.

Again, I think we should simply kill uprobe_munmap(), but this needs another
discussion.

Oleg.
