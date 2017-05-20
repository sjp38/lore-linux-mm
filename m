Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D48BC280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 09:16:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t12so80807461pgo.7
        for <linux-mm@kvack.org>; Sat, 20 May 2017 06:16:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 74si11693644pgd.238.2017.05.20.06.16.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 May 2017 06:16:51 -0700 (PDT)
Date: Sat, 20 May 2017 06:16:45 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] slub/memcg: Cure the brainless abuse of sysfs attributes
Message-ID: <20170520131645.GA5058@infradead.org>
References: <alpine.DEB.2.20.1705201244540.2255@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705201244540.2255@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>

On Sat, May 20, 2017 at 12:52:03PM +0200, Thomas Gleixner wrote:
> This should be rewritten proper by adding a propagate() callback to those
> slub_attributes which must be propagated and avoid that insane conversion
> to and from ASCII

Exactly..

>, but that's too large for a hot fix.

What made this such a hot fix?  Looks like this crap has been in
for quite a while.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
