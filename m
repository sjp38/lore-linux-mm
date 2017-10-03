Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2A06B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 19:51:41 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id n1so17837410pgt.4
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 16:51:41 -0700 (PDT)
Received: from fuzix.org (www.llwyncelyn.cymru. [82.70.14.225])
        by mx.google.com with ESMTPS id 1si646883pln.617.2017.10.03.16.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 16:51:40 -0700 (PDT)
Date: Wed, 4 Oct 2017 00:51:27 +0100
From: Alan Cox <alan@llwyncelyn.cymru>
Subject: Re: tty crash due to auto-failing vmalloc
Message-ID: <20171004005127.398be9ab@alans-desktop>
In-Reply-To: <20171003225504.GA966@cmpxchg.org>
References: <20171003225504.GA966@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

> I think this patch should be reverted. If somebody is vmallocing crazy
> amounts of memory in the exit path we should probably track them down
> individually; the patch doesn't reference any real instances of that.
> But we cannot start failing allocations that have never failed before.
> 
> That said, maybe we want Alan's N_NULL failover in the hangup path too?

I think that would be best. There's always going to be a failure case
even if the vmalloc change makes it rarer. Dropping back to N_NULL fixes
all of the cases.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
