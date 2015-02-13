Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A24C36B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 21:46:41 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so15691159pab.3
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 18:46:41 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id wr6si1056150pbc.82.2015.02.12.18.46.39
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 18:46:40 -0800 (PST)
Date: Fri, 13 Feb 2015 11:48:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 1/3] mm: cma: debugfs interface
Message-ID: <20150213024856.GD6592@js1304-P5Q-DELUXE>
References: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
 <1423780008-16727-2-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1423780008-16727-2-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, akpm@linux-foundation.org, lauraa@codeaurora.org, s.strogin@partner.samsung.com

On Thu, Feb 12, 2015 at 05:26:46PM -0500, Sasha Levin wrote:
> Implement a simple debugfs interface to expose information about CMA areas
> in the system.
> 
> Useful for testing/sanity checks for CMA since it was impossible to previously
> retrieve this information in userspace.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
