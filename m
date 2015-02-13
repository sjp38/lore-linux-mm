Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 151816B0070
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 21:48:51 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so15701954pab.3
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 18:48:50 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id r4si1079802pdn.10.2015.02.12.18.48.48
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 18:48:50 -0800 (PST)
Date: Fri, 13 Feb 2015 11:50:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 3/3] mm: cma: release trigger
Message-ID: <20150213025044.GF6592@js1304-P5Q-DELUXE>
References: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
 <1423780008-16727-4-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1423780008-16727-4-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, akpm@linux-foundation.org, lauraa@codeaurora.org, s.strogin@partner.samsung.com

On Thu, Feb 12, 2015 at 05:26:48PM -0500, Sasha Levin wrote:
> Provides a userspace interface to trigger a CMA release.
> 
> Usage:
> 
> 	echo [pages] > free
> 
> This would provide testing/fuzzing access to the CMA release paths.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
