Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22A0F6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 21:58:19 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so60701903pfb.6
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 18:58:19 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f192si34276238pfa.60.2016.11.07.18.58.17
        for <linux-mm@kvack.org>;
        Mon, 07 Nov 2016 18:58:18 -0800 (PST)
Date: Tue, 8 Nov 2016 11:54:25 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [REVISED DOC on v3] Crossrelease Lockdep
Message-ID: <20161108025425.GY2279@X58A-UD3R>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <20161102054242.GT2279@X58A-UD3R>
 <20161103081813.GV2279@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161103081813.GV2279@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Thu, Nov 03, 2016 at 05:18:13PM +0900, Byungchul Park wrote:
> Hello Peterz,
> 
> I tried to explain about what you asked me for.
> I wonder if I did it exactly. But I hope so.
> Please let me know if there's something more I need to add.

Just to be sure, are you concerning about sync and propagation delay of
memory contents including lock variables between cpus?

IMHO, it makes no difference. It's a true dependence once the dependency
is viewable by a cpu, which means anyway it actually happened. And please
remind all locks related to crosslocks are serialized via proper memory
barriers. I think this was already descibed in my document.

Is there something I missed? Please let me know.

Thank you,
Byungchul

> 
> Thank you,
> Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
