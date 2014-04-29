Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id AF7A76B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 05:33:49 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kq14so6221297pab.4
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 02:33:49 -0700 (PDT)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id pc9si12258055pac.476.2014.04.29.02.33.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 02:33:48 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Tue, 29 Apr 2014 19:33:43 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 8A8852CE8050
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:33:39 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3T9XNQF11403662
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:33:24 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3T9XbG4026659
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 19:33:38 +1000
Message-ID: <535F71EA.6070604@linux.vnet.ibm.com>
Date: Tue, 29 Apr 2014 15:03:30 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 1/2] mm: move FAULT_AROUND_ORDER to arch/
References: <1398675690-16186-1-git-send-email-maddy@linux.vnet.ibm.com> <1398675690-16186-2-git-send-email-maddy@linux.vnet.ibm.com> <20140428090649.GD27561@twins.programming.kicks-ass.net>
In-Reply-To: <20140428090649.GD27561@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, mingo@kernel.org, dave.hansen@intel.com

On Monday 28 April 2014 02:36 PM, Peter Zijlstra wrote:
> On Mon, Apr 28, 2014 at 02:31:29PM +0530, Madhavan Srinivasan wrote:
>> +unsigned int fault_around_order = CONFIG_FAULT_AROUND_ORDER;
> 
> __read_mostly?
> 
Agreed. Will add it.

Thanks for review.
With regards
Maddy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
