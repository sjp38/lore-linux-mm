Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 315DFC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:34:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA2DF22ADA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:34:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MQuSOeR9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA2DF22ADA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 817866B0006; Wed, 24 Jul 2019 15:34:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EE786B0007; Wed, 24 Jul 2019 15:34:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DDF88E0002; Wed, 24 Jul 2019 15:34:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 380486B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:34:30 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n23so17128989pgf.18
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:34:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1fDn3AFXXm19Ake8tU5gjq3MWC1W7K5qFY0eF05b2Pc=;
        b=BtePxHkpRqSuMEMtslCLSN5/KFrxgi0kzl6mF0GsQ08t06MOXPg28glPYNLCWaySvP
         lFi2T+1ILRX8ZAK11TJtS5daeGZ1EjJD82ctID1oXELzd6sUdC3+g4/uetMRrlVd6sq5
         /8y7APpu9m5ofQTovje52ZMS8TSUrZrai10ejSDEfU9cmJUziHgP50dVJ4FILtxVXF0X
         GJSpro3wyNjvGroyPhK3reO0r6I5JQPerz42p06+cltFtfD7R2i9Yq6ktk841GO2MA4M
         b77c0tJLldjMx+gs5pQ5yYoVTi+GhtQvhU73dXnO+G8zZ4S7goIwddxXElTJEXocoQQh
         EPdQ==
X-Gm-Message-State: APjAAAW0ViRno2hXdzvWdIoQT4YTAI1SRMQiP0uQdF2X4VRdyBStyVmI
	/fv311gBU4rFUxlIYCteNjJPOKRGebQE8sfJq4fLEsitWS3ErEuQRgn1dcSjI+Eeezb9pkH0K5Z
	GvaT1zme68T7AbJHSRDZMRkt81Z3NB47Vqx/LBngrxE4RVDb8PMP6sXSsIphKaeBvvA==
X-Received: by 2002:a17:902:bc83:: with SMTP id bb3mr89278334plb.56.1563996869867;
        Wed, 24 Jul 2019 12:34:29 -0700 (PDT)
X-Received: by 2002:a17:902:bc83:: with SMTP id bb3mr89278302plb.56.1563996869346;
        Wed, 24 Jul 2019 12:34:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563996869; cv=none;
        d=google.com; s=arc-20160816;
        b=pNwZ0o/jdn1dufySSRTA0uAh5dvA7kUUlMurU6FHfKmCGIVGkzPdudFVQakW//gaF6
         7vQPtdENiawSPD7so/ohNx6ukbloEE3dTv8WKqtoPCgfPE4jiXPGZYjNBHRj82+ycj0J
         5gaCgByTWaYeaIimAM4cE14WA03nQJu3XqPFzwcsKsQjGZBgrVVkvDpouvH0eDiv0is1
         czKEac3L42aCtZXZGv01j7Eg9NMeVF08feAAg2AceOq5wIzAAoun3cM8YqyGROhBEUPE
         b3PQ4B4mYPHAbRClgh2WFZlX1/GekILeQnqu3fLm0disCcEl+3st/n53zFJj4/JHlSli
         JBrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1fDn3AFXXm19Ake8tU5gjq3MWC1W7K5qFY0eF05b2Pc=;
        b=WKQOTqTfK6wKCerisDU8CwhgLbrRSrfCnaRMA6RmBkLdkCsh30WeH74D/gPyBirqh1
         O8J1+PIx812sXpUFXo7poe/2KcGeEF9AMnR3wjSnYEEBVFTQ237YbajJkGoDqBGCHjhB
         DfKTvfX6vkeeeq7S0mfQ9iFOBpLr+ONc43DRPO3DPdM6yjtke/P97n/84akyf/xhttIg
         ZxDoZjBBegaTuErtzy9WJSQzca9ct9WJ5wycEShRkdkc9h/MLk0X1D3PdCHer7UjVMjW
         NFr86Zs5QXgIgeShVLyzLwcjjmJ8iHJwt4Yp8vCqBt9nclJ3QD4bpVt5oAS2C23/EqGS
         7OFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MQuSOeR9;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l16sor64909719pjb.0.2019.07.24.12.34.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:34:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MQuSOeR9;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1fDn3AFXXm19Ake8tU5gjq3MWC1W7K5qFY0eF05b2Pc=;
        b=MQuSOeR9mj5QCC1q4RsYGdjizf19viLBu8D0muFmywAqDmossyMthj1BsTRNG8GwDI
         kxGHWNPIj3YJR1RWdDp7q+atj144Oxc6UttaYcUuFECwrQVyHnbjrs/T/hkRg6c2APan
         pkPDkRAUv4DyfkYuDSYr8lqe07nJw1WycUm1GdzJKL+XhWhy3CedPhbfcC/oZWDJX96Z
         HphILDBSrUAMcxlSt5OQJiUdyFQKoKLtjOWQJAoTJBz4RfW0sl5Uv3RrbHmNfO618yw6
         QFFO1qg0PjZsg8UfzVFJexHRrSi+j6VzvJ1Lix3GIyXS5Q3uM/Ng9CEbCxPzAi2ZGMlp
         fYMw==
X-Google-Smtp-Source: APXvYqzWJWqJ5BleMO/Ei96DUKZpyyodxYvZ1d6IP5GguMosVsO0BWc/rWyOZUkMH7b44piPkNU3oA==
X-Received: by 2002:a17:90a:cb15:: with SMTP id z21mr43431285pjt.87.1563996868963;
        Wed, 24 Jul 2019 12:34:28 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id v7sm4447177pff.87.2019.07.24.12.34.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 12:34:28 -0700 (PDT)
Date: Thu, 25 Jul 2019 01:04:19 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: sivanich@sgi.com, arnd@arndb.de, jhubbard@nvidia.com,
	ira.weiny@intel.com, jglisse@redhat.com, gregkh@linuxfoundation.org,
	william.kucharski@oracle.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 3/3] sgi-gru: Use __get_user_pages_fast in
 atomic_pte_lookup
Message-ID: <20190724193418.GA19421@bharath12345-Inspiron-5559>
References: <20190724160929.GA14052@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724160929.GA14052@infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 09:09:29AM -0700, Christoph Hellwig wrote:
> I think the atomic_pte_lookup / non_atomic_pte_lookup helpers
> should simply go away.  Most of the setup code is common now and should
> be in the caller where it can be shared.  Then just do a:
> 
> 	if (atomic) {
> 		__get_user_pages_fast()
> 	} else {
> 		get_user_pages_fast();
> 	}
> 
> and we actually have an easy to understand piece of code.

That makes sense. I ll do that and send v3. I ll probably cut down on a
patch and try to fold all the changes into a single patch removing the
*pte_lookup helpers.

