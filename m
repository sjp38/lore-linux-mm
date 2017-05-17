Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39A346B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 11:07:36 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l10so10116763ioi.5
        for <linux-mm@kvack.org>; Wed, 17 May 2017 08:07:36 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id u3si16206478iti.101.2017.05.17.08.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 08:07:35 -0700 (PDT)
Date: Wed, 17 May 2017 10:07:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/6] mm, mempolicy: stop adjusting current->il_next
 in mpol_rebind_nodemask()
In-Reply-To: <20170517081140.30654-3-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.20.1705171007090.8714@east.gentwo.org>
References: <20170517081140.30654-1-vbabka@suse.cz> <20170517081140.30654-3-vbabka@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, 17 May 2017, Vlastimil Babka wrote:

> The task->il_next variable stores the next allocation node id for task's
> MPOL_INTERLEAVE policy. mpol_rebind_nodemask() updates interleave and
> bind mempolicies due to changing cpuset mems. Currently it also tries to
> make sure that current->il_next is valid within the updated nodemask. This is
> bogus, because 1) we are updating potentially any task's mempolicy, not just
> current, and 2) we might be updating a per-vma mempolicy, not task one.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
