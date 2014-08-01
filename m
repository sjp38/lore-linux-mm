Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id A0F3A6B0037
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 09:35:29 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ho1so1373657wib.8
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 06:35:29 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id xu6si10941450wjb.131.2014.08.01.06.35.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 06:35:28 -0700 (PDT)
Date: Fri, 1 Aug 2014 09:34:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] mm, oom: remove unnecessary check for NULL zonelist
Message-ID: <20140801133444.GH9952@cmpxchg.org>
References: <alpine.DEB.2.02.1407231814110.22326@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1407231815090.22326@chino.kir.corp.google.com>
 <20140731152659.GB9952@cmpxchg.org>
 <alpine.DEB.2.02.1408010159500.4061@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1408010159500.4061@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 01, 2014 at 02:10:37AM -0700, David Rientjes wrote:
> On Thu, 31 Jul 2014, Johannes Weiner wrote:
> 
> > out_of_memory() wants the zonelist that was used during allocation,
> > not just the random first node's zonelist that's simply picked to
> > serialize page fault OOM kills system-wide.
> > 
> > This would even change how panic_on_oom behaves for page fault OOMs
> > (in a completely unpredictable way) if we get CONSTRAINED_CPUSET.
> > 
> > This change makes no sense to me.
> > 
> 
> Allocations during fault will be constrained by the cpuset's mems, if we 
> are oom then why would we panic when panic_on_oom == 1?

Can you please address the concerns I raised?

And please describe user-visible changes in the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
