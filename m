Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC2E56B0292
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 15:36:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e199so29014763pfh.7
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 12:36:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r187si2316932pgr.443.2017.07.18.12.36.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 12:36:30 -0700 (PDT)
Date: Tue, 18 Jul 2017 12:36:27 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 06/10] percpu: modify base_addr to be region specific
Message-ID: <20170718193627.GA18303@bombadil.infradead.org>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-7-dennisz@fb.com>
 <20170718192601.GB4009@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170718192601.GB4009@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Dennis Zhou <dennisz@fb.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Tue, Jul 18, 2017 at 03:26:02PM -0400, Josef Bacik wrote:
> On Sat, Jul 15, 2017 at 10:23:11PM -0400, Dennis Zhou wrote:
> > +	map_size_bytes = (ai->reserved_size ?: ai->dyn_size) +
> > +			 pcpu_reserved_offset;
> 
> This confused me for a second, better to be explicit with
> 
> (ai->reserved_size ? 0 : ai->dyn_size) + pcpu_reserved_offset;

You're still confused ;-)  What Dennis wrote is equivalent to:

(ai->reserved_size ? ai->reserved_size : ai->dyn_size) + pcpu_reserved_offset;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
