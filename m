Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8655C6B034B
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 17:00:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l124so24364684wml.4
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 14:00:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jn10si17288996wjb.274.2016.11.04.14.00.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Nov 2016 14:00:28 -0700 (PDT)
Subject: Re: [Bug 186671] New: OOM on system with just rsync running 32GB of
 ram 30GB of pagecache
References: <bug-186671-27@https.bugzilla.kernel.org/>
 <20161103115353.de87ff35756a4ca8b21d2c57@linux-foundation.org>
 <b5b0cef0-8482-e4de-cb81-69a4dd3410fb@suse.cz>
 <CAJtFHUQcJKSnyQ7t7-eDpiF2C+U23+iWpZ+X6fGEzN8qdbzmtA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a8cf869e-f527-9c65-d16d-ac70cf66472a@suse.cz>
Date: Fri, 4 Nov 2016 22:00:16 +0100
MIME-Version: 1.0
In-Reply-To: <CAJtFHUQcJKSnyQ7t7-eDpiF2C+U23+iWpZ+X6fGEzN8qdbzmtA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: E V <eliventer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, linux-btrfs <linux-btrfs@vger.kernel.org>

On 11/04/2016 03:13 PM, E V wrote:
> After the system panic'd yesterday I booted back into 4.8.4 and
> restarted the rsync's. I'm away on vacation next week, so when I get
> back I'll get rc4 or rc5 and try again. In the mean time here's data
> from the system running 4.8.4 without problems for about a day. I'm
> not familiar with xxd and didn't see a -e option, so used -E:
> xxd -E -g8 -c8 /proc/kpagecount | cut -d" " -f2 | sort | uniq -c
> 8258633 0000000000000000
>  216440 0100000000000000

The lack of -e means it's big endian, which is not a big issue. So here
most of memory is free, some pages have just one pin, and only
relatively few have more. The vmstats also doesn't show anything bad, so
we'll have to wait if something appears within the week, or after you
try 4.9 again. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
