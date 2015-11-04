Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB716B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 08:19:32 -0500 (EST)
Received: by iodd200 with SMTP id d200so52902129iod.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 05:19:32 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id rt3si19450160igb.71.2015.11.04.05.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 05:19:31 -0800 (PST)
Received: by pacrf6 with SMTP id rf6so6499044pac.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 05:19:31 -0800 (PST)
Subject: Re: [PATCH v6 1/3] percpu: remove PERCPU_ENOUGH_ROOM which is stale definition
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <20151103220701.GC5749@mtj.duckdns.org>
Date: Wed, 4 Nov 2015 22:19:24 +0900
Content-Transfer-Encoding: 7bit
Message-Id: <D6207CF9-DFA6-4485-8E09-AEDEC9491EB9@gmail.com>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com> <1446363977-23656-2-git-send-email-jungseoklee85@gmail.com> <20151102191044.GA9553@mtj.duckdns.org> <36E66A14-F5AE-45DA-A759-82F1BA5DFE98@gmail.com> <20151103220701.GC5749@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, cl@linux.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, james.morse@arm.com, takahiro.akashi@linaro.org, mark.rutland@arm.com, barami97@gmail.com, linux-kernel@vger.kernel.org

On Nov 4, 2015, at 7:07 AM, Tejun Heo wrote:
> Hello,

Hello,

> On Tue, Nov 03, 2015 at 11:12:51PM +0900, Jungseok Lee wrote:
>> On Nov 3, 2015, at 4:10 AM, Tejun Heo wrote:
>> 
>> Dear Tejun,
>> 
>>> On Sun, Nov 01, 2015 at 07:46:15AM +0000, Jungseok Lee wrote:
>>>> As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
>>>> used any more. That is, no code refers to the definition.
>>>> 
>>>> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
>>> 
>>> Applied to percpu/for-4.4.
>> 
>> Thanks for taking care of this!
> 
> Can you please refresh the patch so that it also drops
> PERCPU_ENOUGH_ROOM definition from ia64?

Sure! I will do re-spin soon. 

Best Regards
Jungseok Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
