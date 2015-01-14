Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD4B6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 13:27:04 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id z12so9428501lbi.4
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 10:27:03 -0800 (PST)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com. [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id ai4si28056034lbc.10.2015.01.14.10.27.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 10:27:03 -0800 (PST)
Received: by mail-la0-f50.google.com with SMTP id pn19so9609093lab.9
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 10:27:02 -0800 (PST)
Date: Wed, 14 Jan 2015 21:27:00 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: account pmd page tables to the process
Message-ID: <20150114182700.GG2253@moon>
References: <1421254316-190596-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421254316-190596-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org

On Wed, Jan 14, 2015 at 06:51:56PM +0200, Kirill A. Shutemov wrote:
> Dave noticed that unprivileged process can allocate significant amount
> of memory -- >500 MiB on x86_64 -- and stay unnoticed by oom-killer and
> memory cgroup. The trick is to allocate a lot of PMD page tables. Linux
> kernel doesn't account PMD tables to the process, only PTE.
> 
> The use-cases below use few tricks to allocate a lot of PMD page tables
> while keeping VmRSS and VmPTE low. oom_score for the process will be 0.

Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
