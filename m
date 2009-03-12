Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EE6CB6B007E
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 07:39:37 -0400 (EDT)
Received: by bwz18 with SMTP id 18so372719bwz.38
        for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:39:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090312111443.GA20569@localhost>
References: <20090311114353.GA759@localhost> <20090311121123.GA7656@localhost>
	 <e2dc2c680903110516v2c66d4a4h6a422cffceb12e2@mail.gmail.com>
	 <20090311122611.GA8804@localhost>
	 <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com>
	 <20090312075952.GA19331@localhost>
	 <e2dc2c680903120104h4d19a3f6j57ad045bc06f9a90@mail.gmail.com>
	 <20090312081113.GA19506@localhost>
	 <e2dc2c680903120148j1aee0759td49055be059e33ae@mail.gmail.com>
	 <20090312111443.GA20569@localhost>
Date: Thu, 12 Mar 2009 12:39:36 +0100
Message-ID: <e2dc2c680903120439i73aa1db8y8e53285ddbfbb8ba@mail.gmail.com>
Subject: Re: Memory usage per memory zone
From: jack marrow <jackmarrow2@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> btw, how much physical memory do you have?
> It's weird that meminfo says 1G but Mem-Info says 4G...

4 gigs.

# free -m
             total       used       free     shared    buffers     cached
Mem:          3804       1398       2405          0          1        240
-/+ buffers/cache:       1156       2648
Swap:         1992        403       1588

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
