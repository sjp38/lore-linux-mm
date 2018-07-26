Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF72C6B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:20:10 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id y26-v6so1678343iob.19
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:20:10 -0700 (PDT)
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700129.outbound.protection.outlook.com. [40.107.70.129])
        by mx.google.com with ESMTPS id u23-v6si1062925iog.184.2018.07.26.10.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Jul 2018 10:20:09 -0700 (PDT)
Date: Thu, 26 Jul 2018 10:20:05 -0700
From: Paul Burton <paul.burton@mips.com>
Subject: Re: [PATCH] mips: switch to NO_BOOTMEM
Message-ID: <20180726172005.pgjmkvwz2lpflpor@pburton-laptop>
References: <1531727262-11520-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726070355.GD8477@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726070355.GD8477@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mips@linux-mips.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Serge Semin <fancer.lancer@gmail.com>

Hi Mike,

On Thu, Jul 26, 2018 at 10:03:56AM +0300, Mike Rapoport wrote:
> Any comments on this?

I haven't looked at this in detail yet, but there was a much larger
series submitted to accomplish this not too long ago, which needed
another revision:

    https://patchwork.linux-mips.org/project/linux-mips/list/?series=787&state=*

Given that, I'd be (pleasantly) surprised if this one smaller patch is
enough.

Thanks,
    Paul
