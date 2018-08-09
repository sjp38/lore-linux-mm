Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CBD06B000A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 08:34:54 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i26-v6so2066231edr.4
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 05:34:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u42-v6si1759770edm.404.2018.08.09.05.34.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 05:34:53 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w79CTfAC091421
	for <linux-mm@kvack.org>; Thu, 9 Aug 2018 08:34:51 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2krmqujn57-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Aug 2018 08:34:51 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 9 Aug 2018 13:34:49 +0100
Date: Thu, 9 Aug 2018 15:34:42 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mips: switch to NO_BOOTMEM
References: <1531727262-11520-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726070355.GD8477@rapoport-lnx>
 <20180726172005.pgjmkvwz2lpflpor@pburton-laptop>
 <CAMPMW8p092oXk1w+SVjgx-ZH+46piAY8xgYPDfLUwLCkBm-TVw@mail.gmail.com>
 <20180802115550.GA10232@rapoport-lnx>
 <CAMPMW8qq-aEm-0dQrWh08SBBSRp3xAqR1PL5Oe-RvkJgUk6LjA@mail.gmail.com>
 <20180808214215.bf6hyurv3nunfynd@pburton-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180808214215.bf6hyurv3nunfynd@pburton-laptop>
Message-Id: <20180809123441.GA3264@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Burton <paul.burton@mips.com>
Cc: Fancer's opinion <fancer.lancer@gmail.com>, Linux-MIPS <linux-mips@linux-mips.org>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Aug 08, 2018 at 02:42:15PM -0700, Paul Burton wrote:
> Hi Sergey & Mike,
> 
> On Thu, Aug 09, 2018 at 12:30:03AM +0300, Fancer's opinion wrote:
> > Hello Mike,
> > I haven't read your patch text yet. I am waiting for the subsystem
> > maintainers response at least
> > about the necessity to have this type of changes being merged into the
> > sources (I mean
> > memblock/no-bootmem alteration). If they find it pointless (although I
> > would strongly disagree), then
> > nothing to discuss. Otherwise we can come up with a solution.
> > 
> > -Sergey
> 
> I'm all for dropping bootmem.
> 
> It's too late for something this invasive in 4.19, but I'd love to get
> it into 4.20.

I can resend my patch once merge window is closed. We can then apply
additional changes Sergey has done in his set on top.

> Thanks,
>     Paul
> 

-- 
Sincerely yours,
Mike.
