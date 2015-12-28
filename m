Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id E46196B02A3
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 05:11:24 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l126so263633632wml.1
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 02:11:24 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id w6si79866435wju.89.2015.12.28.02.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Dec 2015 02:11:23 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id f206so2436231wmf.0
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 02:11:23 -0800 (PST)
Date: Mon, 28 Dec 2015 12:11:21 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/8] mm: Add optional support for PUD-sized transparent
 hugepages
Message-ID: <20151228101121.GB4589@node.shutemov.name>
References: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
 <1450974037-24775-2-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450974037-24775-2-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Thu, Dec 24, 2015 at 11:20:30AM -0500, Matthew Wilcox wrote:
> The only major difference is how the new ->pud_entry method in mm_walk
> works.  The ->pmd_entry method replaces the ->pte_entry method, whereas
> the ->pud_entry method works along with either ->pmd_entry or ->pte_entry.

I think it makes pagewalk API confusing. We need something more coherent.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
