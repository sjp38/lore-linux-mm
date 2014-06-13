Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA1D6B0092
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 01:31:12 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so230893wib.3
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:31:11 -0700 (PDT)
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
        by mx.google.com with ESMTPS id db7si4845287wjb.99.2014.06.12.22.31.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 22:31:11 -0700 (PDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so2160636wgg.25
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:31:10 -0700 (PDT)
Date: Fri, 13 Jun 2014 08:31:07 +0300
From: Dan Aloni <dan@kernelim.com>
Subject: Re: mm/sched/net: BUG when running simple code
Message-ID: <20140613053107.GA24200@gmail.com>
References: <539A6850.4090408@oracle.com>
 <20140613032754.GA20729@gmail.com>
 <539A77A1.60700@oracle.com>
 <20140613045555.GB20729@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140613045555.GB20729@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Fri, Jun 13, 2014 at 07:55:55AM +0300, Dan Aloni wrote:
> And also, the Oops code of 0003 (PF_WRITE and PF_USER) might hint at
> what Dave wrote.

Scrape what I wrote about that, it's PF_PROT | PF_WRITE.

-- 
Dan Aloni

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
