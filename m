Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC7696B4337
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:27:09 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so12111757pfj.3
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 11:27:09 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 194si1059962pgg.519.2018.11.26.11.27.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 11:27:08 -0800 (PST)
Subject: Re: [PATCH] mm: put_and_wait_on_page_locked() while page is migrated
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
 <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
 <alpine.LSU.2.11.1811251900300.1278@eggly.anvils>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <2255640a-a97f-ab31-7466-0d38cbfb2723@linux.intel.com>
Date: Mon, 26 Nov 2018 11:27:07 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1811251900300.1278@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, bhe@redhat.com, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, david@redhat.com, mgorman@techsingularity.net, dh.herrmann@gmail.com, kan.liang@intel.com, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 11/25/2018 07:29 PM, Hugh Dickins wrote:

>>    Does somebody still have access to the customer load that triggered
>> the horrible scaling issues before?
> 
> Kan? Tim?
> 

We don't have access to the workload know.  Will ask the customer to
see if they can test it.

Thanks.

Tim
