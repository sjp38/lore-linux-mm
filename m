Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 76E8A6B0256
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 05:15:52 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ho8so102325178pac.2
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 02:15:52 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id lf12si879316pab.207.2016.02.16.02.15.51
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 02:15:51 -0800 (PST)
Date: Tue, 16 Feb 2016 13:15:47 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 18/28] thp: prepare change_huge_pmd() for file thp
Message-ID: <20160216101547.GF46557@black.fi.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-19-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE291B.3080808@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56BE291B.3080808@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 12, 2016 at 10:48:59AM -0800, Dave Hansen wrote:
> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> > change_huge_pmd() has assert which is not relvant for file page.
> > For shared mapping it's perfectly fine to have page table entry
> > writable, without explicit mkwrite.
> 
> Should we have the bug only trigger on anonymous VMAs instead of
> removing it?

Makes sense.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
