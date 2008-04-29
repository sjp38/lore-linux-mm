Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m3TFLgd6009993
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 16:21:42 +0100
Received: from fg-out-1718.google.com (fgae12.prod.google.com [10.86.56.12])
	by zps37.corp.google.com with ESMTP id m3TFLe2u015209
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 08:21:41 -0700
Received: by fg-out-1718.google.com with SMTP id e12so36636fga.8
        for <linux-mm@kvack.org>; Tue, 29 Apr 2008 08:21:40 -0700 (PDT)
Message-ID: <d43160c70804290821i2bb0bc17m21b0c5838631e0b8@mail.gmail.com>
Date: Tue, 29 Apr 2008 11:21:40 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: Page Faults slower in 2.6.25-rc9 than 2.6.23
In-Reply-To: <661de9470804290752w1dc0cfb3k72e81d828a45765e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70804290610t2135a271hd9b907529e89e74e@mail.gmail.com>
	 <Pine.LNX.4.64.0804291447040.5058@blonde.site>
	 <661de9470804290752w1dc0cfb3k72e81d828a45765e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 10:52 AM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
>  Hmm.. strange.. I don't remember the overhead being so bad (I'll
>  relook at my old numbers). I'll try and git-bisect this one

I'm checking 2.6.24 now.  A quick run of 2.6.25-rc9 without fake numa
showed no real change.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
