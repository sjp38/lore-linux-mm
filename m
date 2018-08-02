Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF6DA6B026B
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:56:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w185-v6so1652743oig.19
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:56:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u8-v6si1170107oib.9.2018.08.02.04.56.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 04:56:10 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w72Bs5XX030376
	for <linux-mm@kvack.org>; Thu, 2 Aug 2018 07:56:09 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2km0kp2f0m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Aug 2018 07:56:09 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 2 Aug 2018 12:56:06 +0100
Date: Thu, 2 Aug 2018 14:55:51 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mips: switch to NO_BOOTMEM
References: <1531727262-11520-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726070355.GD8477@rapoport-lnx>
 <20180726172005.pgjmkvwz2lpflpor@pburton-laptop>
 <CAMPMW8p092oXk1w+SVjgx-ZH+46piAY8xgYPDfLUwLCkBm-TVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMPMW8p092oXk1w+SVjgx-ZH+46piAY8xgYPDfLUwLCkBm-TVw@mail.gmail.com>
Message-Id: <20180802115550.GA10232@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fancer's opinion <fancer.lancer@gmail.com>, Paul Burton <Paul.Burton@mips.com>
Cc: Linux-MIPS <linux-mips@linux-mips.org>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Thu, Jul 26, 2018 at 10:55:53PM +0300, Fancer's opinion wrote:
> Hello, folks
> Regarding the no_bootmem patchset I've sent earlier.
> I'm terribly sorry about huge delay with response. I got sucked in a new
> project, so just didn't have a time to proceed with the series, answer to the
> questions and resend the set.
> If it is still relevant and needed for community, I can get back to the series
> on the next week, answer to the Mett's questions (sorry, man, for doing it so
> long), rebase it on top of the kernel 4.18 and resend the new version. We also
> can try to combine it with this patch, if it is found convenient.

So, what would be the best way to move forward?

> Regards,
> -Sergey
> 
> 
> On Thu, 26 Jul 2018, 20:20 Paul Burton, <paul.burton@mips.com> wrote:
> 
>     Hi Mike,
> 
>     On Thu, Jul 26, 2018 at 10:03:56AM +0300, Mike Rapoport wrote:
>     > Any comments on this?
> 
>     I haven't looked at this in detail yet, but there was a much larger
>     series submitted to accomplish this not too long ago, which needed
>     another revision:
> 
>         https://patchwork.linux-mips.org/project/linux-mips/list/?series=787&
>     state=*
> 
>     Given that, I'd be (pleasantly) surprised if this one smaller patch is
>     enough.
> 
>     Thanks,
>         Paul
> 

-- 
Sincerely yours,
Mike.
