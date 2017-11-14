Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 177596B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 13:29:11 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r12so9976808pgu.9
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 10:29:11 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 197si5720860pgg.741.2017.11.14.10.29.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 10:29:10 -0800 (PST)
Subject: Re: [PATCH 18/30] x86, kaiser: map virtually-addressed performance
 monitoring buffers
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193139.B039E97B@viggo.jf.intel.com>
 <20171114182009.jbhobwxlkfjb2t6i@hirez.programming.kicks-ass.net>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <30655167-963f-09e3-f88f-600bb95407e8@linux.intel.com>
Date: Tue, 14 Nov 2017 10:28:50 -0800
MIME-Version: 1.0
In-Reply-To: <20171114182009.jbhobwxlkfjb2t6i@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, x86@kernel.org

On 11/14/2017 10:20 AM, Peter Zijlstra wrote:
> On Fri, Nov 10, 2017 at 11:31:39AM -0800, Dave Hansen wrote:
>>  static int alloc_ds_buffer(int cpu)
>>  {
>> +	struct debug_store *ds = per_cpu_ptr(&cpu_debug_store, cpu);
>>  
>> +	memset(ds, 0, sizeof(*ds));
> Still wondering about that memset...

My guess is that it was done to mirror the zeroing done by the original
kzalloc().  But, I think you're right that it's zero'd already by virtue
of being static:

static
DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct debug_store,
cpu_debug_store);

I'll queue a cleanup, or update it if I re-post the set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
