Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 4D5466B00F6
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 10:19:50 -0500 (EST)
Received: by yhoo22 with SMTP id o22so2277826yho.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 07:19:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329491708.2293.277.camel@twins>
References: <1329488869-7270-1-git-send-email-consul.kautuk@gmail.com>
	<1329491708.2293.277.camel@twins>
Date: Fri, 17 Feb 2012 10:19:49 -0500
Message-ID: <CAFPAmTRrW4rAiC6UPGCFWChyuAjtbn7pkXRm3L2_SYdrRQCBZQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] rmap: Staticize page_referenced_file and page_referenced_anon
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 17, 2012 at 10:15 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Fri, 2012-02-17 at 09:27 -0500, Kautuk Consul wrote:
>> Staticize the page_referenced_anon and page_referenced_file
>> functions.
>> These functions are called only from page_referenced.
>
> Subject and changelog say: staticize, which I read to mean: make static.
> Yet what the patch does is make them inline ?!?

Yes, sorry my mistake. :)

>
> Also, if they're static and there's only a single callsite, gcc will
> already inline them, does this patch really make a difference?

I just sent this patch for what I thought was "correctness", but I guess
we can let this be if you are absolutely sure that all GCC cross compilers
for all platforms will guarantee inlining.



>
>> -static int page_referenced_anon(struct page *page,
>> +static inline int page_referenced_anon(struct page *page,
>
>


Please reply back if you feel I should resend this patch with modified
description.
Else, I'll just forget about this one. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
