Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2596B0038
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 09:25:24 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id h11so1584893wiw.1
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 06:25:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ch4si14524714wjc.105.2014.10.12.06.25.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Oct 2014 06:25:23 -0700 (PDT)
Date: Sun, 12 Oct 2014 15:24:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/4] mm: gup: use get_user_pages_fast and
 get_user_pages_unlocked
Message-ID: <20141012132443.GA26015@redhat.com>
References: <1412153797-6667-1-git-send-email-aarcange@redhat.com>
 <1412153797-6667-4-git-send-email-aarcange@redhat.com>
 <20141009105245.GN4750@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141009105245.GN4750@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>

On Thu, Oct 09, 2014 at 12:52:45PM +0200, Peter Zijlstra wrote:
> On Wed, Oct 01, 2014 at 10:56:36AM +0200, Andrea Arcangeli wrote:
> > Just an optimization.
> 
> Does it make sense to split the thing in two? One where you apply
> _unlocked and then one where you apply _fast?

Yes but I already dropped the _fast optimization, as the latency
enhancements to gup_fast were NAKed earlier in this thread. So this
patch has already been updated to only apply _unlocked.

http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=bc2e0473b601c6a330ddb4adbcf4c048b2233d4e

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
