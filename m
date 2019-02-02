Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28B66C282D7
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 07:14:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E086420869
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 07:14:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E086420869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C2978E0015; Sat,  2 Feb 2019 02:14:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74AB88E0001; Sat,  2 Feb 2019 02:14:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59E0E8E0015; Sat,  2 Feb 2019 02:14:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 112748E0001
	for <linux-mm@kvack.org>; Sat,  2 Feb 2019 02:14:22 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id t10so7101116plo.13
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 23:14:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=ncxZjFu+N4r6F4RNDxLYEZELwgKQK/ZG9XZOSBhYLd0=;
        b=mz5OQgOKq4d+/shttFB1R2xG8FK3goKF+eM47pVjO4f9mA3DrgvyPQDDUFbT8MyDD5
         ha+TnTp316PrN6Xzqvd5TREyjPBmoe5r6/iHeZF19IONeOChVBE+bqcsfs5g3Jgkl5PN
         HISFgoPcy9pQofjnxehyaiH/qgUrvMMu5QXfcQCHEwokmRD9Lv6E7/WaCqtVFXxRYppx
         mNF7N5p6AnMW7emArHkNhdCKWwJZzUQXUUoqAj8FK+DwRZc61tdaBZnqE+JE7QLDTqFF
         8QYsh4urVwP7qebUh5ZA4L3hEe1d8/AlFAF3W9ijQP4II1Nv8/ti2RTIwL7YPwG5ex+t
         ogrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukd0upuy4TUieb5Aj7sx6ihDxbQIP/J2LjhcjtEkq/Z95YSWbmhu
	EPicS1TSweIS9E0uV56oBSKmrvKUQ+M9zYZFB/MqMyE1BNHpOdNqujLH1X1C99GwY0h08RcEADC
	CkX6GP4LDNzW0vZVkw6Qwz08VlI8kVHLtA0J5ORlDsbxiZvns44wvPjONWmydNFmD1A==
X-Received: by 2002:a63:b30f:: with SMTP id i15mr38858831pgf.240.1549091661711;
        Fri, 01 Feb 2019 23:14:21 -0800 (PST)
X-Google-Smtp-Source: ALg8bN51UA5uAzgeohznV9vH5igXcY+TA52WZvyqPFaKYTWholuN+C37zUo4TEWwEjLGjy+sibp6
X-Received: by 2002:a63:b30f:: with SMTP id i15mr38858812pgf.240.1549091661029;
        Fri, 01 Feb 2019 23:14:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549091661; cv=none;
        d=google.com; s=arc-20160816;
        b=nvGnI+u5/qKiERkEPW4XUEcagyN0avRZ+AMdZxoKWKr/22b0GBlISJRxIDeeed/s1m
         p1MB6dQjVLSxmNfmcqxw7QGg2ek7xnOcoxGublhCPLYf6bDIb8LtKWjCbe05qf3tmDmp
         LaHCWFW0MvBRYbVuFmuLGmdXyg2Yy5/7Vq7rBoPOAaoNT80EtEVs74iIZQnf+nGHlrZz
         ELKyGtJ8SZMWgSOEnldkCoFckaC1Ie5LgkWyHrEHd8fsB0YI9zJODZ6pAosHXgoUN/Bc
         2VKgmMPxwh3nAp6QS8ePkh6nddWeBcaZGfi8DAwTgI65sIRC5zYw7trr4dRQw/h7yN9d
         fjMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=ncxZjFu+N4r6F4RNDxLYEZELwgKQK/ZG9XZOSBhYLd0=;
        b=RfXW/8E+XzxE9hkQgt/urxnr/kQZBuIhjEFAtmQcR2xVGpjuPL+Dgd5jhRDagMxGy2
         cyb/peKzoB2twi1aI93MqIOQyPf1jfR0If0LDFHmpaTTsU3iT5Is+eXSyJFp+sqhcYBb
         YFS3KYT5gX/HbYU3FfPU9GabgFkTVXlGqETzn1g6GescnjH1SoWNedKoU1b9wO8b1pFc
         aoZM01wrb2CL6KqGsOaxK7hkhcFIxPhzxXaWuzGTooTserowfeBVhzDHYq5F/FmeJRLR
         JqaY+SX4mM7u+g56Vjiik50cBxLyKTUraz5eCAJoaEuQHaNfOUEe4+Fuiqypzb/eJaKK
         Qz6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 33si4288851plt.228.2019.02.01.23.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 23:14:20 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 Feb 2019 23:14:20 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,551,1539673200"; 
   d="scan'208";a="315727247"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by fmsmga006.fm.intel.com with ESMTP; 01 Feb 2019 23:14:17 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,  <dan.carpenter@oracle.com>,  <andrea.parri@amarulasolutions.com>,  <shli@kernel.org>,  <dave.hansen@linux.intel.com>,  <sfr@canb.auug.org.au>,  <osandov@fb.com>,  <tj@kernel.org>,  <ak@linux.intel.com>,  <linux-mm@kvack.org>,  <kernel-janitors@vger.kernel.org>,  <paulmck@linux.ibm.com>,  <stern@rowland.harvard.edu>,  <peterz@infradead.org>,  <will.deacon@arm.com>
Subject: Re: About swapoff race patch  (was Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL derefs)
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
	<20190115002305.15402-1-daniel.m.jordan@oracle.com>
	<20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
	<87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
	<20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org>
Date: Sat, 02 Feb 2019 15:14:17 +0800
In-Reply-To: <20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org>
	(Andrew Morton's message of "Thu, 31 Jan 2019 12:46:55 -0800")
Message-ID: <87zhreu0fq.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 31 Jan 2019 10:48:29 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
>
>> Andrew Morton <akpm@linux-foundation.org> writes:
>> > mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch is very
>> > stuck so can you please redo this against mainline?
>> 
>> Allow me to be off topic, this patch has been in mm tree for quite some
>> time, what can I do to help this be merged upstream?
>
> I have no evidence that it has been reviewed, for a start.  I've asked
> Hugh to look at it.

Got it!  I will try to find some people to review it.

Best Regards,
Huang, Ying

