Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A9CDC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 07:24:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2BF22086D
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 07:24:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2BF22086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 467FE6B0008; Tue, 11 Jun 2019 03:24:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 418426B000A; Tue, 11 Jun 2019 03:24:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E03D6B000C; Tue, 11 Jun 2019 03:24:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 138176B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 03:24:28 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o4so10162872qko.8
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 00:24:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=Chqn/2tQLJnYU0wO6ILZVGDh9Ia2h1s7kcE6+jvBc1E=;
        b=Wi534TsAGmhd3bA02MQ2a03QAUs3PBwbFqoWkCtFb2NDRGZYLEl6g+X4zzz2KHxrna
         R/bHEpeVXak1Em/pb/E10pvR12RLWn37qFxg5ta1OTkyEoddrJ+M4xvqCeAQluQaSk37
         dch40Wax2GE6u40l/Xr3zbwz5wcECirWL7aDgLBZJpaS4SRwCaBGTAQajztKMMqek/W7
         0WHZw3mu6ntaoKG1YEw4EpeHpGBGdBJrN5Uce1c9oO1ZnUD2Wq+w/N0Uvum8uHsfJjwb
         sU5phK6BhphGfScb08ssXgYZNyh5y3DRqrbSHMeEZYFKzhoOIipeBNxvNldtnoMRXDDX
         GIKQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWo86i4B45AMEq4k/ShEZwtb4bRr46wT5XhyYLbbkwrURRDnXdQ
	vf08GKlouQLgtz0OJrTbir8i/IwxE++eOUsmUPZHkg2oUUuDXRAktKodTUrJ9Z+utav8/hBtbmv
	GrJuuKqWWU2DywBN46TI3rpkJ98Qos+52uvDRggjFVo7FV8dKcdn0vb7JZsMOUTt2rw==
X-Received: by 2002:ac8:2fce:: with SMTP id m14mr44236042qta.22.1560237867807;
        Tue, 11 Jun 2019 00:24:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHlw4m0g0/tvJxnR4rSP9fC1oBe/VteVjp6TSPPRsl+k2oxL9CObjITM2UWN2opRGgxMvt
X-Received: by 2002:ac8:2fce:: with SMTP id m14mr44236006qta.22.1560237867217;
        Tue, 11 Jun 2019 00:24:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560237867; cv=none;
        d=google.com; s=arc-20160816;
        b=bi8AvHf2+wAc8eV8j8f+4DBnks+K0wJ6xNhLxEH7NAeHkX5GH+7Qn/Dj9kDt8u6EQk
         E0s9lA8pgUON7Kuhf0ie2FfYxkBAgvP8mY+tEvZnMwv0C78IrbzSNaMNe5jA2aje4gRn
         jz1stdS10d9W8oH82gsMN0sQ2pjfy+zlCXNHaKDvjhQBC94rWQVXn18bVKzV4LKOWtlq
         UVM6WAhbRRaLqbZAzJybLBaWFqigUCl3nYdfF/wlGq7CV3J2maKfno1nCTqJQB0d7Qsg
         MP8Zk7CZ1aar+owmcGUXZetasbhuiyqJSu60Bx1E56ip8qhMV3YudwOiA7iJrVdUMNL/
         SaIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=Chqn/2tQLJnYU0wO6ILZVGDh9Ia2h1s7kcE6+jvBc1E=;
        b=yOTVMIEbC3E1fRShLYHeDe3dYckeXHvtAhvUeLWpC+NcVEf3bpjdk2FvUfi6+hf0Kr
         PPpzzOy61QOrYlwGitmNJz+t48hS8GefLp4UrCVSFd2bMlF5kszsH9S93FIgEhnfznUB
         2CEPCGRZpUHpqmosjkreg8ys/pnFU0Rvv0FqoNXxD4r1sq4yy2nH6/yUkTaaFEcrIArk
         qSiKFgTZMBenQD1ezNUSZcGJ/eQGs+zIop27ytn4KFcNrtG70Dixr4odyKfLvWTjNV8+
         aQilIBc5XjZgMuy6WmkrXgyhiukPVoHduTNzvGrLtAul0TJMva2O3s522+XK4RoRd9Es
         yUlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 52si876924qto.14.2019.06.11.00.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 00:24:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 425D6C18B2F3;
	Tue, 11 Jun 2019 07:24:20 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (ovpn-116-118.ams2.redhat.com [10.36.116.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4F4B05D721;
	Tue, 11 Jun 2019 07:24:04 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>,  Andy Lutomirski
 <luto@amacapital.net>,  Peter Zijlstra <peterz@infradead.org>,
  x86@kernel.org,  "H. Peter Anvin" <hpa@zytor.com>,  Thomas Gleixner
 <tglx@linutronix.de>,  Ingo Molnar <mingo@redhat.com>,
  linux-kernel@vger.kernel.org,  linux-doc@vger.kernel.org,
  linux-mm@kvack.org,  linux-arch@vger.kernel.org,
  linux-api@vger.kernel.org,  Arnd Bergmann <arnd@arndb.de>,  Balbir Singh
 <bsingharora@gmail.com>,  Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>,  Dave Hansen <dave.hansen@linux.intel.com>,  Eugene
 Syromiatnikov <esyr@redhat.com>,  "H.J. Lu" <hjl.tools@gmail.com>,  Jann
 Horn <jannh@google.com>,  Jonathan Corbet <corbet@lwn.net>,  Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>,  Oleg Nesterov <oleg@redhat.com>,  Pavel
 Machek <pavel@ucw.cz>,  Randy Dunlap <rdunlap@infradead.org>,  "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	<20190606200926.4029-4-yu-cheng.yu@intel.com>
	<20190607080832.GT3419@hirez.programming.kicks-ass.net>
	<aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	<20190607174336.GM3436@hirez.programming.kicks-ass.net>
	<b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	<34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	<7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
	<25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net>
	<e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
	<3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com>
	<5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
	<0665416d-9999-b394-df17-f2a5e1408130@intel.com>
	<5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
	<ac9a20a6-170a-694e-beeb-605a17195034@intel.com>
	<328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
	<92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com>
Date: Tue, 11 Jun 2019 09:24:03 +0200
In-Reply-To: <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com> (Dave Hansen's
	message of "Mon, 10 Jun 2019 15:02:45 -0700")
Message-ID: <8736kgd1po.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 11 Jun 2019 07:24:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Dave Hansen:

> My assumption has always been that these large, potentially sparse
> hardware tables *must* be mmap()'d with MAP_NORESERVE specified.  That
> should keep them from being problematic with respect to overcommit.

MAP_NORESERVE pages still count towards the commit limit.  The flag only
disables checks at allocation time, for this particular allocation.  (At
least this was the behavior the last time I looked into this, I
believe.)

Not sure if this makes a difference here.

Thanks,
Florian

