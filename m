Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C874B6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 11:11:06 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id i143so3030037qke.14
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 08:11:06 -0700 (PDT)
Received: from mail-qt0-x230.google.com (mail-qt0-x230.google.com. [2607:f8b0:400d:c0d::230])
        by mx.google.com with ESMTPS id z15si8057488qta.23.2017.08.07.08.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 08:11:06 -0700 (PDT)
Received: by mail-qt0-x230.google.com with SMTP id v29so4257118qtv.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 08:11:06 -0700 (PDT)
Date: Mon, 7 Aug 2017 08:11:02 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/vmalloc: reduce half comparison during
 pcpu_get_vm_areas()
Message-ID: <20170807151102.GE4050379@devbig577.frc2.facebook.com>
References: <20170803063822.48702-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170803063822.48702-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 03, 2017 at 02:38:22PM +0800, Wei Yang wrote:
> In pcpu_get_vm_areas(), it checks each range is not overlapped. To make
> sure it is, only (N^2)/2 comparison is necessary, while current code does
> N^2 times. By starting from the next range, it achieves the goal and the
> continue could be removed.
> 
> At the mean time, other two work in this patch:
> *  the overlap check of two ranges could be done with one clause
> *  one typo in comment is fixed.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
