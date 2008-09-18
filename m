Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id m8ILLMp6001152
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 22:21:22 +0100
Received: from wf-out-1314.google.com (wfc25.prod.google.com [10.142.3.25])
	by wpaz29.hot.corp.google.com with ESMTP id m8ILKAaP017713
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 14:21:21 -0700
Received: by wf-out-1314.google.com with SMTP id 25so136408wfc.12
        for <linux-mm@kvack.org>; Thu, 18 Sep 2008 14:21:21 -0700 (PDT)
Message-ID: <33307c790809181421k52ed6a36h9d4ee40d5799a536@mail.gmail.com>
Date: Thu, 18 Sep 2008 14:21:21 -0700
From: "Martin Bligh" <mbligh@google.com>
Subject: Re: Populating multiple ptes at fault time
In-Reply-To: <48D2C46A.5030702@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <48D142B2.3040607@goop.org> <48D1625C.7000309@redhat.com>
	 <48D17A93.4000803@goop.org> <48D29AFB.5070409@linux-foundation.org>
	 <48D2A392.6010308@goop.org>
	 <33307c790809181352h14f2cf26kc73de75b939177b5@mail.gmail.com>
	 <48D2BFB8.6010503@redhat.com>
	 <33307c790809181411j41a6fc4ev8560a13ed8661ec2@mail.gmail.com>
	 <48D2C46A.5030702@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Chris Snook <csnook@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

>>>> Yup, basically you're assuming good locality of reference, but it turns
>>>> out that (as davej would say) "userspace sucks".
>>> Well, *most* userspace sucks.  It might still be worthwhile to do this when
>>> userspace is using madvise().
>>
>> Quite possibly true ... something to benchmark.
>
> Well, I guess we need a new binary format that allows one to execute binaries
> in kernel address space with full powers.

Seems ... extreme ;-)
Maybe we just do it if we're in readahead? (or similar)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
