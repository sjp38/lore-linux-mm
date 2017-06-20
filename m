Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7942B6B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:32:13 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id y192so105650563ywd.9
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:32:13 -0700 (PDT)
Received: from mail-yw0-x235.google.com (mail-yw0-x235.google.com. [2607:f8b0:4002:c05::235])
        by mx.google.com with ESMTPS id c11si3820099ybm.159.2017.06.20.12.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 12:32:12 -0700 (PDT)
Received: by mail-yw0-x235.google.com with SMTP id v7so56403283ywc.2
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:32:12 -0700 (PDT)
Date: Tue, 20 Jun 2017 15:32:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/4] percpu: add basic stats and tracepoints to percpu
 allocator
Message-ID: <20170620193209.GE21326@htj.duckdns.org>
References: <20170619232832.27116-1-dennisz@fb.com>
 <20170620174521.GD21326@htj.duckdns.org>
 <F1DDF17A-B2CE-4EAF-8B6B-1AC4C73451DC@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F1DDF17A-B2CE-4EAF-8B6B-1AC4C73451DC@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>

On Tue, Jun 20, 2017 at 07:12:49PM +0000, Dennis Zhou wrote:
> On 6/20/17, 1:45 PM, "Tejun Heo" <htejun@gmail.com on behalf of tj@kernel.org> wrote:
> > Applied to percpu/for-4.13.  I had to update 0002 because of the
> > recent __ro_after_init changes.  Can you please see whether I made any
> > mistakes while updating it?
> 
> There is a tagging mismatch in 0002. Can you please change or remove the __read_mostly annotation in mm/percpu-internal.h?

Fixed.  Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
