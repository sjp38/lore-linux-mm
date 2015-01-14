Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id B175A6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 09:48:47 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id u10so8211538lbd.13
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:48:45 -0800 (PST)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id h3si6142781lam.29.2015.01.14.06.48.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 06:48:45 -0800 (PST)
Received: by mail-la0-f45.google.com with SMTP id gq15so8503395lab.4
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:48:45 -0800 (PST)
Date: Wed, 14 Jan 2015 17:48:43 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 1/2] mm: rename mm->nr_ptes to mm->nr_pgtables
Message-ID: <20150114144843.GE2253@moon>
References: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20150113214355.GC2253@moon>
 <54B592D6.4090406@linux.intel.com>
 <20150114094538.GD2253@moon>
 <20150114143358.GA9820@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150114143358.GA9820@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Wed, Jan 14, 2015 at 04:33:58PM +0200, Kirill A. Shutemov wrote:
> > 
> > It looks like this doesn't matter. The statistics here prints the size
> > of summary memory occupied for pte_t entries, here PTRS_PER_PTE * sizeof(pte_t)
> > is only valid for, once we start accounting pmd into same counter it implies
> > that PTRS_PER_PTE == PTRS_PER_PMD, which is not true for all archs
> > (if I understand the idea of accounting here right).
> 
> Yeah. good catch. Thank you.
> 
> I'll respin with separate counter for pmd tables. It seems the best
> option.

Sounds good to me, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
