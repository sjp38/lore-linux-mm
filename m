Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 803FB6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 18:19:27 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so121538127pad.3
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 15:19:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cz8si11673411pdb.85.2015.03.20.15.19.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 15:19:26 -0700 (PDT)
Date: Fri, 20 Mar 2015 15:19:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V7] Allow compaction of unevictable pages
Message-Id: <20150320151925.8bbd4c62af3d3739860c0ecb@linux-foundation.org>
In-Reply-To: <1426859390-10974-1-git-send-email-emunson@akamai.com>
References: <1426859390-10974-1-git-send-email-emunson@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-doc@vger.kernel.org, linux-rt-users@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 20 Mar 2015 09:49:50 -0400 Eric B Munson <emunson@akamai.com> wrote:

>  Documentation/sysctl/vm.txt |   11 +++++++++++
>  include/linux/compaction.h  |    1 +
>  kernel/sysctl.c             |    9 +++++++++
>  mm/compaction.c             |    7 +++++++

Documentation/vm/unevictable-lru.txt might benefit from an update.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
