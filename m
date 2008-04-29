Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m3TG5EEE020141
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 17:05:14 +0100
Received: from fg-out-1718.google.com (fge22.prod.google.com [10.86.5.22])
	by zps35.corp.google.com with ESMTP id m3TG5CWX010924
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 09:05:13 -0700
Received: by fg-out-1718.google.com with SMTP id 22so61662fge.19
        for <linux-mm@kvack.org>; Tue, 29 Apr 2008 09:05:12 -0700 (PDT)
Message-ID: <d43160c70804290905m1e451435q2766f552f2b6767c@mail.gmail.com>
Date: Tue, 29 Apr 2008 12:05:12 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: Page Faults slower in 2.6.25-rc9 than 2.6.23
In-Reply-To: <Pine.LNX.4.64.0804291629410.23101@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70804290610t2135a271hd9b907529e89e74e@mail.gmail.com>
	 <Pine.LNX.4.64.0804291447040.5058@blonde.site>
	 <661de9470804290752w1dc0cfb3k72e81d828a45765e@mail.gmail.com>
	 <d43160c70804290821i2bb0bc17m21b0c5838631e0b8@mail.gmail.com>
	 <Pine.LNX.4.64.0804291629410.23101@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 11:32 AM, Hugh Dickins <hugh@veritas.com> wrote:
>> I'm checking 2.6.24 now.  A quick run of 2.6.25-rc9 without fake numa
>> showed no real change.
>

2.6.24 is slower as well.  I can't say for sure it's the full 10%
without more work than it's worth.  But it is definitely significantly
slower than 2.6.23.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
