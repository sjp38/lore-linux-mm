Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 056D76B0071
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 17:59:38 -0500 (EST)
Received: by paceu11 with SMTP id eu11so31027337pac.10
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:59:37 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f2si13393530pdj.71.2015.02.23.14.59.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 14:59:37 -0800 (PST)
Message-ID: <54EBB0AD.8080902@oracle.com>
Date: Mon, 23 Feb 2015 17:58:53 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/6] the big khugepaged redesign
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>	<1424731603.6539.51.camel@stgolabs.net> <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org>
In-Reply-To: <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On 02/23/2015 05:56 PM, Andrew Morton wrote:
>>> Now I don't have any hard data to show how big these problems are, and I
>>> > > expect we will discuss this on LSF/MM (and hope somebody has such data [3]).
>>> > > But it's certain that e.g. SAP recommends to disable THPs [4] for their apps
>>> > > for performance reasons.
>> > 
>> > There are plenty of examples of this, ie for Oracle:
>> > 
>> > https://blogs.oracle.com/linux/entry/performance_issues_with_transparent_huge
> hm, five months ago and I don't recall seeing any followup to this. 
> Does anyone know what's happening?

I'll dig it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
