Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 861A76B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:28:46 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hm5so95972326pac.4
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:28:46 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id i66si5827218pfg.98.2016.10.13.17.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 17:28:45 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id qn10so5365600pac.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:28:45 -0700 (PDT)
Date: Thu, 13 Oct 2016 20:28:43 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
Message-ID: <20161014002843.GH32534@mtj.duckdns.org>
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
 <20161013233139.GE32534@mtj.duckdns.org>
 <b1b3d53c-b6d9-f888-e123-1b6afe9b2e98@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1b3d53c-b6d9-f888-e123-1b6afe9b2e98@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, cl@linux.com

Hello,

On Fri, Oct 14, 2016 at 08:23:06AM +0800, zijun_hu wrote:
> for the current code, only power of 2 alignment value can works well
> 
> is it acceptable to performing a power of 2 checking and returning error code
> if fail?

Yeah, just add is_power_of_2() test to the existing sanity check.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
