Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 09B416B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 21:06:46 -0400 (EDT)
Received: by mail-yk0-f174.google.com with SMTP id 20so3607428yks.33
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 18:06:46 -0700 (PDT)
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com. [15.193.200.69])
        by mx.google.com with ESMTPS id f46si11214422yho.0.2014.04.04.18.06.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 04 Apr 2014 18:06:46 -0700 (PDT)
Message-ID: <1396660004.2461.1.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [mm] e04ddfd12aa: +9.4% ebizzy.throughput
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 04 Apr 2014 18:06:44 -0700
In-Reply-To: <20140404135908.GB22386@localhost>
References: <20140404135908.GB22386@localhost>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org

On Fri, 2014-04-04 at 21:59 +0800, Fengguang Wu wrote:
> Hi Davidlohr,
> 
> FYI, there are noticeable ebizzy throughput increases on commit
> e04ddfd12aa03471eff7daf3bc2435c7cea8e21f ("mm: per-thread vma caching")

Cool, thanks for letting me know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
