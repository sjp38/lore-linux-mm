Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D7ED06B000D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 08:49:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v19-v6so5685917eds.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 05:49:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 91-v6si1170392edf.396.2018.07.02.05.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 05:49:30 -0700 (PDT)
Date: Mon, 2 Jul 2018 14:49:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180702124928.GQ19043@dhcp22.suse.cz>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
 <20180702123350.dktmzlmztulmtrae@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702123350.dktmzlmztulmtrae@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon 02-07-18 15:33:50, Kirill A. Shutemov wrote:
[...]
> I probably miss the explanation somewhere, but what's wrong with allowing
> other thread to re-populate the VMA?

We have discussed that earlier and it boils down to how is racy access
to munmap supposed to behave. Right now we have either the original
content or SEGV. If we allow to simply madvise_dontneed before real
unmap we could get a new page as well. There might be (quite broken I
would say) user space code that would simply corrupt data silently that
way.
-- 
Michal Hocko
SUSE Labs
