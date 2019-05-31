Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE6D6C28CC0
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 02:42:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99CAE26215
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 02:42:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99CAE26215
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 282176B0281; Thu, 30 May 2019 22:42:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 231A86B0282; Thu, 30 May 2019 22:42:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1485D6B0283; Thu, 30 May 2019 22:42:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2B8E6B0281
	for <linux-mm@kvack.org>; Thu, 30 May 2019 22:42:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d7so3676778pgc.8
        for <linux-mm@kvack.org>; Thu, 30 May 2019 19:42:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=tU7jex5GIzwZejVuIEKLBEybbkHIktkFUjNVgunM9dM=;
        b=HWdkN0aHfogb4VJR2/xrQbdssXXZL8VBRcDb331Ko+wn8aMTMxtYWFf4fLBfyB7wKd
         wcoIjw887H9fRJWxbD55rvywTZDhFcTKp34B6Mh/00yWwCRze4n2RwcTph55EoFaTMVw
         U7cg9q26BycQh4lRbglm5moxyr1Z0F4DCbtFgP9Win4vr4l+mR/27mayzgHbZ6dSWo3x
         E92/sgLsmQLMbdGvfrUdVT/12ugVZCFa0QAk/FwUAb+8lgs66KJrwfrDJm7//cMerB00
         kb8p96/SnU9B+nUiVGU9kXMPU1XOrI77/pSSeRUSrjI2BB3PJfyrz8dWqU+B+f8xAPON
         Repw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUxWjN4TlAUgi0KaSMNJJGRr8Wgq917ND/demMkfau6G9XsvMOQ
	lH/YDSEbkQGP7va7DfqT/fwceSVZ4AAG0ZFNaXwX9lb8s/QqRpm1SBot1KWK6DV8/HEzkubypOa
	V8M/qVOe1ldQnQxJST20BxM8CZ91AfuLwUXxHC6+0q25L53mdtmcJqh6NhoinKw5PQg==
X-Received: by 2002:aa7:8dc3:: with SMTP id j3mr7160113pfr.141.1559270559535;
        Thu, 30 May 2019 19:42:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwppcOFazCIiYhiYQ3QqtWDuapjb2KeFRfLnofgRX1jhO+TIwf+CWnihE0gdb/ZLUTac9w1
X-Received: by 2002:aa7:8dc3:: with SMTP id j3mr7160039pfr.141.1559270558244;
        Thu, 30 May 2019 19:42:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559270558; cv=none;
        d=google.com; s=arc-20160816;
        b=YF37blY9TfbbF1nNQeaJx7vdBMNUt+uSZpjjmCFOdTaQ2pHHNt6zU/eS0L8zwRhnni
         /zWvT5sx9ra2TEXVRj8wdLuRgmDej5wrzeJ2XIOcwSsHpGL+BkTQCFsybVtOQC0pSfEM
         VR/8NXmn5/Dvkb3pLLkLLJXX2qmDDTHOzqWerZCDpbBq2ymrpTMf8X5NkCZBQY5Z9Xpy
         oqg43uWzGV9+JzVs+1SrViKsJBmqPMFfH1HoxKzeXu9k0fkriZyOg4AovzZz/nkQ9TyY
         xd31LvSrCod2nW9j8rSuUCWchd5e0TMrtPwrj8f2iGaEVh8WElxU3H4Bg+yo2sCAY+kW
         hYQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=tU7jex5GIzwZejVuIEKLBEybbkHIktkFUjNVgunM9dM=;
        b=jVLBmtCBeRSfFERdrdCQwwRsB7mNiYyX7dOrilWWmIaZowhdh51YVPhHiNIlOIpDol
         yhtA2p3NkJQyOhP6yvb65FEg5KQgHyMOGEXuhxtUmQlqJ+0ak4Yhq+5ye1fOub3K9PAq
         bnPx2ro7RzhCCelO/khe5uopSKQePdTTDQ6tSHWe9ZiZfeNzfXVjy6P1xTsYkJsZH2Az
         knPvENc6OKWQGSkDvC6LjKPx5ZxrbMoX1lHVjexY/dHqhGNF3OfQsRSy5KCN7A3JFhza
         cV4JpzoTQHnaAOUOLyVuJ1nUgrfGKAoBvVlZJMOFTLS8Ot6elKS3KCLBHMwqkOAaM35v
         qM/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id k14si4993836pfa.206.2019.05.30.19.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 19:42:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 19:42:37 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga001.fm.intel.com with ESMTP; 30 May 2019 19:42:35 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: <akpm@linux-foundation.org>,  <broonie@kernel.org>,  <linux-fsdevel@vger.kernel.org>,  <linux-kernel@vger.kernel.org>,  <linux-mm@kvack.org>,  <linux-next@vger.kernel.org>,  <mhocko@suse.cz>,  <mm-commits@vger.kernel.org>,  <sfr@canb.auug.org.au>
Subject: Re: mmotm 2019-05-29-20-52 uploaded
References: <20190530035339.hJr4GziBa%akpm@linux-foundation.org>
	<fac5f029-ef20-282e-b0d2-2357589839e8@oracle.com>
	<87lfyn5rgu.fsf@yhuang-dev.intel.com>
Date: Fri, 31 May 2019 10:42:35 +0800
In-Reply-To: <87lfyn5rgu.fsf@yhuang-dev.intel.com> (Ying Huang's message of
	"Fri, 31 May 2019 09:43:13 +0800")
Message-ID: <87h89b5opw.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Huang, Ying" <ying.huang@intel.com> writes:

> Hi, Mike,
>
> Mike Kravetz <mike.kravetz@oracle.com> writes:
>
>> On 5/29/19 8:53 PM, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2019-05-29-20-52 has been uploaded to
>>> 
>>>    http://www.ozlabs.org/~akpm/mmotm/
>>> 
>>
>> With this kernel, I seem to get many messages such as:
>>
>> get_swap_device: Bad swap file entry 1400000000000001
>>
>> It would seem to be related to commit 3e2c19f9bef7e
>>> * mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
>
> Hi, Mike,
>
> Thanks for reporting!  I find an issue in my patch and I can reproduce
> your problem now.  The reason is total_swapcache_pages() will call
> get_swap_device() for invalid swap device.  So we need to find a way to
> silence the warning.  I will post a fix ASAP.

I have sent out a fix patch in another thread with title

"[PATCH -mm] mm, swap: Fix bad swap file entry warning"

Can you try it?

Best Regards,
Huang, Ying

