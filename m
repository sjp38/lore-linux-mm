Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id C912B6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 10:43:18 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so5433069qcy.1
        for <linux-mm@kvack.org>; Tue, 12 May 2015 07:43:18 -0700 (PDT)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com. [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id o5si11618246qko.11.2015.05.12.07.43.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 07:43:17 -0700 (PDT)
Received: by qcbgu10 with SMTP id gu10so5392128qcb.2
        for <linux-mm@kvack.org>; Tue, 12 May 2015 07:43:17 -0700 (PDT)
Date: Tue, 12 May 2015 10:43:13 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] PM, freezer: Don't thaw when it's intended frozen
 processes
Message-ID: <20150512144313.GO11388@htj.duckdns.org>
References: <20150507064557.GA26928@july>
 <20150507154212.GA12245@htj.duckdns.org>
 <CAH9JG2UAVRgX0Mg0d7WgG0URpkgu4q_bbNMXyOOEh9WFPztppQ@mail.gmail.com>
 <20150508152513.GB28439@htj.duckdns.org>
 <CAH9JG2VROCekWCAa+1t6Giy2wHC171TD-AXQVxG2vTH-LPcoPA@mail.gmail.com>
 <CAH9JG2W6pKi__g-v+9B+-y3HJ=AkdE+W0d0TxmtpBWrXddxL_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH9JG2W6pKi__g-v+9B+-y3HJ=AkdE+W0d0TxmtpBWrXddxL_g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "\\Rafael J. Wysocki\\" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>

Hello,

On Mon, May 11, 2015 at 04:47:14PM +0900, Kyungmin Park wrote:
> > The kernel 3.10 is not working as expected, but right the latest
> > kernel is working correctly.
> 
> Please ignore it. test is wrong and it's not working, see Krzysztof Mail.

So, I just tested and it does work as expected.  What Krzysztof said
is the same thing that I said in the first reply.  The tasks will be
woken up but won't leave freezer.  Please re-test.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
