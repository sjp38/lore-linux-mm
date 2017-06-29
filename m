Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id E06046B0313
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:24:16 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id g31so70857325ybe.11
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 08:24:16 -0700 (PDT)
Received: from mail-yb0-x235.google.com (mail-yb0-x235.google.com. [2607:f8b0:4002:c09::235])
        by mx.google.com with ESMTPS id a66si1469566ybi.188.2017.06.29.08.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 08:24:15 -0700 (PDT)
Received: by mail-yb0-x235.google.com with SMTP id 84so29916209ybe.0
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 08:24:15 -0700 (PDT)
Date: Thu, 29 Jun 2017 11:24:13 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] percpu: fix static checker warnings in
 pcpu_destroy_chunk
Message-ID: <20170629152413.GA9745@htj.duckdns.org>
References: <20170629110954.uz6he7x25bg4n3pp@mwanda>
 <20170629145625.GA79969@dennisz-mbp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170629145625.GA79969@dennisz-mbp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, linux-mm@kvack.org

On Thu, Jun 29, 2017 at 10:56:26AM -0400, Dennis Zhou wrote:
> From 5021b97f4026334d2c8dfad80797dd1028cddd73 Mon Sep 17 00:00:00 2001
> From: Dennis Zhou <dennisz@fb.com>
> Date: Thu, 29 Jun 2017 07:11:41 -0700
> 
> Add NULL check in pcpu_destroy_chunk to correct static checker warnings.
> 
> Signed-off-by: Dennis Zhou <dennisz@fb.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to percpu/for-4.13.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
