Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 372796B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:36:11 -0400 (EDT)
Received: by wijp15 with SMTP id p15so71661728wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 02:36:10 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id en7si31014150wjd.61.2015.08.24.02.36.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 02:36:10 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so44071873wid.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 02:36:09 -0700 (PDT)
Date: Mon, 24 Aug 2015 12:36:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 0/5] Fix compound_head() race
Message-ID: <20150824093607.GB1994@node.dhcp.inet.fi>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820123107.GA31768@node.dhcp.inet.fi>
 <20150820163836.b3b69f2bf36dba7020bdc893@linux-foundation.org>
 <alpine.LSU.2.11.1508221204060.10507@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1508221204060.10507@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Aug 22, 2015 at 01:13:19PM -0700, Hugh Dickins wrote:
> Yes, I did think the compound destructor enum stuff over-engineered,
> and would have preferred just direct calls to free_compound_page()
> or free_huge_page() myself.  But when I tried to make a patch on
> top to do that, even when I left PageHuge out-of-line (which had
> certainly not been my intention), it still generated more kernel
> text than Kirill's enum version (maybe his "- 1" in compound_head
> works better in some places than masking out 3, I didn't study);
> so let's forget about that.

I had my agenda on ->compound_dtor: my refcounting patchset introduces
one more compound destructor. I wanted to avoid hardcoding them here.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
