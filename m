Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m3TH0Za5008712
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 18:00:36 +0100
Received: from fg-out-1718.google.com (fgad23.prod.google.com [10.86.55.23])
	by zps37.corp.google.com with ESMTP id m3TH0UC1020015
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 10:00:33 -0700
Received: by fg-out-1718.google.com with SMTP id d23so64976fga.33
        for <linux-mm@kvack.org>; Tue, 29 Apr 2008 10:00:29 -0700 (PDT)
Message-ID: <d43160c70804291000k5de1b657sc1f381e08ecaeb07@mail.gmail.com>
Date: Tue, 29 Apr 2008 13:00:29 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: Page Faults slower in 2.6.25-rc9 than 2.6.23
In-Reply-To: <48175005.90400@linux.vnet.ibm.com>
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
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 12:42 PM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
> Aah.. Yes... but I am definitely interested in figuring out the root cause for
> the regression.

I can't reproduce the 2.6.23 results.  I'm going to run the benchmarks
a few more times, but I'm suspecting something changed with the
hardware.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
