Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4356B006C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 09:13:29 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id dc16so6709731qab.1
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:13:29 -0800 (PST)
Received: from mail-qa0-x233.google.com (mail-qa0-x233.google.com. [2607:f8b0:400d:c00::233])
        by mx.google.com with ESMTPS id n4si31096361qci.46.2015.01.14.06.13.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 06:13:28 -0800 (PST)
Received: by mail-qa0-f51.google.com with SMTP id f12so5848478qad.10
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:13:28 -0800 (PST)
Date: Wed, 14 Jan 2015 09:13:25 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/5] kernfs: convert node name allocation to kstrdup_const
Message-ID: <20150114141325.GD3565@htj.dyndns.org>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
 <1421054323-14430-3-git-send-email-a.hajda@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421054323-14430-3-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 12, 2015 at 10:18:40AM +0100, Andrzej Hajda wrote:
> sysfs frequently performs duplication of strings located
> in read-only memory section. Replacing kstrdup by kstrdup_const
> allows to avoid such operations.
> 
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
