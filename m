Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E368FC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 17:00:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC3EE20815
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 17:00:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC3EE20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54C986B0005; Thu, 16 May 2019 13:00:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52A616B0006; Thu, 16 May 2019 13:00:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EAD66B0007; Thu, 16 May 2019 13:00:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06A306B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 13:00:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r20so6216638edp.17
        for <linux-mm@kvack.org>; Thu, 16 May 2019 10:00:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=qnP8DXdnAI8r0utqzxoUpU/7eSgQlDA+ZQxN0RGd3jc=;
        b=b+n2s9fOKbFl7+hrJGldkVjtqcdRuOdWym6kzFL+WcS1ozPRLePwb8rFX7AqcMIeEf
         qYzRW+s2SJSucZdazOH/ZZL+PtJ30/uzEMcNsSsmIMkJnype1QqS3h1s18IqXlDg518b
         kiXrWHeaicV9YYMI2LsDfHJJagIcrQI03aD0x/cW6C+QXN8f+0xAXIMc/X45pxPpDV+N
         qXiVb5iKClNvQDf38Hq4oPbeycQf/Y0zuMTwDMhCVOS+/sIiFDt0Nr0YPWQwTOt9HtNa
         0pAq7dLzPdrztp6xH/1Jkack7iGgDbeF5SZV/v5LcLE9j1g/rXrRqXvm52coyn/oFj4g
         U/5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAXjdVa0yav6AV/QvJsJDIhvTibfv6VI+oiUfVjR9X0cGq6HVcgI
	AugrBOOcxMBh0abeRy8a6urE85hg3w+G5XG0orsE14rOaVEhArrsYxa0Kiq4L26qJpylf4AmiJq
	Hz8R1mCYvIhDxEUN6DW2GDqyRPZ4mrBNHemTVMVoBAbyrP3r2ss/3A0/GBetMY/+oYA==
X-Received: by 2002:a50:8684:: with SMTP id r4mr51664682eda.98.1558026039388;
        Thu, 16 May 2019 10:00:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9mz/NSQhjYcu1ILhTHY2Eje54WMdSuc4eQZrSq46GWo365ba4QPkZ5MTiTwrRbutPSLHK
X-Received: by 2002:a50:8684:: with SMTP id r4mr51664427eda.98.1558026037692;
        Thu, 16 May 2019 10:00:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558026037; cv=none;
        d=google.com; s=arc-20160816;
        b=iBRnT9N+iQ21KCrnuTGSJU4HHdxZ84P531wEt0pXL2QmE6Y4rTSPD8+yWFAt1rCSjt
         GJOZhINKQqtIPmUcH2PGrcekhvKEXn6/tew6vCI158kgjidlh5daJl8tMxM78h2Sk2dh
         QUdeFTPZZES4JVoEHHwp5VDGICV87rBrp1e+p2ciJJLbwVST/WjVa9wzvwy9uV2+UYcd
         MY4+Z8TOBsjQwhmJs2inK0h3ouQrWtwHYaVy6z08nOtrjWlSaU8GFKoKxZpDIL795V3f
         T6JGOqp55tJNrGfSPHgy9QZ406gL7sK2QbWnU9R7V0epmWKpGC78BitmqWQVd72OXciZ
         +k5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=qnP8DXdnAI8r0utqzxoUpU/7eSgQlDA+ZQxN0RGd3jc=;
        b=yZlDtuOjlz9kov/zk7JxGg3Ee5zocuKdY4H31jQQnoSwr+xBuicnO6ACFNyWTVwOPW
         M7pk6vJmYWE78UjHTPqnxYyrTVDe3mUJM9dggBQSiP9zJPc01vzsijcmZyQCi6+2E5Cl
         LMXFzbVoeiyxPeEdSt68g9SD5d0jm0KDsYIYkSURfvczG/CMdTjoLwEhvsZvVBmcMzcq
         icOw/C1ofqNDuC0GePHjiaj6mPggy2l3+TMH6DmKmxwxMFqPmTleVNW3lt5lzKMbRzEB
         T1KnNbZN9x1Oh0FYcd1CVVDucFWh/liJ3ClzIJUg9uSd1PZ0Pr8ys7eqYtILPHnon2Xf
         /sLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t20si1046818edb.127.2019.05.16.10.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 10:00:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B3E93AD0A;
	Thu, 16 May 2019 17:00:36 +0000 (UTC)
Date: Thu, 16 May 2019 19:00:35 +0200
From: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: mkoutny@suse.cz, linux-mm@kvack.org, akpm@linux-foundation.org,
	oleg@redhat.com, linux-kernel@vger.kernel.org
Subject: Re: mm: use down_read_killable for locking mmap_sem in
 access_remote_vm
Message-ID: <20190516170034.GO13687@blackbody.suse.cz>
References: <20190515083825.GJ13687@blackbody.suse.cz>
 <11ee83c8-5f0f-0950-a588-037bdcf9084e@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <11ee83c8-5f0f-0950-a588-037bdcf9084e@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, May 15, 2019 at 11:48:32AM +0300, Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
> This function ignores any error like reading from unmapped area and
> returns only size of successful transfer. It never returned any error codes.
This is a point I missed. Hence no need to adjust consumers of
__access_remote_vm() (they won't actually handle -EINTR correctly w/out
further changes). This beats my original idea with simplicity.


Reviewed-by: Michal Koutný <mkoutny@suse.com>

Michal

