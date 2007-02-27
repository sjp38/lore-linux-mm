Received: by ug-out-1314.google.com with SMTP id s2so955742uge
        for <linux-mm@kvack.org>; Mon, 26 Feb 2007 20:36:04 -0800 (PST)
Message-ID: <21d7e9970702262036h3575229ex3bf3cd4474a57068@mail.gmail.com>
Date: Tue, 27 Feb 2007 15:36:03 +1100
From: "Dave Airlie" <airlied@gmail.com>
Subject: Re: [patch 0/6] fault vs truncate/invalidate race fix
In-Reply-To: <20070221023656.6306.246.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070221023656.6306.246.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

>
> I've also got rid of the horrible populate API, and integrated nonlinear pages
> properly with the page fault path.
>
> Downside is that this adds one more vector through which the buffered write
> deadlock can occur. However this is just a very tiny one (pte being unmapped
> for reclaim), compared to all the other ways that deadlock can occur (unmap,
> reclaim, truncate, invalidate). I doubt it will be noticable. At any rate, it
> is better than data corruption.
>
> I hope these can get merged (at least into -mm) soon.

Have these been put into mm? can I expect them in the next -mm so I
can start merging up the drm memory manager code to my -mm tree..

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
