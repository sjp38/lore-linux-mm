Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEAFDC10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 11:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BEF5206BA
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 11:25:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BEF5206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E63556B0003; Mon, 15 Apr 2019 07:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E11E76B0006; Mon, 15 Apr 2019 07:25:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D00816B0007; Mon, 15 Apr 2019 07:25:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 980976B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 07:25:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h22so7502989edh.1
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 04:25:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=YzBsUGO6BltE/Wftbg76QF1TLm8Shh/t6RWrzzUPULI=;
        b=N2/BhwNnGT+ABqzbtLf78Kk2OkZqr8UGfOJwRWD2c0FXVQ8bA1OqM1jZDwAEiEasBV
         x9uLBGZ/djxgYouUNe9d0pv7mkl+DHYbD+Haixj8fF8xF0ZLoLn2mtpDcXfYwlAta+US
         2bvnImAtWAKUG9OsJUbedowHJgOdqfvG35cwWulZbms0/Mgzh3lgmfWeRPA5jkUpbB92
         WbMotUL9r55YaRdKV+pIhf1EtawO04tt8XEBBJo6k4GTvHdeZkCqUto1V+g5HlXPp9ry
         h3saHduc+mC4f2/URRn00cjYeLEpMHMbaLFm1j/sobrNUIBAc0hcULLdguQ0gGJTJUBk
         6DJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXdSIvhEB2H1cpChI/XU2gaqfOg5ri/7X7rkf6m9DaclIr6ByHk
	+xH9fHGzJS2k1SlAlr3OaTu3ve0Gn9GvwBkH2JSzqZji6/95Sr40I35BicnUIl65SUDG0UO695g
	VOMU39AmkYGgODwhDt10InoMToYwJAnKZctTo5ess1HnsjmR6xE9rTkbYxuB+c71tKw==
X-Received: by 2002:a17:906:4b10:: with SMTP id y16mr41402969eju.19.1555327532012;
        Mon, 15 Apr 2019 04:25:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaL0HMVLYvbXPq/KXF0AduC0VWE6/gasSP2wakfQHOYPOYqgGqawCSGLdHrJTtlv1qiMTj
X-Received: by 2002:a17:906:4b10:: with SMTP id y16mr41402941eju.19.1555327531234;
        Mon, 15 Apr 2019 04:25:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555327531; cv=none;
        d=google.com; s=arc-20160816;
        b=T14Z6tA6GwANd7S6pbr7v8/hrrQy7JmvbXLbE54c8rYdcrD9Yvfjmh+D+CR65ngzbS
         Rjv5ea8kh3WKICCcclbukUvN/3QGz/bXkzcWqBPmrLwDZuWopHSPyx+fS13c7YrGY30R
         OsNnjZiJEIPVBgeA+niotf2YvgZiVnX2cq2s7hOJZitGXhVmlK6iH3HObFbHGOASdPG9
         cB+WUsfOQDJZuHm9PfmOt+s971a9s0+/UtdGrRxiOLIZgFHXwYjG/tn0GwPPz3jY8MaU
         Is/eiDA/VbEsMIPccQLnQV4LU2fhUQSvRZuXxOn/xyv9s8is8RhPQg8c9ZQ9IiTUa0Ot
         7L7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=YzBsUGO6BltE/Wftbg76QF1TLm8Shh/t6RWrzzUPULI=;
        b=vbcogOZZnueCeeFtCluNIbMv7l1jFVDq5MiYGGh3HGMTeSZbS96rBuCms3nDWG0hPU
         r4t/WJLfx47SK3ScJ3RlfOFM49mlZUtDCfqfG0LioaCxXcRIxcZOrVqR+eHhMbLhmBTm
         jcu7ahisfky3toU5o/vFxgPW92ero+DXALmSGZdUkV4xC/MaqZ+TNDEBBHIR879dzv07
         Cae80J/NiGl/312w55PpokJQ61dYNeibkd7O9zyPLG1+o1+DJ3emHZlcgmFPrRikI/9F
         LhZDNAI9jJbLjbV03RSZS+M7AHMD0Q2RUmriT7lD5Ri0VbanMSEWoSTEqw7/y/b6VH9i
         GfIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r10si1352266ejn.146.2019.04.15.04.25.30
        for <linux-mm@kvack.org>;
        Mon, 15 Apr 2019 04:25:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CA35280D;
	Mon, 15 Apr 2019 04:25:29 -0700 (PDT)
Received: from [10.162.43.203] (unknown [10.162.43.203])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BDE383F706;
	Mon, 15 Apr 2019 04:25:26 -0700 (PDT)
Subject: Re: [PATCH RESEND 2/3] mm: clean up is_device_*_page() definitions
To: Robin Murphy <robin.murphy@arm.com>, linux-mm@kvack.org
Cc: dan.j.williams@intel.com, ira.weiny@intel.com, jglisse@redhat.com,
 oohall@gmail.com, x86@kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org
References: <cover.1555093412.git.robin.murphy@arm.com>
 <2adb3982a790078fe49fd454414a7b9c0fd60bcb.1555093412.git.robin.murphy@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <a99d745b-af51-8389-e71e-7d16fcbfb79f@arm.com>
Date: Mon, 15 Apr 2019 16:55:25 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <2adb3982a790078fe49fd454414a7b9c0fd60bcb.1555093412.git.robin.murphy@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/13/2019 12:31 AM, Robin Murphy wrote:
> Refactor is_device_{public,private}_page() with is_pci_p2pdma_page()
> to make them all consistent in depending on their respective config
> options even when CONFIG_DEV_PAGEMAP_OPS is enabled for other reasons.
> This allows a little more compile-time optimisation as well as the
> conceptual and cosmetic cleanup.
> 
> Suggested-by: Jerome Glisse <jglisse@redhat.com>
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

