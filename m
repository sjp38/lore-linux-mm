Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id EDE6F6B0035
	for <linux-mm@kvack.org>; Sat, 13 Sep 2014 10:03:33 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id h18so1951618igc.3
        for <linux-mm@kvack.org>; Sat, 13 Sep 2014 07:03:33 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d14si8074784ici.39.2014.09.13.07.03.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 13 Sep 2014 07:03:33 -0700 (PDT)
Message-ID: <54144EAC.8030101@oracle.com>
Date: Sat, 13 Sep 2014 10:03:24 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/6] mm: introduce common page state for ballooned
 memory
References: <20140830163834.29066.98205.stgit@zurg>	<20140830164120.29066.8857.stgit@zurg>	<20140912165143.86d5f83dcde4a9fd78069f79@linux-foundation.org> <CALYGNiM0Uh1KG8Z6pFEAn=uxZBRPfHDffXjKkKJoG-K0hCaqaA@mail.gmail.com>
In-Reply-To: <CALYGNiM0Uh1KG8Z6pFEAn=uxZBRPfHDffXjKkKJoG-K0hCaqaA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>

On 09/13/2014 01:26 AM, Konstantin Khlebnikov wrote:
>> Did we really need to put the BalloonPages count into per-zone vmstat,
>> > global vmstat and /proc/meminfo?  Seems a bit overkillish - why so
>> > important?
> Balloon grabs random pages, their distribution among numa nodes might
> be important.
> But I know nobody who uses numa-aware vm together with ballooning.

*cough*. me?

Obviously there's no need to keep that per-zone vmstat just for me, but
right now NUMA on KVM works just fine and does a good job of catching
NUMA issues without having to run on actual metal.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
