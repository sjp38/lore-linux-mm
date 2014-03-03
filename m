Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id ECB426B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 03:01:24 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id q59so2755534wes.9
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 00:01:24 -0800 (PST)
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
        by mx.google.com with ESMTPS id yz4si8498072wjc.85.2014.03.03.00.01.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 00:01:23 -0800 (PST)
Received: by mail-we0-f172.google.com with SMTP id t61so252972wes.17
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 00:01:22 -0800 (PST)
Date: Mon, 3 Mar 2014 08:01:14 +0000
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH 1/5] mm: hugetlb: Introduce huge_pte_{page,present,young}
Message-ID: <20140303080113.GA14340@linaro.org>
References: <1392737235-27286-1-git-send-email-steve.capper@linaro.org>
 <1392737235-27286-2-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392737235-27286-2-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk, linux-mm@kvack.org
Cc: will.deacon@arm.com, catalin.marinas@arm.com, arnd@arndb.de, dsaxena@linaro.org, robherring2@gmail.com

On Tue, Feb 18, 2014 at 03:27:11PM +0000, Steve Capper wrote:
> Introduce huge pte versions of pte_page, pte_present and pte_young.
> This allows ARM (without LPAE) to use alternative pte processing logic
> for huge ptes.
> 
> Where these functions are not defined by architectural code they
> fallback to the standard functions.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>

Hi,
I was wondering if this patch looks reasonable to people?

Thanks,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
