Received: by ey-out-1920.google.com with SMTP id 21so2314810eyc.44
        for <linux-mm@kvack.org>; Thu, 04 Dec 2008 22:50:09 -0800 (PST)
Message-ID: <4938CF1C.9020503@gmail.com>
Date: Fri, 05 Dec 2008 08:50:04 +0200
From: =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
References: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com>	 <20081126123246.GB23649@wotan.suse.de> <492DAA24.8040100@google.com>	 <20081127085554.GD28285@wotan.suse.de> <492E6849.6090205@google.com>	 <492E8708.4060601@gmail.com> <20081127120330.GM28285@wotan.suse.de>	 <492E90BC.1090208@gmail.com> <20081127123926.GN28285@wotan.suse.de>	 <492E97FA.5000804@gmail.com> <604427e00812041427j7f1c8118p48b1b5b577143703@mail.gmail.com>
In-Reply-To: <604427e00812041427j7f1c8118p48b1b5b577143703@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Nick Piggin <npiggin@suse.de>, Mike Waychison <mikew@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On 2008-12-05 00:27, Ying Han wrote:
> I am trying your test program(scalability) in house, but somehow i got
> different result as you saw. i created 8 files each with 1G size on
> separate drives( to avoid the latency disturbing of disk seek). I got
> this number without applying the batch based on 2.6.26. May i ask how
> to reproduce the mmap issue you mentioned?
>   

Hi,

Try using more files, and of smaller size.  I was using /usr/bin, which
has 3632 files, and 571M total.
I am using XFS filesystem: /dev/mapper/vg--all-lv--usr on /usr type xfs
(rw,noatime,logbsize=262144,logbufs=8,logdev=/dev/sdg6,inode64)


> 8 CPU
> read_worker
> 1 threads Real time: 101.058262 s (since task start)
> 2 threads Real time: 50.670456 s (since task start)
> 4 threads Real time: 25.904657 s (since task start)
> 8 threads Real time: 20.090677 s (since task start)
> --------------------------------------------------------------------------------
> mmap_worker
> 1 threads Real time: 101.340662 s (since task start)
> 2 threads Real time: 51.484646 s (since task start)
> 4 threads Real time: 28.414534 s (since task start)
> 8 threads Real time: 21.785818 s (since task start)
>   


Try 16 threads, so that there is more contention on the read side as well.

Best regards,
--Edwin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
