Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f44.google.com (mail-qe0-f44.google.com [209.85.128.44])
	by kanga.kvack.org (Postfix) with ESMTP id D12A16B005A
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 17:55:19 -0500 (EST)
Received: by mail-qe0-f44.google.com with SMTP id nd7so15046445qeb.31
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:55:19 -0800 (PST)
Received: from mail-qe0-x235.google.com (mail-qe0-x235.google.com [2607:f8b0:400d:c02::235])
        by mx.google.com with ESMTPS id q6si37780317qag.40.2013.12.03.14.55.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 14:55:19 -0800 (PST)
Received: by mail-qe0-f53.google.com with SMTP id nc12so13778330qeb.26
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:55:18 -0800 (PST)
Date: Tue, 3 Dec 2013 17:55:13 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 06/23] mm/char: remove unnecessary inclusion of
 bootmem.h
Message-ID: <20131203225513.GV8277@htj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-7-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386037658-3161-7-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, Dec 02, 2013 at 09:27:21PM -0500, Santosh Shilimkar wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> 
> Clean-up to remove depedency with bootmem headers.
> 
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>

Please merge 4-6 into a single patch.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
