Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 239016B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 06:32:19 -0500 (EST)
Received: by wibhj13 with SMTP id hj13so402975wib.14
        for <linux-mm@kvack.org>; Thu, 26 Jan 2012 03:32:17 -0800 (PST)
Date: Thu, 26 Jan 2012 12:32:18 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Linaro-mm-sig] [PATCH 1/4] dma-buf: Constify ops argument to
 dma_buf_export()
Message-ID: <20120126113218.GD3896@phenom.ffwll.local>
References: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
 <1327577245-20354-2-git-send-email-laurent.pinchart@ideasonboard.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327577245-20354-2-git-send-email-laurent.pinchart@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

On Thu, Jan 26, 2012 at 12:27:22PM +0100, Laurent Pinchart wrote:
> This allows drivers to make the dma buf operations structure constant.
> 
> Signed-off-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
