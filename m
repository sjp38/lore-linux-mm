Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 402706B1F6F
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 04:11:29 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s22so871968pgv.8
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 01:11:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1-v6sor51200657plr.70.2018.11.20.01.11.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 01:11:28 -0800 (PST)
Date: Tue, 20 Nov 2018 12:11:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
Message-ID: <20181120091122.3dxlgff3vivwilrg@kshutemo-mobl1>
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
 <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
 <20181109195150.GA24747@redhat.com>
 <20181110132249.GH23260@techsingularity.net>
 <20181110164412.GB22642@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181110164412.GB22642@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Anthony Yznaga <anthony.yznaga@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com

On Sat, Nov 10, 2018 at 11:44:12AM -0500, Andrea Arcangeli wrote:
> I would prefer to add intelligence to detect when COWs after fork
> should be done at 2m or 4k granularity (in the latter case by
> splitting the pmd before the actual COW while leaving the transhuge
> pmd intact in the other mm), because that would save CPU (and it'd
> automatically optimize redis). The snapshot process especially would
> run faster as it will read with THP performance.

I would argue we should switch to 4k COW everywhere. But it requires some
work on khugepaged side to be able to recover THP back after multiple 4k
COW in the range. Currently khugepaged is not able to collapse PTE entires
backed by compound page back to PMD.

I have this on my todo list for long time, but...

-- 
 Kirill A. Shutemov
