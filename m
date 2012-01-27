Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 51DAD6B00A6
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 00:19:46 -0500 (EST)
Received: by qcsg1 with SMTP id g1so860977qcs.14
        for <linux-mm@kvack.org>; Thu, 26 Jan 2012 21:19:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
References: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
From: Sumit Semwal <sumit.semwal@linaro.org>
Date: Fri, 27 Jan 2012 10:49:24 +0530
Message-ID: <CAO_48GH36S1spUw-4B=Ti-EGugy5thP=fJ3d96iTwLep+mM_1A@mail.gmail.com>
Subject: Re: [PATCH 0/4] Miscellaneous dma-buf patches
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

On 26 January 2012 16:57, Laurent Pinchart
<laurent.pinchart@ideasonboard.com> wrote:
> Hi Sumit,
Hi Laurent,
>
> Here are 4 dma-buf patches that fix small issues.
Thanks; merged to 'dev' branch on
git://git.linaro.org/people/sumitsemwal/linux-3.x.git.
>
> Laurent Pinchart (4):
> =A0dma-buf: Constify ops argument to dma_buf_export()
> =A0dma-buf: Remove unneeded sanity checks
> =A0dma-buf: Return error instead of using a goto statement when possible
> =A0dma-buf: Move code out of mutex-protected section in dma_buf_attach()
>
> =A0drivers/base/dma-buf.c =A0| =A0 26 +++++++++++---------------
> =A0include/linux/dma-buf.h | =A0 =A08 ++++----
> =A02 files changed, 15 insertions(+), 19 deletions(-)
>
> --
> Regards,
>
> Laurent Pinchart
Best regards,
~Sumit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
