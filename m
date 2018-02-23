Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9FF6B000C
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 21:04:27 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id x35so5572274qtx.5
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:04:27 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id m15si1482817qki.29.2018.02.22.18.04.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 18:04:26 -0800 (PST)
Date: Thu, 22 Feb 2018 20:01:53 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
In-Reply-To: <E4FA7972-B97C-4D63-8473-C6F1F4FAB7A0@cs.rutgers.edu>
Message-ID: <alpine.DEB.2.20.1802222000470.2221@nuc-kabylake>
References: <20180216160110.641666320@linux.com> <20180216160121.519788537@linux.com> <20180219101935.cb3gnkbjimn5hbud@techsingularity.net> <68050f0f-14ca-d974-9cf4-19694a2244b9@schoebel-theuer.de> <E4FA7972-B97C-4D63-8473-C6F1F4FAB7A0@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, 22 Feb 2018, Zi Yan wrote:

> I am very interested in the theory behind your patch. Do you mind sharing it? Is there
> any required math background before reading it? Is there any related papers/articles I could
> also read?

His patches were attached to the email you responded to. Guess I should
update the patchset with the suggested changes and repost.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
