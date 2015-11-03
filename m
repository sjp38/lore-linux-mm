Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3158E6B0038
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 09:12:57 -0500 (EST)
Received: by padhx2 with SMTP id hx2so11901304pad.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 06:12:56 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id yd7si42584713pbc.86.2015.11.03.06.12.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 06:12:56 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so2402781pab.3
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 06:12:56 -0800 (PST)
Subject: Re: [PATCH v6 1/3] percpu: remove PERCPU_ENOUGH_ROOM which is stale definition
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <20151102191044.GA9553@mtj.duckdns.org>
Date: Tue, 3 Nov 2015 23:12:51 +0900
Content-Transfer-Encoding: 7bit
Message-Id: <36E66A14-F5AE-45DA-A759-82F1BA5DFE98@gmail.com>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com> <1446363977-23656-2-git-send-email-jungseoklee85@gmail.com> <20151102191044.GA9553@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, cl@linux.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, james.morse@arm.com, takahiro.akashi@linaro.org, mark.rutland@arm.com, barami97@gmail.com, linux-kernel@vger.kernel.org

On Nov 3, 2015, at 4:10 AM, Tejun Heo wrote:

Dear Tejun,

> On Sun, Nov 01, 2015 at 07:46:15AM +0000, Jungseok Lee wrote:
>> As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
>> used any more. That is, no code refers to the definition.
>> 
>> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
> 
> Applied to percpu/for-4.4.

Thanks for taking care of this!

Best Regards
Jungseok Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
