Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id AA3C46B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 03:55:01 -0400 (EDT)
Date: Tue, 24 Jul 2012 15:54:59 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [QUERY]: Understanding the calculations in mm/page-writeback.c
Message-ID: <20120724075459.GB9519@localhost>
References: <CAMYGaxpusZsvVYdruSe4cYr9FWsAs2Eu-7tpoUJoU_GyL1QmXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMYGaxpusZsvVYdruSe4cYr9FWsAs2Eu-7tpoUJoU_GyL1QmXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rajman mekaco <rajman.mekaco@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi Rajman,

On Sun, Jul 22, 2012 at 09:18:57PM +0530, rajman mekaco wrote:
> Hi,
> 
> I am trying to understand the calculations in mm/page-writeback.c but
> I am falling short of theoretical knowledge.
> 
> What online (or otherwise) reading material can be used to fully
> understand the maths formulae in mm/page-writeback.c ?

Here is the slides I used in LinuxCon Japan 2012, please feel free to
ask more specific questions on it :)

http://events.linuxfoundation.org/images/stories/pdf/lcjp2012_wu.pdf

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
