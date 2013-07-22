Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id ED4B06B0032
	for <linux-mm@kvack.org>; Sun, 21 Jul 2013 20:43:02 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 22 Jul 2013 06:07:17 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 3A1F33940057
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 06:12:53 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6M0greY29818992
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 06:12:54 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6M0guoD005418
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 10:42:56 +1000
Date: Mon, 22 Jul 2013 08:42:55 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/slub.c: add parameter length checking for
 alloc_loc_track()
Message-ID: <20130722004255.GA13225@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <51DF5404.4060004@asianux.com>
 <0000013fd3250e40-1832fd38-ede3-41af-8fe3-5a0c10f5e5ce-000000@email.amazonses.com>
 <51E33F98.8060201@asianux.com>
 <0000013fe2e73e30-817f1bdb-8dc7-4f7b-9b60-b42d5d244fda-000000@email.amazonses.com>
 <51E49BDF.30008@asianux.com>
 <0000013fed280250-85b17e35-d4d4-468d-abed-5b2e29cedb94-000000@email.amazonses.com>
 <51E73A16.8070406@asianux.com>
 <0000013ff2076fb0-b52e0245-8fb5-4842-b0dd-d812ce2c9f62-000000@email.amazonses.com>
 <51E882E1.4000504@gmail.com>
 <0000013ff73897b8-9d8f4486-1632-470c-8f1f-caf44932cef1-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013ff73897b8-9d8f4486-1632-470c-8f1f-caf44932cef1-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Chen Gang F T <chen.gang.flying.transformer@gmail.com>, Chen Gang <gang.chen@asianux.com>, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jul 19, 2013 at 01:57:28PM +0000, Christoph Lameter wrote:
>On Fri, 19 Jul 2013, Chen Gang F T wrote:
>
>> Yes, "'max' can roughly mean the same thing", but they are still a
>> little different.
>>
>> 'max' also means: "the caller tells callee: I have told you the
>> maximize buffer length, so I need not check the buffer length to be
>> sure of no memory overflow, you need be sure of it".
>>
>> 'size' means: "the caller tells callee: you should use the size which I
>> give you, I am sure it is OK, do not care about whether it can cause
>> memory overflow or not".
>
>Ok that makes sense.
>
>> The diff may like this:
>
>I am fine with such a patch.
>
>Ultimately I would like the tracking and debugging technology to be
>abstracted from the slub allocator and made generally useful by putting it
>into mm/slab_common.c. SLAB has similar things but does not have all the
>features.
	
Coincidence, I am doing this work recently and will post patches soon.
;-)

Regards,
Wanpeng Li 

>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
