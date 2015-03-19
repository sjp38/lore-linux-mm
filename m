Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4A91E6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 12:18:15 -0400 (EDT)
Received: by qgfa8 with SMTP id a8so69580258qgf.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 09:18:15 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id b79si1575272qge.107.2015.03.19.09.18.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 09:18:14 -0700 (PDT)
Date: Thu, 19 Mar 2015 11:18:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH V6] Allow compaction of unevictable pages
In-Reply-To: <550AEC8B.1080806@akamai.com>
Message-ID: <alpine.DEB.2.11.1503191117380.26866@gentwo.org>
References: <1426773430-31052-1-git-send-email-emunson@akamai.com> <550AE38E.7090006@suse.cz> <550AEC8B.1080806@akamai.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-rt-users@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 19 Mar 2015, Eric B Munson wrote:

> Thanks, I have a version with the changelog fixed up to actually make
> sense and can submit that if the patch is acceptable otherwise.


Looks good as far as I can see.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
