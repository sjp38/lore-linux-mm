Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B1E386B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 19:30:34 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id h11so1965511wiw.0
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 16:30:34 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id gl9si11961628wjc.3.2015.01.28.16.30.31
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 16:30:32 -0800 (PST)
Date: Thu, 29 Jan 2015 02:30:28 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/4] mm: split up mm_struct to separate header file
Message-ID: <20150129003028.GA17519@node.dhcp.inet.fi>
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1422451064-109023-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422451064-109023-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 28, 2015 at 03:17:42PM +0200, Kirill A. Shutemov wrote:
> We want to use __PAGETABLE_PMD_FOLDED in mm_struct to drop nr_pmds if
> pmd is folded. __PAGETABLE_PMD_FOLDED is defined in <asm/pgtable.h>, but
> <asm/pgtable.h> itself wants <linux/mm_types.h> for struct page
> definition.
> 
> This patch move mm_struct definition into separate header file in order
> to fix circular header dependencies.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Guenter, below is update for the patch. It doesn't fix all the issues, but
you should see an improvement. I'll continue with this tomorrow.

BTW, any idea where I can get hexagon cross compiler?
