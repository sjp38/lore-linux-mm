Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id E62526B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 07:20:28 -0400 (EDT)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH 0/4] Miscellaneous dma-buf patches
Date: Wed, 21 Mar 2012 12:20:56 +0100
Message-ID: <1425373.iStdZJ1xiW@avalon>
In-Reply-To: <CAO_48GH36S1spUw-4B=Ti-EGugy5thP=fJ3d96iTwLep+mM_1A@mail.gmail.com>
References: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com> <CAO_48GH36S1spUw-4B=Ti-EGugy5thP=fJ3d96iTwLep+mM_1A@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

Hi Sumit,

On Friday 27 January 2012 10:49:24 Sumit Semwal wrote:
> On 26 January 2012 16:57, Laurent Pinchart wrote:
> > Hi Sumit,
> 
> Hi Laurent,
> 
> > Here are 4 dma-buf patches that fix small issues.
> 
> Thanks; merged to 'dev' branch on
> git://git.linaro.org/people/sumitsemwal/linux-3.x.git.

Thank you. It would be even nicer if you could push them to mainline at some 
point :-)

> > Laurent Pinchart (4):
> >  dma-buf: Constify ops argument to dma_buf_export()
> >  dma-buf: Remove unneeded sanity checks
> >  dma-buf: Return error instead of using a goto statement when possible
> >  dma-buf: Move code out of mutex-protected section in dma_buf_attach()
> > 
> >  drivers/base/dma-buf.c  |   26 +++++++++++---------------
> >  include/linux/dma-buf.h |    8 ++++----
> >  2 files changed, 15 insertions(+), 19 deletions(-)

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
