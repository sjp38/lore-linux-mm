Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 005296B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 16:24:12 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id d70-v6so2878406itd.1
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 13:24:12 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0156.hostedemail.com. [216.40.44.156])
        by mx.google.com with ESMTPS id c10-v6si1185882ioh.248.2018.07.03.13.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 13:24:11 -0700 (PDT)
Message-ID: <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
From: Joe Perches <joe@perches.com>
Date: Tue, 03 Jul 2018 13:24:07 -0700
In-Reply-To: <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
	 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 2018-07-03 at 12:57 -0700, Andrew Morton wrote:
> Did you see all this checkpatch noise?
> 
> : WARNING: Deprecated vsprintf pointer extension '%pF' - use %pS instead
> : #54: FILE: mm/memblock.c:1348:
> : +	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
> : +		     __func__, (u64)size, (u64)align, nid, &min_addr,
> : +		     &max_addr, (void *)_RET_IP_);
> : ...

%p[Ff] got deprecated by commit 04b8eb7a4ccd9ef9343e2720ccf2a5db8cfe2f67

I think it'd be simplest to just convert
all the %pF and %pf uses all at once.

$ git grep --name-only "%p[Ff]" | \
  xargs sed -i -e 's/%pF/%pS/' -e 's/%pf/%ps/'

and remove the appropriate Documentation bit.
