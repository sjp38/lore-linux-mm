Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDE27C282CB
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 00:58:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2AB82175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 00:58:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2AB82175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4550B8E00A4; Tue,  5 Feb 2019 19:58:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DAA08E009C; Tue,  5 Feb 2019 19:58:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27E108E00A4; Tue,  5 Feb 2019 19:58:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D16488E009C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 19:58:46 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o187so3477392pgo.2
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 16:58:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=iufs91SqQAu/I5/RzUTK+ChUmoS2efNaynlacgmQ2s0=;
        b=SIP9RZSFfKRqRZ7F/hZ94wlJpQfk9vrI23p1QpXJK4PwjXe67EHO+zmb1/hxcDdUjh
         fzujsODtj5McRBexLDVcujxH0ZPOC8iFGjDQINPrNV9KRrHPY41o6S45qrKB9/bdTTI2
         rJEB7lwLyOH9Ju+5rQWGumQXvnKgvof6f39VtN7R0PoWDZGrP75Tt0VixX4Ozz3d+UFr
         MSxAcqOJndRJPiuJ15pBOSQA1T2hkrC0tTbz2qDaVCVRmCqmBK5BRid/NXhrw5bdQ7Ql
         8XcMIBW2C63JgiOYNW+fd1BUyUiLeG/A3qAkXsPOq6HcppdAvuOtUQ0wmASaYjxVIRgq
         cTPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubBOD2w21iuAFkuWH5nQ9pA8u43Lvsvxz4VIJppkIrO2I1zT7Gy
	EtkwHl2tZ/wpMatdlU7W7rPAVJfgSKRcHmOLApadNNCSpQN+GAbQjKOotC/un6+l2ZbCGYae0ed
	iTnIW078R7rQ92nlV1WdXJpzE8lRW42e4+j5qBZK5ryBYkyNnAeOGIa1ITGZta3PXhg==
X-Received: by 2002:a65:4c0f:: with SMTP id u15mr6827727pgq.225.1549414726430;
        Tue, 05 Feb 2019 16:58:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYJRkK8WqaAbOs4mFPySq7pafKTcv5p5WG9hXHn+lD5rLFELBTqrVhhMJb+hENK+q0C6VWw
X-Received: by 2002:a65:4c0f:: with SMTP id u15mr6827699pgq.225.1549414725748;
        Tue, 05 Feb 2019 16:58:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549414725; cv=none;
        d=google.com; s=arc-20160816;
        b=du7Hkx1B36pFdHsvTusXRbIAuik/iNXiDcCVPo2i0XlnesYWF4KoyEtY026Pq6Ychl
         mmXBpYwqnd+qA/pybrXrZ1YXP5iaH5G4k/JJXtT+1mP8z01LoZW6n9SMz59akc3b+o69
         33cNBtL16Ex5Y71sBIhzX33SiHwSq+myIuaeZJgOuO5Pr/Y33afbXW1peim1G0afcQji
         NOz3s4pS1ERhKxcjgstiDGDhUyrLwTyBR9wotiZuv1fcx3UCHI7U33xDGIKPlJlSZABn
         Z/+Pc9zxYYdFiivrhdcUJibiiAa4+FezioTJx5a2999slnYkIjP1lu/3eksjY6yOjvhI
         UxIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=iufs91SqQAu/I5/RzUTK+ChUmoS2efNaynlacgmQ2s0=;
        b=Lzmr9/qdoz7MxnvIr5zeOeWnEAUoF5UOSv+nZLGUCb29z3Qq9/GTkKzlbueDClDjZ5
         o/lZ6+91xqD0nU0oOXxVu/VO8cggIeSbHuMD/y9ERKardj8DVOJUHmqpuqrivuil39Bs
         4VmxPioorjOdx354fTnPxlMCdD1E1b1uOVyaQjZV2A+mcXdiedXse8TzSpVVO/YJtnDP
         MSTH16z+PgFT0AY4ui676/vVRJ3fSedmT1P5yWzo1RVhYg+Xu9aoOohO1acALaBM9+N/
         tFPVHWuuH3O7ANbpFJcqdHDWZx6na7Ud+j+3JoO1CvMSZNgU34vnjtUi51YQO66yDwaW
         Z86Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n5si4307549pgl.485.2019.02.05.16.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 16:58:45 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Feb 2019 16:58:44 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,337,1544515200"; 
   d="scan'208";a="141895210"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by fmsmga004.fm.intel.com with ESMTP; 05 Feb 2019 16:58:41 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,  Daniel Jordan <daniel.m.jordan@oracle.com>,  <dan.carpenter@oracle.com>,  <andrea.parri@amarulasolutions.com>,  <dave.hansen@linux.intel.com>,  <sfr@canb.auug.org.au>,  <osandov@fb.com>,  <tj@kernel.org>,  <ak@linux.intel.com>,  <linux-mm@kvack.org>,  <kernel-janitors@vger.kernel.org>,  <paulmck@linux.ibm.com>,  <stern@rowland.harvard.edu>,  <peterz@infradead.org>,  <willy@infradead.org>,  <will.deacon@arm.com>
Subject: Re: About swapoff race patch  (was Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL derefs)
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
	<20190115002305.15402-1-daniel.m.jordan@oracle.com>
	<20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
	<87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
	<20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org>
	<alpine.LSU.2.11.1902041257390.4682@eggly.anvils>
	<878sytsrh0.fsf@yhuang-dev.intel.com>
	<alpine.LSU.2.11.1902051618320.10986@eggly.anvils>
Date: Wed, 06 Feb 2019 08:58:41 +0800
In-Reply-To: <alpine.LSU.2.11.1902051618320.10986@eggly.anvils> (Hugh
	Dickins's message of "Tue, 5 Feb 2019 16:36:35 -0800")
Message-ID: <874l9hspfi.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hughd@google.com> writes:

> On Wed, 6 Feb 2019, Huang, Ying wrote:
>> 
>> Thanks a lot for your review and comments!
>> 
>> It appears that you have no strong objection for this patch?
>
> That much is correct.
>
>> Could I have your "Acked-by"?
>
> Sorry to be so begrudging, but I have to save my Acks for when I feel
> more confident in my opinion.  Here I don't think I can get beyond
>
> Not-Nacked-by: Hugh Dickins <hughd@google.com>
>
> I imagine Daniel would ask for some barriers in there: maybe you can
> get a more generous response from him when he looks over the result.

Thanks a lot for your help!  Will ask him help too.

Best Regards,
Huang, Ying

> Warmly but meanly,
> Hugh

