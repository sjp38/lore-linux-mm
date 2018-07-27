Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFA956B0006
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:23:52 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id p7-v6so1909721wrv.15
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:23:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l8-v6si4164405wrv.161.2018.07.27.14.23.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 14:23:51 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6RLIW2v017642
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:23:50 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kgb0ngg6u-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:23:49 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 27 Jul 2018 22:23:48 +0100
Date: Sat, 28 Jul 2018 00:23:40 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mips: switch to NO_BOOTMEM
References: <1531727262-11520-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726070355.GD8477@rapoport-lnx>
 <20180726172005.pgjmkvwz2lpflpor@pburton-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726172005.pgjmkvwz2lpflpor@pburton-laptop>
Message-Id: <20180727212339.GC17745@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Burton <paul.burton@mips.com>
Cc: linux-mips@linux-mips.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Serge Semin <fancer.lancer@gmail.com>

On Thu, Jul 26, 2018 at 10:20:05AM -0700, Paul Burton wrote:
> Hi Mike,
> 
> On Thu, Jul 26, 2018 at 10:03:56AM +0300, Mike Rapoport wrote:
> > Any comments on this?
> 
> I haven't looked at this in detail yet, but there was a much larger
> series submitted to accomplish this not too long ago, which needed
> another revision:
> 
>     https://patchwork.linux-mips.org/project/linux-mips/list/?series=787&state=*
> 
> Given that, I'd be (pleasantly) surprised if this one smaller patch is
> enough.

I didn't test it on the real hardware, so I could have missed something.
I've looked at Sergey's patches, largely we are doing the same things. 
 
> Thanks,
>     Paul
> 

-- 
Sincerely yours,
Mike.
