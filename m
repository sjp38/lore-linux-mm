Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8516B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 10:20:13 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id e190so1593090ybh.8
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 07:20:13 -0700 (PDT)
Received: from mail-yw0-x234.google.com (mail-yw0-x234.google.com. [2607:f8b0:4002:c05::234])
        by mx.google.com with ESMTPS id b203si29703ybc.506.2017.07.19.07.20.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 07:20:12 -0700 (PDT)
Received: by mail-yw0-x234.google.com with SMTP id v193so1016241ywg.2
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 07:20:12 -0700 (PDT)
Date: Wed, 19 Jul 2017 14:20:11 +0000
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 06/10] percpu: modify base_addr to be region specific
Message-ID: <20170719142010.GB23135@li70-116.members.linode.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-7-dennisz@fb.com>
 <20170718192601.GB4009@destiny>
 <20170718193627.GA18303@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170718193627.GA18303@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Dennis Zhou <dennisz@fb.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Tue, Jul 18, 2017 at 12:36:27PM -0700, Matthew Wilcox wrote:
> On Tue, Jul 18, 2017 at 03:26:02PM -0400, Josef Bacik wrote:
> > On Sat, Jul 15, 2017 at 10:23:11PM -0400, Dennis Zhou wrote:
> > > +	map_size_bytes = (ai->reserved_size ?: ai->dyn_size) +
> > > +			 pcpu_reserved_offset;
> > 
> > This confused me for a second, better to be explicit with
> > 
> > (ai->reserved_size ? 0 : ai->dyn_size) + pcpu_reserved_offset;
> 
> You're still confused ;-)  What Dennis wrote is equivalent to:
> 
> (ai->reserved_size ? ai->reserved_size : ai->dyn_size) + pcpu_reserved_offset;

Lol jesus, made my point even harder with me being an idiot.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
