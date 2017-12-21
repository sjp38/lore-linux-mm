Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42DC96B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 16:29:45 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a5so15000808pgu.1
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 13:29:45 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 61si15365346plz.285.2017.12.21.13.29.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 13:29:44 -0800 (PST)
Date: Thu, 21 Dec 2017 14:29:43 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/2] mm: Make follow_pte_pmd an inline
Message-ID: <20171221212943.GB9087@linux.intel.com>
References: <20171219165823.24243-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219165823.24243-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Josh Triplett <josh@joshtriplett.org>, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Dec 19, 2017 at 08:58:22AM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The one user of follow_pte_pmd (dax) emits a sparse warning because
> it doesn't know that follow_pte_pmd conditionally returns with the
> pte/pmd locked.  The required annotation is already there; it's just
> in the wrong file.

Can you help me find the required annotation that is already there but in the
wrong file?

This does seem to quiet a lockep warning in fs/dax.c, but I think we still
have a related one in mm/memory.c:

mm/memory.c:4204:5: warning: context imbalance in '__follow_pte_pmd' - different lock contexts for basic block

Should we deal with this one as well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
