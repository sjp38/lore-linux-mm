Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id EA1DD6B00C4
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:56:35 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so1861485yhn.4
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 07:56:35 -0800 (PST)
Received: from mail-yh0-x22d.google.com (mail-yh0-x22d.google.com [2607:f8b0:4002:c01::22d])
        by mx.google.com with ESMTPS id w8si21201032yhd.83.2013.11.25.07.56.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 07:56:35 -0800 (PST)
Received: by mail-yh0-f45.google.com with SMTP id v1so1920433yhn.32
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 07:56:34 -0800 (PST)
Date: Mon, 25 Nov 2013 10:56:29 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
Message-ID: <20131125155629.GA24344@htj.dyndns.org>
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com>
 <529217C7.6030304@cogentembedded.com>
 <52935762.1080409@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <52935762.1080409@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Mon, Nov 25, 2013 at 08:57:54AM -0500, Santosh Shilimkar wrote:
> On Sunday 24 November 2013 10:14 AM, Sergei Shtylyov wrote:
> > Hello.
> > 
> > On 24-11-2013 3:28, Santosh Shilimkar wrote:
> > 
> >> Building ARM with NO_BOOTMEM generates below warning. Using min_t
> > 
> >    Where is that below? :-)
> > 
> Damn.. Posted a wrong version of the patch ;-(
> Here is the one with warning message included.
> 
> From 571dfdf4cf8ac7dfd50bd9b7519717c42824f1c3 Mon Sep 17 00:00:00 2001
> From: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Date: Sat, 23 Nov 2013 18:16:50 -0500
> Subject: [PATCH] mm: nobootmem: avoid type warning about alignment value
> 
> Building ARM with NO_BOOTMEM generates below warning.
> 
> mm/nobootmem.c: In function a??__free_pages_memorya??:
> mm/nobootmem.c:88:11: warning: comparison of distinct pointer types lacks a cast
> 
> Using min_t to find the correct alignment avoids the warning.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
