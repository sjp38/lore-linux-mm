Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 882DE6B0279
	for <linux-mm@kvack.org>; Tue, 15 May 2018 08:01:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k11-v6so1416023pgq.10
        for <linux-mm@kvack.org>; Tue, 15 May 2018 05:01:27 -0700 (PDT)
Received: from mx144.netapp.com (mx144.netapp.com. [2620:10a:4005:8000:2306::d])
        by mx.google.com with ESMTPS id j194-v6si3515015pgc.92.2018.05.15.05.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 05:01:26 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <20180515114755.GY12217@hirez.programming.kicks-ass.net>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <030fb555-017c-298a-823c-3b9dfd346461@netapp.com>
Date: Tue, 15 May 2018 15:01:06 +0300
MIME-Version: 1.0
In-Reply-To: <20180515114755.GY12217@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 15/05/18 14:47, Peter Zijlstra wrote:
> On Tue, May 15, 2018 at 01:43:23PM +0300, Boaz Harrosh wrote:
>> Yes I know, but that is exactly the point of this flag. I know that this
>> address is only ever accessed from a single core. Because it is an mmap (vma)
>> of an O_TMPFILE-exclusive file created in a core-pinned thread and I allow
>> only that thread any kind of access to this vma. Both the filehandle and the
>> mmaped pointer are kept on the thread stack and have no access from outside.
>>
>> So the all point of this flag is the kernel driver telling mm that this
>> address is enforced to only be accessed from one core-pinned thread.
> 
> What happens when the userspace part -- there is one, right, how else do
> you get an mm to stick a vma in -- simply does a full address range
> probe scan?
> 
> Something like this really needs a far more detailed Changelog that
> explains how its to be used and how it is impossible to abuse. Esp. that
> latter is _very_ important.
> 

Thank you yes. I will try and capture all this thread in the commit message
and as Christoph demanded supply a user code to demonstrate usage.

Thank you for looking
Boaz
