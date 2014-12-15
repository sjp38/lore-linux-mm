Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7566B008C
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:57:16 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so12658919pdb.4
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 15:57:16 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id l11si16099597pdj.98.2014.12.15.15.57.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 15:57:15 -0800 (PST)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9F2603EE0AE
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:57:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id ADC22AC0453
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:57:11 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A3E9E08001
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:57:11 +0900 (JST)
Message-ID: <548F7541.8040407@jp.fujitsu.com>
Date: Tue, 16 Dec 2014 08:56:49 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Stalled MM patches for review
References: <20141215150207.67c9a25583c04202d9f4508e@linux-foundation.org>
In-Reply-To: <20141215150207.67c9a25583c04202d9f4508e@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>

(2014/12/16 8:02), Andrew Morton wrote:
>
> I'm sitting on a bunch of patches which have question marks over them.
> I'll send them out now.  Can people please dig in and see if we can get
> them finished off one way or the other?
>
> My notes (which may be out of date):
>

Here are the threads of each discussion. Please use them as a reference.

> mm-page_isolation-check-pfn-validity-before-access.patch:
>    - Might be unneeded. mhocko has issues.

https://lkml.org/lkml/2014/11/6/79

>
> mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask.patch:
>    - Needs review and checking



> mm-page_alloc-embed-oom-killing-naturally-into-allocation-slowpath.patch:
>    - mhocko wanted a changelog update

https://lkml.org/lkml/2014/12/4/697

>
> mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone.patch:
>    - Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> has issues with it

https://lkml.org/lkml/2014/12/9/482

>
> mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch:
>    - Adds a comment whcih might not be true?
>

> fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch:
>    - Unsure whether or not this helps.

https://lkml.org/lkml/2014/2/15/245

Thanks,
Yasuaki Ishimatsu

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
