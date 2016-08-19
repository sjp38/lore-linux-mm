Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A11F26B0253
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:26:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so40699874pfg.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:26:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id zt6si7640323pab.198.2016.08.19.03.26.30
        for <linux-mm@kvack.org>;
        Fri, 19 Aug 2016 03:26:31 -0700 (PDT)
Message-ID: <1471602388.3866.0.camel@linux.intel.com>
Subject: Re: [PATCH 1/2] io-mapping: Always create a struct to hold metadata
 about the io-mapping
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Fri, 19 Aug 2016 13:26:28 +0300
In-Reply-To: <1471261984-15756-1-git-send-email-chris@chris-wilson.co.uk>
References: <1471261984-15756-1-git-send-email-chris@chris-wilson.co.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org
Cc: linux-mm@kvack.org

On ma, 2016-08-15 at 12:53 +0100, Chris Wilson wrote:
> Currently, we only allocate a structure to hold metadata if we need to
> allocate an ioremap for every access, such as on x86-32. However, it
> would be useful to store basic information about the io-mapping, such as
> its page protection, on all platforms.
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>

Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

Regards, Joonas
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
