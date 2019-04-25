Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDC6AC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:25:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED15020644
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:25:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED15020644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2ECD46B0003; Thu, 25 Apr 2019 11:25:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29B446B0005; Thu, 25 Apr 2019 11:25:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 165AD6B000D; Thu, 25 Apr 2019 11:25:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AFD8D6B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:25:54 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f42so11826406edd.0
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:25:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JUHCXsxI21xAskyPS/8qWCx/sd6/yDCl0smP0UgAJ7I=;
        b=DMhbipbfgahlFs+czdvrwyi9tjX5HNYt8f98yczaa76gC3dbNMZNTBCwUwZ2t9eYAA
         HDgcaPU/lEKHMX9J9awxhvP52mAu2NYJNPko5KoQH4IAy8m7SkEkKXgGuTXZm3C1L5JE
         roaMjB3ZPrlO1q3/rqWj/jHkD+iADMWSLymO9A+Mo+QELMUiLhN8u4oTxSKg5VVt/bzs
         O0nEULiVDvSYVJ5pCKzazoku8Vq2ZxQtteeiIiQ4HZfyeBg9TrucCQov2N8iLmlZqd0e
         b94zk6onS6tRqP+sH2KwqU+nsppn5pVX22GGxz2WzFUOqGPWwBkKy0aDSvUSusBlPtL6
         6bNw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXlouMtJnqM2GjqziJndABdmy6jXOcrXwcuYd6+m4IkhStk7+Qb
	VwiVRN56kTMlsH3CTGQizk19ZF8J5AKuth5W3/jf+Mqhd8hrhQNSSjkeJDoVHl7fyJVSPxR7gME
	ylPE9kRQal7dLXbohQaST5FwG0FBT807d0bJy3keCWHCnqQkPblIByToKa2ADFSY=
X-Received: by 2002:aa7:d50a:: with SMTP id y10mr24242995edq.261.1556205954237;
        Thu, 25 Apr 2019 08:25:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0OPy1frJF77PpFIlICNyjpaqwuPSgUqIHDUmqlaY82tvUMwyLlk+2+217OIBdhZl+7Ckh
X-Received: by 2002:aa7:d50a:: with SMTP id y10mr24242940edq.261.1556205953258;
        Thu, 25 Apr 2019 08:25:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556205953; cv=none;
        d=google.com; s=arc-20160816;
        b=Ma3N80NMZbPOj9Yp/oD11ji7dnkbRqoJLAtaOzwIP4tu6YZaO/6ThS/GEIDnR54uUL
         cVfesMt4U/JWeUKf9J7bce8H99xXNtvDmQlPz0QqKaotI/fsmGX/Qt2YoUcYi9BbHfkH
         vKW2LuzT+h+iKiFZ8dWPyXS09xiInpWRymFK5YZMNbY0+pXiDhUuTayuM8SYR07wrmRS
         bjDJw8q/G1ENQDpxKC586mSHXdrPIFI9fIDaMrq4drcZOcxmQH+5wJa8Hs9vF3pAaxzq
         cry9JUhj0m9VloND/dEmcXkfbrp6q8GugpawdQK3UKZ+etCBrYWwU8n1QHZ+ePQl4xkJ
         CDng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JUHCXsxI21xAskyPS/8qWCx/sd6/yDCl0smP0UgAJ7I=;
        b=mmXu8bF/i6ahSD5cR1Lsod3tZAeWoQ7/QtBDthNgvXGHJHBtWkEIKCOxZ//uxdqESG
         ItjT+3bJf2PfK+ZPD59wK0iSJYWK1rzRzlG07MfTJq+4W12wHSdhTwdqkzhvT5Vj2fpJ
         R2ZVvqwrRHN2O2p3tHMuEbY/qQXxWuH7Mogkxv92ckV451PriEBNufVsJl9QlfV7GNsP
         OIJjkwwin45/X02mF7AEOD5hLgEHaeFYJmjbiiACOkrS3UhOG+1E71NlC3lS9hTKi0Gj
         ODGaVWCKQ+FqGDnty/fo4aJZCfqcyYhKtdfipIRNGCk7z5aIa5hU7NmNscpvQzTf5zfa
         EZCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g8si435454eje.360.2019.04.25.08.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 08:25:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6F7B5AF26;
	Thu, 25 Apr 2019 15:25:52 +0000 (UTC)
Date: Thu, 25 Apr 2019 17:25:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: jmorris@namei.org, sashal@kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org, dave.hansen@linux.intel.com,
	dan.j.williams@intel.com, keith.busch@intel.com,
	vishal.l.verma@intel.com, dave.jiang@intel.com, zwisler@kernel.org,
	thomas.lendacky@amd.com, ying.huang@intel.com,
	fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com, tiwai@suse.de, jglisse@redhat.com,
	catalin.marinas@arm.com, will.deacon@arm.com,
	rppt@linux.vnet.ibm.com, ard.biesheuvel@linaro.org,
	andrew.murray@arm.com, james.morse@arm.com, marc.zyngier@arm.com,
	sboyd@kernel.org, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH] arm64: configurable sparsemem section size
Message-ID: <20190425152550.GY12751@dhcp22.suse.cz>
References: <20190423203843.2898-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423203843.2898-1-pasha.tatashin@soleen.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 23-04-19 16:38:43, Pavel Tatashin wrote:
> sparsemem section size determines the maximum size and alignment that
> is allowed to offline/online memory block. The bigger the size the less
> the clutter in /sys/devices/system/memory/*. On the other hand, however,
> there is less flexability in what granules of memory can be added and
> removed.
> 
> Recently, it was enabled in Linux to hotadd persistent memory that
> can be either real NV device, or reserved from regular System RAM
> and has identity of devdax.
> 
> The problem is that because ARM64's section size is 1G, and devdax must
> have 2M label section, the first 1G is always missed when device is
> attached, because it is not 1G aligned.
> 
> Allow, better flexibility by making section size configurable.

Is there any inherent reason (64k page size?) that enforces such a large
memsection?
-- 
Michal Hocko
SUSE Labs

