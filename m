Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 773FB6B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 04:12:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j10-v6so670402pgv.6
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 01:12:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y28-v6sor146168pgk.228.2018.07.03.01.12.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 01:12:10 -0700 (PDT)
Date: Tue, 3 Jul 2018 11:12:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180703081205.3ue5722pb3ko4g2w@kshutemo-mobl1>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
 <20180702123350.dktmzlmztulmtrae@kshutemo-mobl1>
 <20180702124928.GQ19043@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702124928.GQ19043@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon, Jul 02, 2018 at 02:49:28PM +0200, Michal Hocko wrote:
> On Mon 02-07-18 15:33:50, Kirill A. Shutemov wrote:
> [...]
> > I probably miss the explanation somewhere, but what's wrong with allowing
> > other thread to re-populate the VMA?
> 
> We have discussed that earlier and it boils down to how is racy access
> to munmap supposed to behave. Right now we have either the original
> content or SEGV. If we allow to simply madvise_dontneed before real
> unmap we could get a new page as well. There might be (quite broken I
> would say) user space code that would simply corrupt data silently that
> way.

Okay, so we add a lot of complexity to accommodate broken userspace that
may or may not exist. Is it right? :)

-- 
 Kirill A. Shutemov
