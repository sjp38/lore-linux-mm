Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA5BF6B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 10:53:45 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 19so73798926qty.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 07:53:45 -0700 (PDT)
Received: from mail-qt0-x235.google.com (mail-qt0-x235.google.com. [2607:f8b0:400d:c0d::235])
        by mx.google.com with ESMTPS id i127si14925917qkc.370.2017.07.17.07.53.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 07:53:45 -0700 (PDT)
Received: by mail-qt0-x235.google.com with SMTP id 21so32779385qtx.3
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 07:53:44 -0700 (PDT)
Date: Mon, 17 Jul 2017 10:53:41 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 04/10] percpu: update the header comment and
 pcpu_build_alloc_info comments
Message-ID: <20170717145341.GH3519177@devbig577.frc2.facebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-5-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716022315.19892-5-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Sat, Jul 15, 2017 at 10:23:09PM -0400, Dennis Zhou wrote:
>   *  c0                           c1                         c2
>   *  -------------------          -------------------        ------------
>   * | u0 | u1 | u2 | u3 |        | u0 | u1 | u2 | u3 |      | u0 | u1 | u
>   *  -------------------  ......  -------------------  ....  ------------
> +

Missing '*'.  Added and applied to percpu/for-4.14.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
