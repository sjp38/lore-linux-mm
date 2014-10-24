Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7358D6B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 05:54:11 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so2273217lbg.32
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 02:54:10 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [185.26.127.97])
        by mx.google.com with ESMTPS id mi5si6176799lbc.61.2014.10.24.02.54.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 02:54:09 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH 1/4] mm: cma: Don't crash on allocation if CMA area can't be activated
Date: Fri, 24 Oct 2014 12:54:08 +0300
Message-ID: <1796959.xTvOMRAxHJ@avalon>
In-Reply-To: <20141024025014.GA15243@js1304-P5Q-DELUXE>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <CAL1ERfPiv6KG5Lim6F0w72z=j47D1KCWhukLc5T6jJPOHTP_mQ@mail.gmail.com> <20141024025014.GA15243@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Weijie Yang <weijie.yang.kh@gmail.com>, Michal Nazarewicz <mina86@mina86.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>

Hello,

On Friday 24 October 2014 11:50:14 Joonsoo Kim wrote:
> On Fri, Oct 24, 2014 at 10:02:49AM +0800, Weijie Yang wrote:
> > On Fri, Oct 24, 2014 at 7:42 AM, Laurent Pinchart wrote:
> > > On Thursday 23 October 2014 18:53:36 Michal Nazarewicz wrote:
> > >> On Thu, Oct 23 2014, Laurent Pinchart wrote:
> > >> > If activation of the CMA area fails its mutex won't be initialized,
> > >> > leading to an oops at allocation time when trying to lock the mutex.
> > >> > Fix this by failing allocation if the area hasn't been successfully
> > >> > actived, and detect that condition by moving the CMA bitmap
> > >> > allocation after page block reservation completion.
> > >> > 
> > >> > Signed-off-by: Laurent Pinchart
> > >> > <laurent.pinchart+renesas@ideasonboard.com>
> > >> 
> > >> Cc: <stable@vger.kernel.org>  # v3.17
> > >> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> > 
> > This patch is good, but how about add a active field in cma struct?
> > use cma->active to check whether cma is actived successfully.
> > I think it will make code more clear and readable.
> > Just my little opinion.
> 
> Or just setting cma->count to 0 would work fine.

I would prefer setting cma->count to 0 to avoid the extra field. I'll modify 
the patch accordingly.

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
