Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m8IM8YlP000687
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 23:08:34 +0100
Received: from wf-out-1314.google.com (wfd26.prod.google.com [10.142.4.26])
	by zps77.corp.google.com with ESMTP id m8IM8CAe002518
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 15:08:33 -0700
Received: by wf-out-1314.google.com with SMTP id 26so139064wfd.26
        for <linux-mm@kvack.org>; Thu, 18 Sep 2008 15:08:33 -0700 (PDT)
Message-ID: <33307c790809181508v2e64c0a4j8f0e93df99673e63@mail.gmail.com>
Date: Thu, 18 Sep 2008 15:08:33 -0700
From: "Martin Bligh" <mbligh@google.com>
Subject: Re: Populating multiple ptes at fault time
In-Reply-To: <48D2CEF3.6060308@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <48D142B2.3040607@goop.org> <48D2A392.6010308@goop.org>
	 <33307c790809181352h14f2cf26kc73de75b939177b5@mail.gmail.com>
	 <48D2BFB8.6010503@redhat.com>
	 <33307c790809181411j41a6fc4ev8560a13ed8661ec2@mail.gmail.com>
	 <48D2C46A.5030702@linux-foundation.org>
	 <33307c790809181421k52ed6a36h9d4ee40d5799a536@mail.gmail.com>
	 <48D2C8DD.4040303@linux-foundation.org>
	 <28c262360809181449v1050c1f7ndf17dadba9fac0bf@mail.gmail.com>
	 <48D2CEF3.6060308@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: MinChan Kim <minchan.kim@gmail.com>, Chris Snook <csnook@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> My patches were only for anonymous pages not for file backed because readahead
> is available for file backed mappings.

Do we populate the PTEs though? I didn't think that was batched, but I
might well be wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
