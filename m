Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 77CB76B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 17:04:20 -0400 (EDT)
Received: by qgev79 with SMTP id v79so46955843qge.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 14:04:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b16si11753589qhc.47.2015.09.10.14.04.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 14:04:19 -0700 (PDT)
Date: Thu, 10 Sep 2015 14:04:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 99471] System locks with kswapd0 and kworker taking full
 IO and mem
Message-Id: <20150910140418.73b33d3542bab739f8fd1826@linux-foundation.org>
In-Reply-To: <bug-99471-27-hjYeBz7jw2@https.bugzilla.kernel.org/>
References: <bug-99471-27@https.bugzilla.kernel.org/>
	<bug-99471-27-hjYeBz7jw2@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, gaguilar@aguilardelgado.com, sgh@sgh.dk

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 01 Sep 2015 12:32:10 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=99471

Guys, could you take a look please?

The machine went oom when there's heaps of unused swap and most memory
is being used on active_anon and inactive_anon.  We should have just
swapped that stuff out and kept going.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
