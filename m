Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 419096B0254
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 20:02:54 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so115400008pac.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 17:02:54 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xm9si30898664pbc.199.2015.11.13.17.02.53
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 17:02:53 -0800 (PST)
Subject: Re: [PATCH v2 02/11] mm: add pmd_mkclean()
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
 <1447459610-14259-3-git-send-email-ross.zwisler@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56468838.6010506@intel.com>
Date: Fri, 13 Nov 2015 17:02:48 -0800
MIME-Version: 1.0
In-Reply-To: <1447459610-14259-3-git-send-email-ross.zwisler@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On 11/13/2015 04:06 PM, Ross Zwisler wrote:
> +static inline pmd_t pmd_mkclean(pmd_t pmd)
> +{
> +	return pmd_clear_flags(pmd, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
> +}

pte_mkclean() doesn't clear _PAGE_SOFT_DIRTY.  What the thought behind
doing it here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
