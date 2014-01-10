Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 815C96B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 17:39:12 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id e14so5591462iej.26
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:39:12 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.179.30])
        by mx.google.com with ESMTP id jw1si13937039icc.153.2014.01.10.14.39.11
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 14:39:11 -0800 (PST)
Date: Fri, 10 Jan 2014 16:39:09 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [RFC PATCH] mm: thp: Add per-mm_struct flag to control THP
Message-ID: <20140110223909.GA8666@sgi.com>
References: <1389383718-46031-1-git-send-email-athorlton@sgi.com>
 <20140110202310.GB1421@node.dhcp.inet.fi>
 <20140110220155.GD3066@sgi.com>
 <20140110221010.GP31570@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140110221010.GP31570@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On Fri, Jan 10, 2014 at 11:10:10PM +0100, Peter Zijlstra wrote:
> We already have the information to determine if a page is shared across
> nodes, Mel even had some prototype code to do splits under those
> conditions.

I'm aware that we can determine if pages are shared across nodes, but I
thought that Mel's code to split pages under these conditions had some
performance issues.  I know I've seen the code that Mel wrote to do
this, but I can't seem to dig it up right now.  Could you point me to
it?

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
