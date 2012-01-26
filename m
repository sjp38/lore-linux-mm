Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 853896B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 07:12:12 -0500 (EST)
Message-Id: <e0d58a$3259e0@orsmga002.jf.intel.com>
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [Linaro-mm-sig] [PATCH 4/4] dma-buf: Move code out of mutex-protected section in dma_buf_attach()
In-Reply-To: <1327577245-20354-5-git-send-email-laurent.pinchart@ideasonboard.com>
References: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com> <1327577245-20354-5-git-send-email-laurent.pinchart@ideasonboard.com>
Date: Thu, 26 Jan 2012 12:11:57 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Sumit Semwal <sumit.semwal@ti.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

On Thu, 26 Jan 2012 12:27:25 +0100, Laurent Pinchart <laurent.pinchart@ideasonboard.com> wrote:
> Some fields can be set without mutex protection. Initialize them before
> locking the mutex.

struct mutex lock is described as

 /* mutex to serialize list manipulation and other ops */

maybe now is a good time to be a little more descriptive in what that
mutex is meant to protect and sprinkle enforcement throughout the code
as a means of documentation.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
