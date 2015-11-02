Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 44EEA6B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 14:10:48 -0500 (EST)
Received: by ykek133 with SMTP id k133so150254295yke.2
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 11:10:48 -0800 (PST)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com. [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id a129si10140373ywf.426.2015.11.02.11.10.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 11:10:47 -0800 (PST)
Received: by ykba4 with SMTP id a4so149160682ykb.3
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 11:10:47 -0800 (PST)
Date: Mon, 2 Nov 2015 14:10:44 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v6 1/3] percpu: remove PERCPU_ENOUGH_ROOM which is stale
 definition
Message-ID: <20151102191044.GA9553@mtj.duckdns.org>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com>
 <1446363977-23656-2-git-send-email-jungseoklee85@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446363977-23656-2-git-send-email-jungseoklee85@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, cl@linux.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, james.morse@arm.com, takahiro.akashi@linaro.org, mark.rutland@arm.com, barami97@gmail.com, linux-kernel@vger.kernel.org

On Sun, Nov 01, 2015 at 07:46:15AM +0000, Jungseok Lee wrote:
> As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
> used any more. That is, no code refers to the definition.
> 
> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>

Applied to percpu/for-4.4.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
