Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 994EBC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 09:03:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4929A20657
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 09:03:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4929A20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B98066B0007; Tue, 11 Jun 2019 05:03:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B479F6B0008; Tue, 11 Jun 2019 05:03:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A37BA6B000A; Tue, 11 Jun 2019 05:03:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 540426B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:03:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so19677724edc.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 02:03:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Y68IYd+puRrRM8+dCrR6+0OU7Ugl5tCsbkQvIaCUI08=;
        b=N+zlFFalKByhQ9a8n6Ds/MPm66BUOJVc1Wa2BzC7GbJeFcK7QSjsvVBY5oOndsrgar
         r9dRyNN/eiOL6uFWAYZ1w7MDeLeHK3VRcQvIUm6Rwwa2BgIgIWUYDypplI/MYAdE4OnC
         6KyR+O6vuLvKpdieADVnvdrJRABogI42xH+lsTiuci3ENtUeZeC/TJRnSsPyNAzfFFZ+
         0oKf767WLC2bSOVCofwFtIHbCejU9A24iYLzEU2QNNQLi1ajfXkQlApbnHROgBUgaY7M
         uKVTrxqTuwvw+6zzsNIuvH7QRPWPti3mS23TXD00FFjc1ICvpjvXDf1D1K4DRPVnBkN9
         ZkqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.16 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVNW7RbXqQ+upJnZ4Bmgnj/YTWxgkQxU7h83C6NyvHK8H151r87
	lgxCwVujlnd2VCNPMGl3X9pSit5ts/+AFy+gHXWW+wbkY6qUcbXjmoI0CDZkeXhKSsVak/9afST
	s0o8yHvnGxTbl1+gPqDGti4NMMmy4vrLRatF4coHOdwfJiwzb0ZWlpXLnHcKGLZa3Vg==
X-Received: by 2002:aa7:c98c:: with SMTP id c12mr16008608edt.225.1560243827918;
        Tue, 11 Jun 2019 02:03:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlOWF+e2p4RbPBWgACkT1gswtvpbb7SmGyzyVs1LIbwurDYrlSNIBsypuViq0394k/8ENz
X-Received: by 2002:aa7:c98c:: with SMTP id c12mr16008540edt.225.1560243827152;
        Tue, 11 Jun 2019 02:03:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560243827; cv=none;
        d=google.com; s=arc-20160816;
        b=OCozllpTVxrHDu52/szAA7GRosx+O0Q1/jPrjs1x56kHeMDbNDlLYyDwPCNZK4x5h4
         xw1aDHTfao2M2A0CISUC8VAw438UxKiA41M5rqFmziZgsGeNJrGXRbkQjmbvnLRnK3rv
         Qaz6jvTiOKvGdH4PCaPE0DgUxx7s5Z3XHvGbMJd2tOXil0K95sl388mHF8/zdN8XqR1t
         Qi0YxJDBKwmtFUflyknhO5ZfWgI8DpDE1y69X6hiDqexpPEugxR/V/HYlTR4YvcwLwnT
         +zGOVFHqzEDS+szSs/e8ubJ+12vO/clg1jUU3sajp1d59rD5hap7x1/dXcEkgpYwbaWu
         XI1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Y68IYd+puRrRM8+dCrR6+0OU7Ugl5tCsbkQvIaCUI08=;
        b=xfhXkiivSn4MwrW5y4ub4dhA/2JbgOx37dFe7q5C8ffZBrUZ0wxVCgmkiC37NxWwzW
         XdoTs7A2c064xFjHwWlbPld1LiddUDwiBSq4OkRrL3NusJt/wuU+MaSdSuiB0dBxCtNw
         760nhq//K3ihtgwg2xMlAvMPf9tTRKdN6gbY3ERSso06LqAlxK2eThAUG6pXCjIlz0pi
         YpuH9OW/1pD3D5X7Iuvaht2GCkJOLQOS5tFSD9ZhOyqzCoJP57IT/+4neq147AMRUo42
         SBg6kvaza6QmstiKfLQIza+hqAb+J945c+4tIpNefJrHbTOdJoduz00Oc5v7fEnDrplI
         kO3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.16 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id n13si9666197edn.373.2019.06.11.02.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 02:03:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.16 as permitted sender) client-ip=81.17.249.16;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.16 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id D08FA98B0E
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 09:03:46 +0000 (UTC)
Received: (qmail 4067 invoked from network); 11 Jun 2019 09:03:46 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 11 Jun 2019 09:03:46 -0000
Date: Tue, 11 Jun 2019 10:03:45 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: balducci@units.it
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org
Subject: Re: [Bug 203715] New: BUG: unable to handle kernel NULL pointer
 dereference under stress (possibly related to
 https://lkml.org/lkml/2019/5/24/292 ?)
Message-ID: <20190611090345.GC28744@techsingularity.net>
References: <20190605172136.GC4626@techsingularity.net>
 <27679.1559827273@dschgrazlin2.units.it>
 <20190606142600.GA2782@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190606142600.GA2782@techsingularity.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 03:44:24PM +0100, Mel Gorman wrote:
> > (I applied the patch on top of e577c8b64d58fe307ea4d5149d31615df2d90861,
> > right?)
> 
> Please try the following on top of 5.2-rc3
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9e1b9acb116b..69f4ddfddfa4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -277,8 +277,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
>  	}
>  
>  	/* Ensure the end of the pageblock or zone is online and valid */
> -	block_pfn += pageblock_nr_pages;
> -	block_pfn = min(block_pfn, zone_end_pfn(zone) - 1);
> +	block_pfn = min(pageblock_end_pfn(block_pfn), zone_end_pfn(zone) - 1);
>  	end_page = pfn_to_online_page(block_pfn);
>  	if (!end_page)
>  		return false;
> @@ -289,7 +288,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
>  	 * is necessary for the block to be a migration source/target.
>  	 */
>  	do {
> -		if (pfn_valid_within(pfn)) {
> +		if (pfn_valid(pfn)) {
>  			if (check_source && PageLRU(page)) {
>  				clear_pageblock_skip(page);
>  				return true;

Any news with this patch?

-- 
Mel Gorman
SUSE Labs

