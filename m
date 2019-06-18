Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D509FC46477
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:57:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7BCF21479
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:57:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7BCF21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C6F36B0005; Tue, 18 Jun 2019 10:57:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 150798E0002; Tue, 18 Jun 2019 10:57:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 016E78E0001; Tue, 18 Jun 2019 10:57:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3E5E6B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 10:57:57 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so21649648eds.14
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 07:57:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IrRkQLiiPOjM5QQUnELNR5Xw7wGDbfE12JYr/2t1OS0=;
        b=nl7gsma9nAMag3G5ezBXZVizx43LQalat8lMk+H/HCdI2HaQOsTYZ5R1fN/udmwjVs
         SCqdLKiFJs0bIHGcxoWTHqgnBYAkI+TsFLjP21Htj1egoGsMTiWJvzZmednieV0GqdIk
         4jSGXI09Q1puArTIBoVj/IgFhas1DSy7RRfOrVeBp5FrNvF44vo3yaFxNRpiNijeHVuV
         IpeozbVHp7Eok0PAVcVN7MEfH7rqN2pFnCBFHEGm2dnKepZXftU5PwlYrG3zkln/Wdvk
         ARuYcrA9fB4RIdFySrOb4JcPegsJSiptNvsL9Hkrl6T8W0EBokMx9roEnskRQM7lQAJe
         xJKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWuVKUJ3S8KGBsv9uA2Jf4qc9t3MfMmI3jhqid3OmGL2orZdTUl
	3V8/1gMeTZ+Wiou7WRFJNjOW27rUJcsymXTY+ofkmPKy1xA9tsOj4SGtL1uvmHURRzuzNilzsLL
	aPoi2X9KulUYPgThP4RyKYef4iFa/gdHK7M2vrcU3e5baIt1Qo7FyoyRufPSfQg2Iog==
X-Received: by 2002:a50:86dc:: with SMTP id 28mr98483968edu.132.1560869877224;
        Tue, 18 Jun 2019 07:57:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxI1AD5KQ0DhAz1FYwJrfP3/VVUQuQPa35BtjJzx44xKh3WCMy3VSHvbbM0qiZXTI8VKNlk
X-Received: by 2002:a50:86dc:: with SMTP id 28mr98483913edu.132.1560869876478;
        Tue, 18 Jun 2019 07:57:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560869876; cv=none;
        d=google.com; s=arc-20160816;
        b=D0poV2uOZ4BlCnu+ZU88s2jcZtlm3vynFu+1XJgHQ7NchciBzjjR6/p4Bu/EL2nAlp
         FAmJ4jGNoCyTndnA43rnDuc5LGbcGIsUT9pnwtwKOfJyIb4lx+GLs7hz5D21kOB8bvvr
         y34/DcqB61XVszlUWckd1Dbh93dTAHlAaiNf+wii0rQqMpVWGYveJ3b4PHxv60Ck/rZk
         B5u08uiwDH9eIXByL109vkO0joPP+oB2uMhe0fPJ/id+jSc2alTWieUoXcMC/aS/dmm3
         nO89SqpmfIvDRCNUH4YncrCoSm4bVXHsoIJg75rhwQN2m6iZjftNeoDrYAMLxhF5L5ai
         S8AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IrRkQLiiPOjM5QQUnELNR5Xw7wGDbfE12JYr/2t1OS0=;
        b=kjJIz73ZZ5otZpxZ+sm7OYjeaC5ee7irXJIVV1HcGowbgbfWxTtG3Jv92RL0w7mAEW
         fLuUYoxLEMECmK2DGj0Ylz8ihgEyNbTSyxNUClC2g/JWJeB+mM5aaB0jpVhH0S6aVDA0
         Ak+wBvKW1yFQlEv8atfv7Z5+LaNliCs66MSlrk8tjF2cfOhrwPPh1VDiKUJMsV/RrwL6
         OxJEY9WpHYP/s6343xOy1fMQawHANt1wM/y1RXu9x0C7MqzYgSMGxjr1mtiqVlTkVfTZ
         EFBEN5NCEyjCT6TTtbMWgR00TD0pkfSEcAaWvRISRUmZrCzwWF40Svou+efCMPNmOlk2
         FD2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t48si10694195edb.29.2019.06.18.07.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 07:57:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B2F8EAD81;
	Tue, 18 Jun 2019 14:57:55 +0000 (UTC)
Date: Tue, 18 Jun 2019 16:57:52 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	xishi.qiuxishi@alibaba-inc.com,
	"Chen, Jerry T" <jerry.t.chen@intel.com>,
	"Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>, linux-kernel@vger.kernel.org,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH v3 1/2] mm: soft-offline: return -EBUSY if
 set_hwpoison_free_buddy_page() fails
Message-ID: <20190618145748.GA14817@linux>
References: <1560761476-4651-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560761476-4651-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560761476-4651-2-git-send-email-n-horiguchi@ah.jp.nec.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 05:51:15PM +0900, Naoya Horiguchi wrote:
> The pass/fail of soft offline should be judged by checking whether the
> raw error page was finally contained or not (i.e. the result of
> set_hwpoison_free_buddy_page()), but current code do not work like that.
> So this patch is suggesting to fix it.
> 
> Without this fix, there are cases where madvise(MADV_SOFT_OFFLINE) may
> not offline the original page and will not return an error.  It might
> lead us to misjudge the test result when set_hwpoison_free_buddy_page()
> actually fails.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
> Cc: <stable@vger.kernel.org> # v4.19+

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
> ChangeLog v2->v3:
> - update patch description to clarify user visible change
> ---
>  mm/memory-failure.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git v5.2-rc4/mm/memory-failure.c v5.2-rc4_patched/mm/memory-failure.c
> index 8da0334..8ee7b16 100644
> --- v5.2-rc4/mm/memory-failure.c
> +++ v5.2-rc4_patched/mm/memory-failure.c
> @@ -1730,6 +1730,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  		if (!ret) {
>  			if (set_hwpoison_free_buddy_page(page))
>  				num_poisoned_pages_inc();
> +			else
> +				ret = -EBUSY;
>  		}
>  	}
>  	return ret;
> -- 
> 2.7.0
> 

-- 
Oscar Salvador
SUSE L3

