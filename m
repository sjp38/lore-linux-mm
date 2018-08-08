Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9339D6B0005
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 17:42:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f10-v6so2429847wmb.9
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 14:42:24 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0098.outbound.protection.outlook.com. [104.47.32.98])
        by mx.google.com with ESMTPS id n11-v6si3880629wro.28.2018.08.08.14.42.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Aug 2018 14:42:22 -0700 (PDT)
Date: Wed, 8 Aug 2018 14:42:15 -0700
From: Paul Burton <paul.burton@mips.com>
Subject: Re: [PATCH] mips: switch to NO_BOOTMEM
Message-ID: <20180808214215.bf6hyurv3nunfynd@pburton-laptop>
References: <1531727262-11520-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726070355.GD8477@rapoport-lnx>
 <20180726172005.pgjmkvwz2lpflpor@pburton-laptop>
 <CAMPMW8p092oXk1w+SVjgx-ZH+46piAY8xgYPDfLUwLCkBm-TVw@mail.gmail.com>
 <20180802115550.GA10232@rapoport-lnx>
 <CAMPMW8qq-aEm-0dQrWh08SBBSRp3xAqR1PL5Oe-RvkJgUk6LjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMPMW8qq-aEm-0dQrWh08SBBSRp3xAqR1PL5Oe-RvkJgUk6LjA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fancer's opinion <fancer.lancer@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Linux-MIPS <linux-mips@linux-mips.org>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

Hi Sergey & Mike,

On Thu, Aug 09, 2018 at 12:30:03AM +0300, Fancer's opinion wrote:
> Hello Mike,
> I haven't read your patch text yet. I am waiting for the subsystem
> maintainers response at least
> about the necessity to have this type of changes being merged into the
> sources (I mean
> memblock/no-bootmem alteration). If they find it pointless (although I
> would strongly disagree), then
> nothing to discuss. Otherwise we can come up with a solution.
> 
> -Sergey

I'm all for dropping bootmem.

It's too late for something this invasive in 4.19, but I'd love to get
it into 4.20.

Thanks,
    Paul
