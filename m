Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m3TGlWYH016177
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 02:47:32 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3TGol6j276026
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 02:50:47 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3TGkl0F007996
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 02:46:47 +1000
Message-ID: <48175005.90400@linux.vnet.ibm.com>
Date: Tue, 29 Apr 2008 22:12:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Page Faults slower in 2.6.25-rc9 than 2.6.23
References: <d43160c70804290610t2135a271hd9b907529e89e74e@mail.gmail.com> <Pine.LNX.4.64.0804291447040.5058@blonde.site> <661de9470804290752w1dc0cfb3k72e81d828a45765e@mail.gmail.com> <d43160c70804290821i2bb0bc17m21b0c5838631e0b8@mail.gmail.com> <Pine.LNX.4.64.0804291629410.23101@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0804291629410.23101@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ross Biro <rossb@google.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 29 Apr 2008, Ross Biro wrote:
>> On Tue, Apr 29, 2008 at 10:52 AM, Balbir Singh
>> <balbir@linux.vnet.ibm.com> wrote:
>>>  Hmm.. strange.. I don't remember the overhead being so bad (I'll
>>>  relook at my old numbers). I'll try and git-bisect this one
>> I'm checking 2.6.24 now.  A quick run of 2.6.25-rc9 without fake numa
>> showed no real change.
> 
> Worth checking 2.6.24, yes.  But you've already made it clear that
> you do NOT have mem cgroups in your 2.6.25-rc9, so Balbir (probably)
> need not worry about your regression: my guess was wrong on that.
> 

Aah.. Yes... but I am definitely interested in figuring out the root cause for
the regression.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
