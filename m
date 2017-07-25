Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD29D6B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:27:26 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g13so11275266qta.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:27:26 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id x78si8006365qkb.243.2017.07.25.11.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:27:26 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id u19so2448469qtc.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:27:26 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:27:24 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 10/23] percpu: change the number of pages marked in
 the first_chunk pop bitmap
Message-ID: <20170725182723.GJ18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-11-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-11-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:07PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The populated bitmap represents the state of the pages the chunk serves.
> Prior, the bitmap was marked completely used as the first chunk was
> allocated and immutable. This is misleading because the first chunk may
> not be completely filled. Additionally, with moving the base_addr up in
> the previous patch, the population check no longer corresponds to what
> was being checked.
> 
> This patch modifies the population map to be only the number of pages
> the region serves and to make what it was checking correspond correctly
> again. The change is to remove any misunderstanding between the size of
> the populated bitmap and the actual size of it. The work function page
> iterators now use nr_pages for the check rather than pcpu_unit_pages
> because nr_populated is now chunk specific. Without this, the work
> function would try to populate the remainder of these chunks despite it
> not serving any more than nr_pages when nr_pages is set less than
> pcpu_unit_pages.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
