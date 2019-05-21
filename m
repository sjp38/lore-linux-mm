Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1148C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:11:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B33272173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:11:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B33272173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B44A6B0006; Tue, 21 May 2019 12:11:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5667D6B0007; Tue, 21 May 2019 12:11:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A27F6B0008; Tue, 21 May 2019 12:11:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1778F6B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:11:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e21so31373183edr.18
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:11:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5/i/kr8EFjFeA/wEh2rz1tJq6M0y92KA3xDD1zmtX7k=;
        b=Bj3GMAY9MuvjUB/XI5FEGz3BFlsNMEWY8kwy7xGOvQn7dwBJMHct3bJNS3+YUyfUJw
         vhVqW26pqv1GHc/aQcCIgkLeBt44GZVPSTui9UyQahgYFbf82eTwHXn3s2X4VMqJy+cr
         mbC0mnin532kRH/Db0rIxqDu1KF1Q7A8BO+2mE0LaModgqVNDRsbsSrGLd8e58lzOBaf
         vQ8t+1K6qjw1c90WUMHuitcyrJAgnk+RiBIYN7wCWNlInyS1I+khQ1JQsL4kss825Mgw
         4yNhYBnBuRHM6rRnVnUPQU88hFK+2jpZgVNMB9ieCeqrkMnX9zgPxKELlpefmk9QearZ
         SgeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUsF8G4JYNJiC6JZSgwa5PnTJO9kZgqfLwpJZ110gb7a7rWfvVS
	kCXb+L/Wqlt8zk8cdlymBKIYOE0QcAqMiAaG005ZKt/+TMUe47O0v1AM+8lIo0EvgdLdUVv6AzJ
	J8EVd0Mn3pAb6gd0xen8r8Nq3nn/KOGbCAPExPBq6tAsmHb6rQevuyiALaEkmnroM0w==
X-Received: by 2002:a50:9435:: with SMTP id p50mr84579191eda.40.1558455069622;
        Tue, 21 May 2019 09:11:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTCUwxTuOOgfNschr+iH8aYaMKhpxHW2By5eFLR1Vk3mx3SWibddxqIh6EopTzSw6Q93RN
X-Received: by 2002:a50:9435:: with SMTP id p50mr84579089eda.40.1558455068807;
        Tue, 21 May 2019 09:11:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558455068; cv=none;
        d=google.com; s=arc-20160816;
        b=hAcEtGnSqmXlLvaCtisvyttD9Z3NNZ4xOKuRedfHK5VWKskrjAhtdzO5t9Z1ekUBzK
         w3nMsKFhP9naok1C084Qq1t34Z6MuTcoy7fO/PUdwrbO5L+GLmCPebLOwCLtLyti49dG
         VN3ZRm4Re/6yxhRZ0IEvFpOfoxPMnK8Znkzslnl6re7ppOpG0K0JboAtzB8timTN3l7+
         ngsybP9bC2tFCGc3Rn7qqhjyrD2/zen2emOcCcP8OQTHgk38a3qNA2EkFXB+tUPgDYNX
         ci9lW4IeqFYIowcP82QPvjarxJOXmjgisfjzSncVgKI2Z3+zMdWuk+IWQxk310CM8Hn5
         Fsvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5/i/kr8EFjFeA/wEh2rz1tJq6M0y92KA3xDD1zmtX7k=;
        b=nq0BuESVsaU14YhSynmEw11C1EqWuhC/6ItsDBZs9V4h45BtixUIqIt19K0nX9Z90j
         KKub56aygo4MuKdf9EB9wS0AIGBUSDEfCijjPbt61P8DfnN0y7Fcqc1D7mSHq1OotweE
         EtRrB4kcqjCYuzsL8eTWEnBiBkI9/BnaJt0/1lQZBc+AYpyEu1IWxa3OF+FTcNw0PJ6c
         OFwThrTW0iYBbOgr3hPykbMbVwemQUqCK740zWXKrm6ZvLxkoKi/pTr1OE8SwdNDUXof
         ea5bso9l2zxo93YD6R/QrXIKaKr7uhcQOL8w3Qq5IlqFmFDCBwY14U3DW/RZm+rDvlf7
         cx3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b51si1206706edc.153.2019.05.21.09.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 09:11:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D22D7ADE1;
	Tue, 21 May 2019 16:11:07 +0000 (UTC)
Date: Tue, 21 May 2019 18:11:05 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Jonathan Corbet <corbet@lwn.net>,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] docs: reorder memory-hotplug documentation
Message-ID: <20190521161101.GA2372@linux>
References: <1557822213-19058-1-git-send-email-rppt@linux.ibm.com>
 <43092504-a95f-374d-f3db-b961dd8ac428@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43092504-a95f-374d-f3db-b961dd8ac428@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 12:41:50PM +0200, David Hildenbrand wrote:
> > +Future Work
> > +===========
> > +
> > +  - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
> > +    sysctl or new control file.
> 
> ... that already works if I am not completely missing the point here

It does.

> > +  - support HugeTLB page migration and offlining.
> 
> ... I remember that Oscar was doing something in that area, Oscar?

Yes, in general offlinining on hugetlb pages was already working, but we did not
allow to offline 1GB-hugetlb pages on x86_64.
I removed that limitation with
("commit: 10eeadf3045c mm,memory_hotplug: unlock 1GB-hugetlb on x86_64") , so now
offlining on hugetlb pages should be fully operative.

> I'd vote for removing the future work part, this is pretty outdated.

Instead of removing it, I would rather make it consistent with the present.
E.g:

- Move page handling from memory-hotremove to offline stage
- Enable a way to allocate vmemmap pages from hot-added memory
etc.


-- 
Oscar Salvador
SUSE L3

