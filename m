Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88BDDC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 08:14:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B7BC20652
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 08:14:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B7BC20652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A35F46B0005; Tue, 11 Jun 2019 04:14:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E7406B0006; Tue, 11 Jun 2019 04:14:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FCFE6B0007; Tue, 11 Jun 2019 04:14:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 454B76B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 04:14:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p14so19527641edc.4
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 01:14:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ZWq8OEuzCZpBJ21OEAhCH6HP5H4hUsFxTXMhE34ApCE=;
        b=WGyk2DOGJzBmChrfw90v/q56F8Com4u6q3352m5EdpYO1kQhuv8UyDcn3NXdCxJQwT
         lEYzLfyu63js5HDfVOhuKyu1BBHWJHjd1GH7SycZ3WTmGhe3iu/Z7+fJpStnT+o6XAZl
         bYZS3wVHoCWrE/xm0GMPZq3Niz8H61yimy7abQVzgBJ2V7No/HYHsLDouHBTj/SpTAin
         f4nE5unD+WKKGFHIprscpCXw5qp0cY7UoRp4VeVBncJebaRJQYBl30o2hrOpI5rnoD6l
         HlR6ZH/oWu99G2z/HMRuNEzrf5vTaWgYRqPUhA3G/G6iT3BuHQdwpNwBNYmqD4eLacND
         LQlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXibb6dbi+cYjpck0OeJqEnogzR1ZfHQCv68edFfkzGxuWTquCL
	yFnz3up6DjScNIHI6mFtHzKeh3FaCQzvUivFuqzvXdhsop0/QC9aNf9UTZ5I2mo9xwVrvddr5U5
	fzSJYQiJqIDTDPqCXAs/99TJ8vfsMaA1u05XwTn9l4rqmt/SMD6d0HXoxNto0wgTWtg==
X-Received: by 2002:a17:906:5cd:: with SMTP id t13mr25209820ejt.270.1560240873861;
        Tue, 11 Jun 2019 01:14:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqozMRcs7cfkNx12aLGxjjF/tEKrdkr0seuOdXGe7RSh5JRHNAGvygkBJ9STvMvgOmFN61
X-Received: by 2002:a17:906:5cd:: with SMTP id t13mr25209765ejt.270.1560240872822;
        Tue, 11 Jun 2019 01:14:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560240872; cv=none;
        d=google.com; s=arc-20160816;
        b=EetNwMFAaoRi4pyoZG9pfK5rCOQ98baUiJRjGIXC110UKfKUHDZruP0xn1ICN8512o
         vfpIGrwJrws+v+m/wT/sP1jwI5SuHow3nQfXtS3Lg22qA3I3J18Z91xj7/ffz27863oa
         zDSfcSaDqwVupk2NnUg4J//O2bM/FWs1gBXYVbF1UfNXESR6cscHvOadb7Gu72HRq/d8
         A+AfMIOUZFOULTGQa0IqS84lzJSWmSVawbr0JNxBpYvkWqepgDrGOGLiqI++GvWHnpNW
         gsUXzYz9RkFhP+NjYK1vwrhyqUylIQcLml2obg7bNHUGBpu5WTSmjGG7+gUY+0s24Eur
         05Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ZWq8OEuzCZpBJ21OEAhCH6HP5H4hUsFxTXMhE34ApCE=;
        b=0HR1DONtMzvQy80OfmvNFw7EmtMgL/TRt/RFjoXdqMA/vey3/pUq8Pa2MAG2FsbHBo
         1tb7Cotz4pauLAfZ+sCIoE6JvtPDJmRBBF1RpUIunRXFlk9i4RWKrksRcNfiMKhDh0g4
         iH0tHHQ7yxtOU2++fl7CUF2bLdzaQu/wDvlLsTSl1y6jzgWE6msCJNRieEYo6+d82pSH
         Quvnz1HW50mc43NrlRFi3LIU/0yHaX15njlbH9FqfKcShJBaadh3ifO8aUyGjK8x2uv3
         xdrl+XDQpe7uuU/QGx4ph68F1gu8qG4KJOGfK058sja3j529GWfnCGDYKazlS9lcSW5G
         uHjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id o25si2338403ejg.254.2019.06.11.01.14.32
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 01:14:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6C22C346;
	Tue, 11 Jun 2019 01:14:31 -0700 (PDT)
Received: from [10.162.43.135] (p8cg001049571a15.blr.arm.com [10.162.43.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 706593F73C;
	Tue, 11 Jun 2019 01:14:28 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm: soft-offline: return -EBUSY if
 set_hwpoison_free_buddy_page() fails
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>,
 "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
 "Chen, Jerry T" <jerry.t.chen@intel.com>, "Zhuo, Qiuxu"
 <qiuxu.zhuo@intel.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560154686-18497-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <8e8e6afc-cddb-9e79-c8ae-c2814b73cbe9@oracle.com>
 <20190611005715.GB5187@hori.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <67bb5891-d0be-ffb8-3161-092c8167a960@arm.com>
Date: Tue, 11 Jun 2019 13:44:46 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190611005715.GB5187@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/11/2019 06:27 AM, Naoya Horiguchi wrote:
> On Mon, Jun 10, 2019 at 05:19:45PM -0700, Mike Kravetz wrote:
>> On 6/10/19 1:18 AM, Naoya Horiguchi wrote:
>>> The pass/fail of soft offline should be judged by checking whether the
>>> raw error page was finally contained or not (i.e. the result of
>>> set_hwpoison_free_buddy_page()), but current code do not work like that.
>>> So this patch is suggesting to fix it.
>>>
>>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>> Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
>>> Cc: <stable@vger.kernel.org> # v4.19+
>>
>> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> Thank you, Mike.
> 
>>
>> To follow-up on Andrew's comment/question about user visible effects.  Without
>> this fix, there are cases where madvise(MADV_SOFT_OFFLINE) may not offline the
>> original page and will not return an error.
> 
> Yes, that's right.

Then should this be included in the commit message as well ?

