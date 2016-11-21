Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D83D76B04BF
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 21:09:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a8so198944203pfg.0
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 18:09:02 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id h24si19999380pfk.250.2016.11.20.18.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 18:09:02 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id e9so26606407pgc.1
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 18:09:01 -0800 (PST)
Subject: Re: [HMM v13 07/18] mm/ZONE_DEVICE/x86: add support for
 un-addressable device memory
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-8-git-send-email-jglisse@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <33e9c941-ac57-3dfd-2ed9-c1d058a57d8f@gmail.com>
Date: Mon, 21 Nov 2016 13:08:56 +1100
MIME-Version: 1.0
In-Reply-To: <1479493107-982-8-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>



On 19/11/16 05:18, JA(C)rA'me Glisse wrote:
> It does not need much, just skip populating kernel linear mapping
> for range of un-addressable device memory (it is pick so that there
> is no physical memory resource overlapping it). All the logic is in
> share mm code.
> 
> Only support x86-64 as this feature doesn't make much sense with
> constrained virtual address space of 32bits architecture.
> 

Is there a reason this would not work on powerpc64 for example?
Could you document the limitations -- testing/APIs/missing features?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
