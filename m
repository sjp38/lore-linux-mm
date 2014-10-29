Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 95B39900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 10:35:27 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id dc16so2183849qab.32
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 07:35:27 -0700 (PDT)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com. [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id u3si7786301qag.0.2014.10.29.07.35.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 07:35:26 -0700 (PDT)
Received: by mail-qc0-f170.google.com with SMTP id l6so2500451qcy.29
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 07:35:26 -0700 (PDT)
Date: Wed, 29 Oct 2014 10:35:23 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch] percpu: off by one in BUG_ON()
Message-ID: <20141029143523.GB25226@htj.dyndns.org>
References: <20141029084504.GD8939@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141029084504.GD8939@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Wed, Oct 29, 2014 at 11:45:04AM +0300, Dan Carpenter wrote:
> The unit_map[] array has "nr_cpu_ids" number of elements.  It's
> allocated a few lines earlier in the function.  So this test should be
> >= instead of >.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to percpu/for-3.19.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
