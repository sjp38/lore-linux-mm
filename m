Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67396C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 14:42:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ABFF20842
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 14:42:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ABFF20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CF1B8E0003; Tue,  5 Mar 2019 09:42:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7570A8E0001; Tue,  5 Mar 2019 09:42:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F97A8E0003; Tue,  5 Mar 2019 09:42:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F2C6C8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 09:42:37 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e46so4652292ede.9
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 06:42:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=caVisadCiuqASZTMOD21L6ubHMWWySvjVR4TqaafDbo=;
        b=JHUN0+Cy8LYbhTspnYN1hvBclLH4lpoDGn5ni3uB8+HS3RDyT7/W29xWquzfVFHYoZ
         ZXePrGLL6YATxoWP+3zdXJC6ODgLou0yg4QQj0Q4+PDK+eFheeAe3pa5bXqAIhyjrv9A
         sHj3ieSnOeLrU6ElWHDhHhXB3vMqzIykts9lcfVv0tD+SDZkdM+T7lI0CN9pKODqU9iF
         TKvic8UXiNkjdz1hAZXbPiL6C3TAWyP+Bx4kdySfhV5fxkXrAM5KmxtPNwSlFVXsjzlq
         kjCzG9CvFpNkKOza1IOJSjo/yUptjg9D3busmCrMR8TtYPWvppBVnv1g+Eik7phmbJMa
         Uz+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVYjqrM/8VRkbshTdr9NiYmEfRrpRSXeF47DXEByPBQ7gnMPALl
	QU9bZUFpOuNKUTWnm4/gm+DBeioJme9I8z7g4mnUhCZ3589UH+JFCMm1aq0r64fapOpqUApiqA1
	Hum7xxW9vUAQlDMgj9DFw/+qt0t4TL28zP/UpXOeyOyyIAvW9zvX3OkRXk9sGihLdBA==
X-Received: by 2002:a17:906:69c8:: with SMTP id g8mr479599ejs.75.1551796957418;
        Tue, 05 Mar 2019 06:42:37 -0800 (PST)
X-Google-Smtp-Source: APXvYqzsfuxkIuCo7EqrWLsuydp3cWWgAmu0uHluEvjXZRQGiYUUUrwyAIO4EajY+yYddPVNTbWo
X-Received: by 2002:a17:906:69c8:: with SMTP id g8mr479543ejs.75.1551796956330;
        Tue, 05 Mar 2019 06:42:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551796956; cv=none;
        d=google.com; s=arc-20160816;
        b=iQefD1+NUTS7f1H2gZ0GsnB7+PvQZddGaHlBc0oizGa/46DborKWnvkrEtp76OcwMI
         H6c77dYa/miam/hULi4uqwadWnvR44jKOU39F1dDzW8g6APDO2NawbsJfRXq7GltcbeC
         ryBwB4oE4YdkSZ0lL0KxaWCPGSVKYNKzv/uk+dpgS81BiIzfYiDDvAnW175WNqE3ZoTe
         EWuzkbjjjBL0UPzLrS3KbXU1IFVYR61NATy5Wy0OtC9xfX+DDvKCcmFURRWe4DG8SbZG
         ySgxlGE8YTNRvAQa9qxddYf/9ivAG8smtsZVqRbuYittFtH60bKbmFi1fZuxY+kIxOEx
         sBfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=caVisadCiuqASZTMOD21L6ubHMWWySvjVR4TqaafDbo=;
        b=vbkAitsQplqCZjD2+IeMgrbMXt3FkZd0QflgSgInEiGOTVS467+klP9sqSWjxctTLm
         IG8arVm8f4Hpbzy32E54lnVZ7KuxKx9oB4RO5vZRoLirCsyysaz3J2/4PKwVOOFmnW6c
         sJeT0LURcpH/SguwOX8zN8EfUn+2StPZShN3vHEokUllNeHsSmK18yKnrB0KAcgjrWhq
         xYAp6dsd98DRa6t364G5wOZ3jMhEmG2enoX3Sqib1RYfuYRwOGxv8S0rJRIn8GRqse1n
         ctz3F4YNnA0PmU/0I3/XKbJH8GK5+nPjPQANA7C9CUcDe6RzAUGAaY64kGPVUAOfw6di
         vssQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id k28si2532290edd.227.2019.03.05.06.42.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 06:42:36 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) client-ip=46.22.139.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id B96F21C27A1
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 14:42:35 +0000 (GMT)
Received: (qmail 23213 invoked from network); 5 Mar 2019 14:42:35 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 5 Mar 2019 14:42:35 -0000
Date: Tue, 5 Mar 2019 14:42:34 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Qian Cai <cai@lca.pw>
Cc: vbabka@suse.cz, Linux-MM <linux-mm@kvack.org>
Subject: Re: low-memory crash with patch "capture a page under direct
 compaction"
Message-ID: <20190305144234.GH9565@techsingularity.net>
References: <604a92ae-cbbb-7c34-f9aa-f7c08925bedf@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <604a92ae-cbbb-7c34-f9aa-f7c08925bedf@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 10:55:04PM -0500, Qian Cai wrote:
> Reverted the patches below from linux-next seems fixed a crash while running LTP
> oom01.
> 
> 915c005358c1 mm, compaction: Capture a page under direct compaction -fix
> e492a5711b67 mm, compaction: capture a page under direct compaction
> 
> Especially, just removed this chunk along seems fixed the problem.
> 
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -2227,10 +2227,10 @@ compact_zone(struct compact_control *cc, struct
> capture_control *capc)
>                 }
> 
>                 /* Stop if a page has been captured */
> -               if (capc && capc->page) {
> -                       ret = COMPACT_SUCCESS;
> -                       break;
> -               }
> 

It's hard to make sense of how this is connected to the bug. The
out-of-bounds warning would have required page flags to be corrupted
quite badly or maybe the use of an uninitialised page. How reproducible
has this been for you? I just ran the test 100 times with UBSAN and page
alloc debugging enabled and it completed correctly.

-- 
Mel Gorman
SUSE Labs

