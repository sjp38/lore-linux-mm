Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA5782F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 17:07:06 -0500 (EST)
Received: by ykba4 with SMTP id a4so40762032ykb.3
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 14:07:06 -0800 (PST)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id b187si12500968ywd.424.2015.11.03.14.07.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 14:07:05 -0800 (PST)
Received: by ykft191 with SMTP id t191so40915362ykf.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 14:07:05 -0800 (PST)
Date: Tue, 3 Nov 2015 17:07:01 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v6 1/3] percpu: remove PERCPU_ENOUGH_ROOM which is stale
 definition
Message-ID: <20151103220701.GC5749@mtj.duckdns.org>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com>
 <1446363977-23656-2-git-send-email-jungseoklee85@gmail.com>
 <20151102191044.GA9553@mtj.duckdns.org>
 <36E66A14-F5AE-45DA-A759-82F1BA5DFE98@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <36E66A14-F5AE-45DA-A759-82F1BA5DFE98@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, cl@linux.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, james.morse@arm.com, takahiro.akashi@linaro.org, mark.rutland@arm.com, barami97@gmail.com, linux-kernel@vger.kernel.org

Hello,

On Tue, Nov 03, 2015 at 11:12:51PM +0900, Jungseok Lee wrote:
> On Nov 3, 2015, at 4:10 AM, Tejun Heo wrote:
> 
> Dear Tejun,
> 
> > On Sun, Nov 01, 2015 at 07:46:15AM +0000, Jungseok Lee wrote:
> >> As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
> >> used any more. That is, no code refers to the definition.
> >> 
> >> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
> > 
> > Applied to percpu/for-4.4.
> 
> Thanks for taking care of this!

Can you please refresh the patch so that it also drops
PERCPU_ENOUGH_ROOM definition from ia64?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
