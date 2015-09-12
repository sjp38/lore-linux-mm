Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id CDED06B0038
	for <linux-mm@kvack.org>; Sat, 12 Sep 2015 02:18:23 -0400 (EDT)
Received: by iofh134 with SMTP id h134so120250703iof.0
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 23:18:23 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id ok17si5483076pab.94.2015.09.11.23.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 23:18:23 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so93841334pad.3
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 23:18:23 -0700 (PDT)
Subject: Re: [Bug 99471] System locks with kswapd0 and kworker taking full IO
 and mem
References: <bug-99471-27@https.bugzilla.kernel.org/>
 <bug-99471-27-hjYeBz7jw2@https.bugzilla.kernel.org/>
 <20150910140418.73b33d3542bab739f8fd1826@linux-foundation.org>
From: Raymond Jennings <shentino@gmail.com>
Message-ID: <55F3C3AC.6070800@gmail.com>
Date: Fri, 11 Sep 2015 23:18:20 -0700
MIME-Version: 1.0
In-Reply-To: <20150910140418.73b33d3542bab739f8fd1826@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, gaguilar@aguilardelgado.com, sgh@sgh.dk

On 09/10/15 14:04, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Tue, 01 Sep 2015 12:32:10 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=99471
> Guys, could you take a look please?
>
> The machine went oom when there's heaps of unused swap and most memory
> is being used on active_anon and inactive_anon.  We should have just
> swapped that stuff out and kept going.

Isn't there already logic in the kernel that disables OOM if there's 
swap space available?

I saw it once, what happened to it?
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
