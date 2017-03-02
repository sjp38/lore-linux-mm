Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 66B536B0388
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 23:20:28 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 1so79124322pgz.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 20:20:28 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a191si6416465pfa.23.2017.03.01.20.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 20:20:27 -0800 (PST)
Date: Wed, 1 Mar 2017 20:20:21 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170302042021.GN16328@bombadil.infradead.org>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228181547.GM5680@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228181547.GM5680@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Feb 28, 2017 at 07:15:47PM +0100, Peter Zijlstra wrote:
> (And we should not be returning to userspace with locks held anyway --
> lockdep already has a check for that).

Don't we return to userspace with page locks held, eg during async directio?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
