Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id A028D6B0035
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 05:10:40 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so1181959igb.16
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 02:10:40 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id v20si20820136icb.23.2014.08.01.02.10.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 02:10:39 -0700 (PDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so1182198igd.14
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 02:10:39 -0700 (PDT)
Date: Fri, 1 Aug 2014 02:10:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/3] mm, oom: remove unnecessary check for NULL
 zonelist
In-Reply-To: <20140731152659.GB9952@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1408010159500.4061@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407231814110.22326@chino.kir.corp.google.com> <alpine.DEB.2.02.1407231815090.22326@chino.kir.corp.google.com> <20140731152659.GB9952@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 31 Jul 2014, Johannes Weiner wrote:

> out_of_memory() wants the zonelist that was used during allocation,
> not just the random first node's zonelist that's simply picked to
> serialize page fault OOM kills system-wide.
> 
> This would even change how panic_on_oom behaves for page fault OOMs
> (in a completely unpredictable way) if we get CONSTRAINED_CPUSET.
> 
> This change makes no sense to me.
> 

Allocations during fault will be constrained by the cpuset's mems, if we 
are oom then why would we panic when panic_on_oom == 1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
