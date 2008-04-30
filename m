Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m3UDGH6P017746
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 14:16:17 +0100
Received: from fg-out-1718.google.com (fgg16.prod.google.com [10.86.7.16])
	by zps38.corp.google.com with ESMTP id m3UDGFlt002910
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 06:16:16 -0700
Received: by fg-out-1718.google.com with SMTP id 16so149957fgg.23
        for <linux-mm@kvack.org>; Wed, 30 Apr 2008 06:16:15 -0700 (PDT)
Message-ID: <d43160c70804300616v6eb89ea8re22af1956b11f012@mail.gmail.com>
Date: Wed, 30 Apr 2008 09:16:15 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: Page Faults slower in 2.6.25-rc9 than 2.6.23
In-Reply-To: <d43160c70804291000k5de1b657sc1f381e08ecaeb07@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70804290610t2135a271hd9b907529e89e74e@mail.gmail.com>
	 <Pine.LNX.4.64.0804291447040.5058@blonde.site>
	 <661de9470804290752w1dc0cfb3k72e81d828a45765e@mail.gmail.com>
	 <d43160c70804290821i2bb0bc17m21b0c5838631e0b8@mail.gmail.com>
	 <Pine.LNX.4.64.0804291629410.23101@blonde.site>
	 <48175005.90400@linux.vnet.ibm.com>
	 <d43160c70804291000k5de1b657sc1f381e08ecaeb07@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 1:00 PM, Ross Biro <rossb@google.com> wrote:
> > Aah.. Yes... but I am definitely interested in figuring out the root cause for
>  > the regression.
>
>  I can't reproduce the 2.6.23 results.  I'm going to run the benchmarks
>  a few more times, but I'm suspecting something changed with the
>  hardware.

The 2.6.23 results have been consistant with 2.6.24 results and
lmbench has crashed my test machine at least once.  I'm guessing some
sort of memory error causing a lot of ECC and slowing things down.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
