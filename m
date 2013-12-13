Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id EA14E6B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 17:38:48 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id l109so2041876yhq.19
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 14:38:48 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id p5si3389948yho.159.2013.12.13.14.38.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Dec 2013 14:38:47 -0800 (PST)
Message-ID: <52AB8C68.1040305@zytor.com>
Date: Fri, 13 Dec 2013 14:38:32 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
References: <1386964870-6690-1-git-send-email-mgorman@suse.de> <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
In-Reply-To: <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/13/2013 01:16 PM, Linus Torvalds wrote:
> On Fri, Dec 13, 2013 at 12:01 PM, Mel Gorman <mgorman@suse.de> wrote:
>>
>> ebizzy
>>                       3.13.0-rc3                3.4.69            3.13.0-rc3            3.13.0-rc3
>>       thread             vanilla               vanilla       altershift-v2r1           nowalk-v2r7
>> Mean     1     7377.91 (  0.00%)     6812.38 ( -7.67%)     7784.45 (  5.51%)     7804.08 (  5.78%)
>> Mean     2     8262.07 (  0.00%)     8276.75 (  0.18%)     9437.49 ( 14.23%)     9450.88 ( 14.39%)
>> Mean     3     7895.00 (  0.00%)     8002.84 (  1.37%)     8875.38 ( 12.42%)     8914.60 ( 12.91%)
>> Mean     4     7658.74 (  0.00%)     7824.83 (  2.17%)     8509.10 ( 11.10%)     8399.43 (  9.67%)
>> Mean     5     7275.37 (  0.00%)     7678.74 (  5.54%)     8208.94 ( 12.83%)     8197.86 ( 12.68%)
>> Mean     6     6875.50 (  0.00%)     7597.18 ( 10.50%)     7755.66 ( 12.80%)     7807.51 ( 13.56%)
>> Mean     7     6722.48 (  0.00%)     7584.75 ( 12.83%)     7456.93 ( 10.93%)     7480.74 ( 11.28%)
>> Mean     8     6559.55 (  0.00%)     7591.51 ( 15.73%)     6879.01 (  4.87%)     6881.86 (  4.91%)
> 
> Hmm. Do you have any idea why 3.4.69 still seems to do better at
> higher thread counts?
> 
> No complaints about this patch-series, just wondering..
> 

It would be really great to get some performance numbers on something
other than ebizzy, though...

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
