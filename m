Received: by ug-out-1314.google.com with SMTP id 34so1612944ugf.19
        for <linux-mm@kvack.org>; Thu, 27 Nov 2008 05:23:18 -0800 (PST)
Message-ID: <492E9F42.6010808@gmail.com>
Date: Thu, 27 Nov 2008 15:23:14 +0200
From: =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
References: <492DAA24.8040100@google.com> <20081127085554.GD28285@wotan.suse.de> <492E6849.6090205@google.com> <492E8708.4060601@gmail.com> <20081127120330.GM28285@wotan.suse.de> <492E90BC.1090208@gmail.com> <20081127123926.GN28285@wotan.suse.de> <492E97FA.5000804@gmail.com> <20081127130525.GO28285@wotan.suse.de> <492E9C3C.9050507@gmail.com> <20081127131215.GQ28285@wotan.suse.de>
In-Reply-To: <20081127131215.GQ28285@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Mike Waychison <mikew@google.com>, Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On 2008-11-27 15:12, Nick Piggin wrote:
> On Thu, Nov 27, 2008 at 03:10:20PM +0200, Torok Edwin wrote:
>   
>>
>> Ok. Sorry for hijacking the thread, my testcase is not a good testcase
>> for what this patch tries to solve.
>>     
>
> No not at all. It's always really useful to hear any problems like this.
> I'd like you to keep participating... for one thing I'd like you to test
> my mmap_sem patch ;) (when I finish it)

Sure, just send me your patch when it is ready (together, or
before/after the rwsems patch).

Best regards,
--Edwin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
