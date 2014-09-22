Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id A91156B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 00:02:48 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id v10so4934507qac.21
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 21:02:48 -0700 (PDT)
Received: from mail-qa0-x22b.google.com (mail-qa0-x22b.google.com [2607:f8b0:400d:c00::22b])
        by mx.google.com with ESMTPS id w8si8023322qas.110.2014.09.21.21.02.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 21 Sep 2014 21:02:47 -0700 (PDT)
Received: by mail-qa0-f43.google.com with SMTP id x12so4881073qac.2
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 21:02:47 -0700 (PDT)
Date: Mon, 22 Sep 2014 00:02:45 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] Revert "percpu: free percpu allocation info for
 uniprocessor system"
Message-ID: <20140922040245.GF23583@htj.dyndns.org>
References: <1411337093-683-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411337093-683-1-git-send-email-linux@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, Honggang Li <enjoymindful@gmail.com>

On Sun, Sep 21, 2014 at 03:04:53PM -0700, Guenter Roeck wrote:
> This reverts commit 3189eddbcafc ("percpu: free percpu allocation info for
> uniprocessor system").
> 
> The commit causes a hang with a crisv32 image. This may be an architecture
> problem, but at least for now the revert is necessary to be able to boot a
> crisv32 image.
> 
> Fixes: 3189eddbcafc ("percpu: free percpu allocation info for uniprocessor system")
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Honggang Li <enjoymindful@gmail.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied to percpu/for-3.18.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
