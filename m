Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6A25C43612
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 08:18:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADCD620657
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 08:18:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADCD620657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E1A18E0004; Thu, 17 Jan 2019 03:18:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4679E8E0002; Thu, 17 Jan 2019 03:18:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 331468E0004; Thu, 17 Jan 2019 03:18:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C99438E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:18:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so3372778edz.15
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 00:18:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=fkFWXCAMcSgRqw41+6eOQdS3uu82j0R4MK/GEu9OYIY=;
        b=kBCW/z4twmynPj5AZQbFc/LD6NsGkyqyMvAjcUEmW54jjAsg0epn4fkXPNAyNMkk8c
         sLJXnMamV9SxfsAYu1qjNwCqe5W9tzy9ct60m+VFBxASh0W1vqGo0usW+uhmc4i5f8hL
         PUG0jt04RRF6IJyCoVx/BAjHuEapc3UPqUspzBgaJ6dykteZQvGx5f9G7/Zi0cN6JgyU
         uUYMpVar/L1A2hMN4s5oCEoU4RHcEyZjpvLJxMlxKp1U9ez7I2v1pmAlRwYxpZGK7M9q
         m7BZBA6rHqGXHBByJHILhsrXtWJzOQ748PKGBkWXPmJ5/PiSejnDbDHBO5jtaOFjweIA
         UaGQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcmumQXuxuGI99ynk3ZXXi7T/7Y0Hjy0aPzcU6BxHtCnYWEg8Cm
	hEAZOpvVnua4F2EPHpFJn0LduoYMUIIYfcnuXpxVkIoDKrsxQimxAwo0uDdyCsJ4Q2306sil+7h
	maMRD9nRBT/LwCltIVFjXOBXi5HETXv4mOr7+CXXgJRScsoQcVmPn+LpCNg6RCas=
X-Received: by 2002:a50:e610:: with SMTP id y16mr10712629edm.163.1547713125333;
        Thu, 17 Jan 2019 00:18:45 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4wEzKf/n5DpmwVkvYeWiwmghaYS3joyixv8M5I4qzXk1Ar6N6aTXezs7EM/FE8ulFZai77
X-Received: by 2002:a50:e610:: with SMTP id y16mr10712561edm.163.1547713123992;
        Thu, 17 Jan 2019 00:18:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547713123; cv=none;
        d=google.com; s=arc-20160816;
        b=X0MoPMd/38s9bWuLsbXWsdJrGWXbHxTuvssD7g3itmzgve0Wbt1QC5NL04HREomQyb
         HBBAKPIk6JE6bDywBIUKN6dPOdqFTgBtvuYRS/L2oJuuUYr6SHG3scedbuV/PkLKaV6C
         y2+FIpBw+VyViJt3zZDO1C2RPW0qchDJ3r0v1fYYsOGv+mKquSyb78uuJuY5DIFeJgK6
         /WYfUOxpX887KjIfp21noFXcW/HJQ2QmUjHyCncrerHmKLc0IUwFnJuK9Fit5N3ft4tk
         pwG3SAaSDwndkxFOxNtDOZH6LszuQrSxO3nn1X4qzdmpE1FJMC1qU39x4FPicDQ7aLLk
         hVNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=fkFWXCAMcSgRqw41+6eOQdS3uu82j0R4MK/GEu9OYIY=;
        b=PSUcd+yIZ2AANHyejUd0RQ+0sYeHfFDNfXi/BZvhRyGW0EUaynl8ojOzkAZRdjrlzr
         eLsMhGpda0yUr4Zk3/QV+8RctDQSXb83Cex5pQeLAzzxCU32uf3bVmiUGgr9EKHVaJ0w
         V6nvncZ198z2TvdH6J2+IRvQfS3UkLZKZg2TvtH61fb/n3XPDJk6cEPocM709P0pKJ0d
         CIZfOSzLI3OXfoq+W7dazmNc1zwQAjTDzEpQtLlL4ttVxOvrP3GbvnStAW/49GnQqLq0
         /cNRyaFtHDh06WaciIVE0D2YTwQkIM735/TxoIZ/4x1CBADWoxZKc5kluz9OBd1AZ4xe
         9iUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l24si505628edr.135.2019.01.17.00.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 00:18:43 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4DD94AEE5;
	Thu, 17 Jan 2019 08:18:43 +0000 (UTC)
Date: Thu, 17 Jan 2019 09:18:41 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Dave Chinner <david@fromorbit.com>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190117022244.GV4205@dastard>
Message-ID: <nycvar.YFH.7.76.1901170917490.6626@cbobk.fhfr.pm>
References: <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com> <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com> <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm> <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com> <20190110004424.GH27534@dastard> <nycvar.YFH.7.76.1901110836110.6626@cbobk.fhfr.pm>
 <20190117022244.GV4205@dastard>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117081841.9z1MGkEmHif7BS7egUsLJoE-q-eglsU7Y3iE6XpWuwU@z>

On Thu, 17 Jan 2019, Dave Chinner wrote:

> > > commit e837eac23662afae603aaaef7c94bc839c1b8f67
> > > Author: Steve Lord <lord@sgi.com>
> > > Date:   Mon Mar 5 16:47:52 2001 +0000
> > > 
> > >     Add bounds checking for direct I/O, do the cache invalidation for
> > >     data coherency on direct I/O.
> > 
> > Out of curiosity, which repository is this from please? Even google 
> > doesn't seem to know about this SHA.
> 
> because oss.sgi.com is no longer with us, it's fallen out of all the
> search engines.  It was from the "archive/xfs-import.git" tree on
> oss.sgi.com:
> 
> https://web.archive.org/web/20120326044237/http://oss.sgi.com:80/cgi-bin/gitweb.cgi
> 
> but archive.org doesn't have a copy of the git tree. It contained
> the XFS history right back to the first Irix commit in 1993. Some of
> us still have copies of it sitting around....

For cases like this, would it be worth pushing it to git.kernel.org as an 
frozen historical reference archive?

Thanks,

-- 
Jiri Kosina
SUSE Labs

