Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3243C6B006C
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 19:42:52 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id vb8so15791501obc.7
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:42:52 -0800 (PST)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id 79si6344186oim.124.2015.01.09.16.42.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 16:42:51 -0800 (PST)
Received: by mail-oi0-f45.google.com with SMTP id x69so14259368oia.4
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:42:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA25o9T=sif3COXWK58OsCJW5ZM-7WgsREq3CW1mfPPv+K_Dgg@mail.gmail.com>
References: <CAA25o9Sf62u3mJtBp_swLL0RS2Zb=EjZtWERJqyrbBpk7-bP-A@mail.gmail.com>
	<20150108223024.da818218.akpm@linux-foundation.org>
	<CAA25o9SQfb3yO2D4ABeeYoZkurhxramAgckr9DVOG1=DwVF0qg@mail.gmail.com>
	<CAAmzW4Oqo7KoYD5Mx+jVpo1Yt3xSt+vKuTSgf=AMXsu-nRDtwQ@mail.gmail.com>
	<CAA25o9T=sif3COXWK58OsCJW5ZM-7WgsREq3CW1mfPPv+K_Dgg@mail.gmail.com>
Date: Sat, 10 Jan 2015 09:42:50 +0900
Message-ID: <CAAmzW4NZUvzuvpkzRCXXYnbSeN-5nzFdBrwnw83XoHnG982UKQ@mail.gmail.com>
Subject: Re: mm performance with zram
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

2015-01-10 9:19 GMT+09:00 Luigi Semenzato <semenzato@google.com>:
> Thank you!  I am using perf version 3.13.11.10, will look for newer versions.

I said one misleading word, 'default'. Command should have -g option
when recording.

perf record -g xxxx
perf report

And, I did quick test and found that this ability can be usable with >= 3.16.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
