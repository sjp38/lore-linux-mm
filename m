Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m8ILBaeF022634
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 22:11:37 +0100
Received: from wf-out-1314.google.com (wff29.prod.google.com [10.142.6.29])
	by zps18.corp.google.com with ESMTP id m8ILBZJw004719
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 14:11:36 -0700
Received: by wf-out-1314.google.com with SMTP id 29so104376wff.3
        for <linux-mm@kvack.org>; Thu, 18 Sep 2008 14:11:35 -0700 (PDT)
Message-ID: <33307c790809181411j41a6fc4ev8560a13ed8661ec2@mail.gmail.com>
Date: Thu, 18 Sep 2008 14:11:35 -0700
From: "Martin Bligh" <mbligh@google.com>
Subject: Re: Populating multiple ptes at fault time
In-Reply-To: <48D2BFB8.6010503@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <48D142B2.3040607@goop.org> <48D1625C.7000309@redhat.com>
	 <48D17A93.4000803@goop.org> <48D29AFB.5070409@linux-foundation.org>
	 <48D2A392.6010308@goop.org>
	 <33307c790809181352h14f2cf26kc73de75b939177b5@mail.gmail.com>
	 <48D2BFB8.6010503@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Snook <csnook@redhat.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

>> Yup, basically you're assuming good locality of reference, but it turns
>> out that (as davej would say) "userspace sucks".
>
> Well, *most* userspace sucks.  It might still be worthwhile to do this when
> userspace is using madvise().

Quite possibly true ... something to benchmark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
