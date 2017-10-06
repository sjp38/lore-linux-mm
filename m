Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 59DA76B0038
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 18:12:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so27117535pfc.7
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 15:12:43 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id e71si1782142pgc.143.2017.10.06.15.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 15:12:42 -0700 (PDT)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v1][cover-letter] mm/mempolicy.c: Fix get_nodes() off-by-one error.
References: <1507296994-175620-1-git-send-email-luis.felipe.sandoval.castro@intel.com>
Date: Fri, 06 Oct 2017 15:12:40 -0700
In-Reply-To: <1507296994-175620-1-git-send-email-luis.felipe.sandoval.castro@intel.com>
	(Luis Felipe Sandoval Castro's message of "Fri, 6 Oct 2017 08:36:33
	-0500")
Message-ID: <87a814ncx3.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu

Luis Felipe Sandoval Castro <luis.felipe.sandoval.castro@intel.com>
writes:

> According to mbind() and set_mempolicy()'s man pages the argument "maxnode"
> specifies the max number of bits in the "nodemask" (which is also to be passed
> to these functions) that should be considered for the memory policy. If maxnode
> = 2, only two bits are to be considered thus valid node masks are: 0b00, 0b01,
> 0b10 and 0b11.

We can't change this unfortunately, it would break old binaries (like
libnuma) which assume the old interface.

The only way to fix it would be to add a new system call and keep
the old one for compatibility, but that would seem like overkill just
for this.

You always have to add +1, sorry.

Perhaps it could be better documented.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
