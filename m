Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id F0B036B0039
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 13:59:45 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so8539868pdj.16
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 10:59:45 -0800 (PST)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id i8si25764372pav.103.2014.02.04.10.57.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 10:57:13 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <87r47jsb2p.fsf@xmission.com>
	<1391530721.4301.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<871tzirdwf.fsf@xmission.com>
	<1391539464.10160.1.camel@edumazet-glaptop2.roam.corp.google.com>
Date: Tue, 04 Feb 2014 10:57:05 -0800
In-Reply-To: <1391539464.10160.1.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Tue, 04 Feb 2014 10:44:24 -0800")
Message-ID: <87r47ik8ou.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH] fdtable: Avoid triggering OOMs from alloc_fdmem
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Tue, 2014-02-04 at 09:22 -0800, Eric W. Biederman wrote:
>
>> The two code paths below certainly look good canidates for having
>> __GFP_NORETRY added to them.  The same issues I ran into with
>> alloc_fdmem are likely to show up there as well.
>
> Yes, this is what I thought : a write into TCP socket should be more
> frequent than the alloc_fdmem() case ;)
>
> But then, maybe your workload was only using UDP ?

As I have heard it described one tcp connection per small requestion,
and someone goofed and started creating new connections when the server
was bogged down.  But since all of the requests and replies were small I
don't expect even TCP would allocate more than a 4KiB page in that
worload.

I had oodles of 4KiB and 8KiB pages.  What size of memory allocation did
you see failing?  

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
