Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 391356B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 16:50:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f132-v6so1320663pgc.21
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 13:50:57 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l9-v6si2270753pgi.509.2018.10.23.13.50.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 13:50:56 -0700 (PDT)
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
 <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
 <20181023152640.GD20085@bombadil.infradead.org>
 <20181023170532.GW18839@dhcp22.suse.cz>
 <98842edb-d462-96b1-311f-27c6ebfc108a@kernel.org>
 <20181023193044.GA139403@joelaf.mtv.corp.google.com>
 <024af44a-77e1-1c61-c9b2-64ffbe4f7c49@kernel.org>
 <20181023200923.GB25444@bombadil.infradead.org>
From: Shuah Khan <shuah@kernel.org>
Message-ID: <ffec3806-969d-62df-2965-e8800babb8a1@kernel.org>
Date: Tue, 23 Oct 2018 14:50:53 -0600
MIME-Version: 1.0
In-Reply-To: <20181023200923.GB25444@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Joel Fernandes <joel@joelfernandes.org>, Michal Hocko <mhocko@kernel.org>, Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, maco@android.com, Shuah Khan <shuah@kernel.org>

On 10/23/2018 02:09 PM, Matthew Wilcox wrote:
> On Tue, Oct 23, 2018 at 01:48:32PM -0600, Shuah Khan wrote:
>> On 10/23/2018 01:30 PM, Joel Fernandes wrote:
>>> On Tue, Oct 23, 2018 at 11:13:36AM -0600, Shuah Khan wrote:
>>>> I like this proposal. I think we will open up lot of test opportunities with
>>>> this approach.
>>>>
>>>> Maybe we can use this stress test as a pilot and see where it takes us.
>>>
>>> I am a bit worried that such an EXPORT_SYMBOL_KSELFTEST mechanism can be abused by
>>> out-of-tree module writers to call internal functionality.
>>
>> That is  valid concern to consider before we go forward with the proposal.
>>
>> We could wrap EXPORT_SYMBOL_KSELFTEST this in an existing debug option. This could
>> be fine grained for each sub-system for its debug option. We do have a few of these
>> now
> 
> This all seems far more complicated than my proposed solution.
> 

Not sure if it that complicated. But it is more involved. It dies have the
advantage of fitting in with the rest of the debug/test type framework we
already have.

The option you proposed sounds simpler, however it sounds a bit adhoc to me.

In any case I went looking for EXPORT_SYMBOL defines and found them in 

tools/include/asm/export.h
tools/include/linux/export.h
tools/virtio/linux/export.h

selftests/powerpc/copyloops/asm/export.h
selftests/powerpc/stringloops/asm/export.h

thanks,
-- Shuah
