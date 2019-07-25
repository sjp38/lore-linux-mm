Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 216F9C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:14:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0E8120840
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:14:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0E8120840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3725C8E0043; Thu, 25 Jul 2019 03:14:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3233F8E0031; Thu, 25 Jul 2019 03:14:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 212668E0043; Thu, 25 Jul 2019 03:14:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE6FD8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:14:18 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so25700031pll.22
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 00:14:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=pl4VFNjumg1HwDu/CJY+b146qJd52pJu/R/JaNNnLPY=;
        b=Tn/xWAidcBOiYke90TWXR+5CWc37WTdh2NBQjQBpa75g20nAQeqzX8HXeO5RPRbQik
         61KitaIP70Ul1gcChAG4YgpB3grDqu5M+DMo4U3a+4Yfxdywpqp/igqFrIoB3x5khmPp
         AFxDhrntCAasfBYtGA7AAZ9UKvse7jLSDJidYYqSGna6nvBZSg/16cuI2nPh7UAP7Ir7
         kOy+5Mijft4JAs6CKoM44S7i9nE/57KsnSh2FlIZ8WYaAXhF+fPNgPQwTLkn+i2XVdvv
         l/huFzGyv9h04cYuqGNIp/RfErRKYaDzzTzUYS72YPHjSYp2qR1g2ZSuPvamJS99VrIs
         VBpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVmJ+PQH3SZEJeTJ92FRlB5wtpsDCUUxtCmIycPrrWmc/fMsS3+
	UiYcl+Y8NjYDk6PMKRO6fybpOAmkGk+HPIy3OmPglClJ8ZTRilHxQ23kESKdOeob98P8CbIHQoE
	gnvOD68ADqlvsJcjpaObdRSFnHU+5FBdKMxrpY+Gjgg0k+emCdDA9E6cOraAvLJxybw==
X-Received: by 2002:aa7:8193:: with SMTP id g19mr14800625pfi.16.1564038858498;
        Thu, 25 Jul 2019 00:14:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwX3L88HcugElazS6FT4SojO+5wMMBwAxqFvj6sRCY8fQmwyfnQy2RF/7fGqD8P6svSXjqy
X-Received: by 2002:aa7:8193:: with SMTP id g19mr14800578pfi.16.1564038857537;
        Thu, 25 Jul 2019 00:14:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564038857; cv=none;
        d=google.com; s=arc-20160816;
        b=ReQp+8W8QOdjD1+N2jyfjaOLn5h7eDzTECk/Kc65M8q9IF6f9Yf/uo/UcoLQaXjvjZ
         0dF2qyLSjAoUOdNaZ1Vh+A9Lm1SqeS7tHVunn2TW1Fqzza90NjUidKo055E1klrgQeUT
         pbOVXjveQLDl0/zj48o6xWrF663X0Ufd+NwxCoe10lHGIduiOW9A3JamdBaaAdUhj/Zf
         Fiv9/IkPuMvzWqD+knh5SKfB7bGfDrFZqt89wtmE3UXDHOp56jdsIzu8LNdHn0LRniJw
         Qtm8skxbBH5pawMCBQ1QVAa8ZgtCR0qIDFNPhCmrMtZIX1qqYcve3fr+2DS4t75B1tX9
         VDEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=pl4VFNjumg1HwDu/CJY+b146qJd52pJu/R/JaNNnLPY=;
        b=qP2/IImN9jPSqoJVhzR0+kGE8GMPa4XMwpwZ2Hz5elHkJ0WINahnYMi+H917qkPweZ
         TZ0/rf+B85wkEt0TG5sh4wlddNgmq1VDAXzIJZe+8SSqekdD8DdVaQtUDbVza0Lig/tQ
         0L7dy8TAFsPbBW35P3RmOYozohlkSz2PmHJW6x8dpeVr4kzlG3DOKM6ZBd7EgA87a6F+
         HzuTMOckCg8c/TUDz0/e/WBb2g3HqRDEKw4yiChqvwg0iU6d8jmxDS4cbSKRnnanngtG
         SqGxwiRn+s5E5wT830sMi3j5RnWKq1g4NEJZ9OfCNiJWcYgiwkWC/uxi6CYAM/MGJ8OT
         SPwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id l62si20489529pge.590.2019.07.25.00.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 00:14:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 00:14:16 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,305,1559545200"; 
   d="scan'208";a="253846210"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by orsmga001.jf.intel.com with ESMTP; 25 Jul 2019 00:14:15 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,  Matthew Wilcox <willy@infradead.org>
Cc: huang ying <huang.ying.caritas@gmail.com>,  Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,  <linux-mm@kvack.org>
Subject: Re: kernel BUG at mm/swap_state.c:170!
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
	<CAC=cRTMz5S636Wfqdn3UGbzwzJ+v_M46_juSfoouRLS1H62orQ@mail.gmail.com>
	<CABXGCsOo-4CJicvTQm4jF4iDSqM8ic+0+HEEqP+632KfCntU+w@mail.gmail.com>
	<878ssqbj56.fsf@yhuang-dev.intel.com>
	<CABXGCsOhimxC17j=jApoty-o1roRhKYoe+oiqDZ3c1s2r3QxFw@mail.gmail.com>
	<87zhl59w2t.fsf@yhuang-dev.intel.com>
	<CABXGCsNRpq=AF1aRgyquszy2MZzVfKZwrKXiSW-PnGiAR652cg@mail.gmail.com>
Date: Thu, 25 Jul 2019 15:14:15 +0800
In-Reply-To: <CABXGCsNRpq=AF1aRgyquszy2MZzVfKZwrKXiSW-PnGiAR652cg@mail.gmail.com>
	(Mikhail Gavrilov's message of "Thu, 25 Jul 2019 11:17:21 +0500")
Message-ID: <87v9vq7fi0.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com> writes:

> On Tue, 23 Jul 2019 at 10:08, Huang, Ying <ying.huang@intel.com> wrote:
>>
>> Thanks!  I have found another (easier way) to reproduce the panic.
>> Could you try the below patch on top of v5.2-rc2?  It can fix the panic
>> for me.
>>
>
> Thanks! Amazing work! The patch fixes the issue completely. The system
> worked at a high load of 16 hours without failures.

Thanks a lot for your help!

Hi, Matthew and Kirill,

I think we can fold this fix patch into your original patch and try
again.

> But still seems to me that page cache is being too actively crowded
> out with a lack of memory. Since, in addition to the top speed SSD on
> which the swap is located, there is also the slow HDD in the system
> that just starts to rustle continuously when swap being used. It would
> seem better to push some of the RAM onto a fast SSD into the swap
> partition than to leave the slow HDD without a cache.
>
> https://imgur.com/a/e8TIkBa
>
> But I am afraid it will be difficult to implement such an algorithm
> that analyzes the waiting time for the file I/O and waiting for paging
> (memory) and decides to leave parts in memory where the waiting time
> is more higher it would be more efficient for systems with several
> drives with access speeds can vary greatly. By waiting time I mean
> waiting time reading/writing to storage multiplied on the count of
> hits. Thus, we will not just keep in memory the most popular parts of
> the memory/disk, but also those parts of which read/write where was
> most costly.

Yes.  This is a valid problem.  I remember Johannes has a solution long
ago, but I don't know why he give up that.  Some information can be
found in the following URL.

https://lwn.net/Articles/690079/

Best Regards,
Huang, Ying

> --
> Best Regards,
> Mike Gavrilov.

