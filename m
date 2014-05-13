Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8467F6B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 14:24:39 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id bs8so1110417wib.6
        for <linux-mm@kvack.org>; Tue, 13 May 2014 11:24:39 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id um5si3389938wjc.236.2014.05.13.11.24.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 11:24:38 -0700 (PDT)
Date: Tue, 13 May 2014 20:24:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140513182432.GH2485@laptop.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140513152719.GF18164@linux.vnet.ibm.com>
 <20140513181852.GB12123@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140513181852.GB12123@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Tue, May 13, 2014 at 08:18:52PM +0200, Oleg Nesterov wrote:
> 
> In short: I am totally confused and most probably misunderstood you ;)

Yeah, my bad, I got myself totally confused and it seems to spread fast.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
