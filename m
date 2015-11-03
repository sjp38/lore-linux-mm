Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 64F8C6B0038
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 09:11:24 -0500 (EST)
Received: by padhx2 with SMTP id hx2so11870159pad.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 06:11:24 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id yj5si39192455pbc.32.2015.11.03.06.11.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 06:11:23 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so19689370pab.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 06:11:23 -0800 (PST)
Subject: Re: [PATCH v6 2/3] percpu: add PERCPU_ATOM_SIZE for a generic percpu area setup
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org>
Date: Tue, 3 Nov 2015 23:11:16 +0900
Content-Transfer-Encoding: 7bit
Message-Id: <8FA31B91-D361-4F98-A2D3-EFC5D877EDB1@gmail.com>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com> <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com> <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, james.morse@arm.com, takahiro.akashi@linaro.org, mark.rutland@arm.com, barami97@gmail.com, linux-kernel@vger.kernel.org

On Nov 3, 2015, at 1:10 AM, Christoph Lameter wrote:

Dear Christoph,

> On Sun, 1 Nov 2015, Jungseok Lee wrote:
> 
>> There is no room to adjust 'atom_size' now when a generic percpu area
>> is used. It would be redundant to write down an architecture-specific
>> setup_per_cpu_areas() in order to only change the 'atom_size'. Thus,
>> this patch adds a new definition, PERCPU_ATOM_SIZE, which is PAGE_SIZE
>> by default. The value could be updated if needed by architecture.
> 
> What is atom_size? Why would you want a difference allocation size here?
> The percpu area is virtually mapped regardless. So you will have
> contiguous addresses even without atom_size.

I think Catalin have already written down a perfect explanation. I'd like
memory with an alignment greater than PAGE_SIZE. But, __per_cpu_offset[]
is PAGE_SIZE aligned under a generic setup_per_cpu_areas(). That is,
secondary cores cannot get that kind of space.

Thanks for taking a look at this doubtable change!

Best Regards
Jungseok Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
