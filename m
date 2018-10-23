Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 132F96B0005
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 13:13:40 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q18-v6so1001699pgv.16
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 10:13:40 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id ca6-v6si1881947plb.52.2018.10.23.10.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 10:13:38 -0700 (PDT)
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
 <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
 <20181023152640.GD20085@bombadil.infradead.org>
 <20181023170532.GW18839@dhcp22.suse.cz>
From: Shuah Khan <shuah@kernel.org>
Message-ID: <98842edb-d462-96b1-311f-27c6ebfc108a@kernel.org>
Date: Tue, 23 Oct 2018 11:13:36 -0600
MIME-Version: 1.0
In-Reply-To: <20181023170532.GW18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>
Cc: Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, Shuah Khan <shuah@kernel.org>

On 10/23/2018 11:05 AM, Michal Hocko wrote:
> On Tue 23-10-18 08:26:40, Matthew Wilcox wrote:
>> On Tue, Oct 23, 2018 at 09:02:56AM -0600, Shuah Khan wrote:
> [...]
>>> The way it can be handled is by adding a test module under lib. test_kmod,
>>> test_sysctl, test_user_copy etc.
>>
>> The problem is that said module can only invoke functions which are
>> exported using EXPORT_SYMBOL.  And there's a cost to exporting them,
>> which I don't think we're willing to pay, purely to get test coverage.
> 
> Yes, I think we do not want to export internal functionality which might
> be still interesting for the testing coverage. Maybe we want something
> like EXPORT_SYMBOL_KSELFTEST which would allow to link within the
> kselftest machinery but it wouldn't allow the same for general modules
> and will not give any API promisses.
> 

I like this proposal. I think we will open up lot of test opportunities with
this approach.

Maybe we can use this stress test as a pilot and see where it takes us.

thanks,
-- Shuah
