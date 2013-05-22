Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 294616B00CC
	for <linux-mm@kvack.org>; Wed, 22 May 2013 10:35:37 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519C01D8.4040301@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-30-git-send-email-kirill.shutemov@linux.intel.com>
 <519C01D8.4040301@sr71.net>
Subject: Re: [PATCHv4 29/39] thp: move maybe_pmd_mkwrite() out of
 mk_huge_pmd()
Content-Transfer-Encoding: 7bit
Message-Id: <20130522143746.A7CE5E0090@blue.fi.intel.com>
Date: Wed, 22 May 2013 17:37:46 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > It's confusing that mk_huge_pmd() has sematics different from mk_pte()
> > or mk_pmd().
> > 
> > Let's move maybe_pmd_mkwrite() out of mk_huge_pmd() and adjust
> > prototype to match mk_pte().
> 
> Was there a motivation to do this beyond adding consistency?  Do you use
> this later or something?

I spent some time on debugging problem caused by this inconsistency, so at
that point I was motivated to fix it. :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
