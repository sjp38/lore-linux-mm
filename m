Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7DC6B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:05:03 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k190so160991795pgk.8
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 13:05:03 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t8si7294671pgc.259.2017.07.24.13.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 13:05:02 -0700 (PDT)
Date: Mon, 24 Jul 2017 16:04:47 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: Re: [PATCH 05/10] percpu: change reserved_size to end page aligned
Message-ID: <20170724200446.GA91613@dennisz-mbp.dhcp.thefacebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-6-dennisz@fb.com>
 <20170717164650.GJ3519177@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170717164650.GJ3519177@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

Hi Tejun,

On Mon, Jul 17, 2017 at 12:46:50PM -0400, Tejun Heo wrote:
 
> Heh, that was pretty difficult to parse, but here's my question.  So,
> we're expanding reserved area so that its end aligns to page boundary
> which is completely fine.  We may end up with reserved area which is a
> bit larger than specified but no big deal.  However, we can't do the
> same thing with the boundary between the static and reserved chunks,
> so instead we pull down the start of the reserved area and mark off
> the overwrapping area, which is fine too.
> 
> My question is why we're doing one thing for the end of reserved area
> while we need to do a different thing for the beginning of it.  Can't
> we do the same thing in both cases?  ie. for the both boundaries
> between static and reserved, and reserved and dynamic, pull down the
> start to the page boundary and mark the overlapping areas used?

I've refactored the code to maintain start and end offsets. This removes
the need to expand the reserved region. There are a few more constraints
though. The reserved region must be a multiple of the minimum allocation
size. The static region and dynamic region are expanded and shrunk
respectively to maintain alignment with the minimum allocation size.

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
