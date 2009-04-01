Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7806F6B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 20:17:43 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n310HtMW022972
	for <linux-mm@kvack.org>; Wed, 1 Apr 2009 01:17:55 +0100
Received: from wf-out-1314.google.com (wfa25.prod.google.com [10.142.1.25])
	by wpaz13.hot.corp.google.com with ESMTP id n310Hr7j019741
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:17:53 -0700
Received: by wf-out-1314.google.com with SMTP id 25so3183456wfa.27
        for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:17:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090331150046.16539218.akpm@linux-foundation.org>
References: <604427e00812051140s67b2a89dm35806c3ee3b6ed7a@mail.gmail.com>
	 <20090331150046.16539218.akpm@linux-foundation.org>
Date: Tue, 31 Mar 2009 17:17:52 -0700
Message-ID: <604427e00903311717u20633bara3feca0c4f30e570@mail.gmail.com>
Subject: Re: [RFC v2][PATCH]page_fault retry with NOPAGE_RETRY
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, mikew@google.com, rientjes@google.com, rohitseth@google.com, hugh@veritas.com, a.p.zijlstra@chello.nl, hpa@zytor.com, edwintorok@gmail.com, lee.schermerhorn@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Thanks Andrew. I have the patches for all the arches and i just need
to clean them up a little bit. I will send them to you ASAP.

--Ying

On Tue, Mar 31, 2009 at 3:00 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 5 Dec 2008 11:40:19 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> changelog[v2]:
>> - reduce the runtime overhead by extending the 'write' flag of
>> =A0 handle_mm_fault() to indicate the retry hint.
>> - add another two branches in filemap_fault with retry logic.
>> - replace find_lock_page with find_lock_page_retry to make the code
>> =A0 cleaner.
>>
>> todo:
>> - there is potential a starvation hole with the retry. By the time the
>> =A0 retry returns, the pages might be released. we can make change by ho=
lding
>> =A0 page reference as well as remembering what the page "was"(in case th=
e
>> =A0 file was truncated). any suggestion here are welcomed.
>>
>> I also made patches for all other arch. I am posting x86_64 here first a=
nd
>> i will post others by the time everyone feels comfortable of this patch.
>
> I'm about to send this into Linus. =A0What happened to the patches for
> other architectures?
>
> Please send them over when convenient and I'll work on getting them
> trickled out to arch maintainers, thanks.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
