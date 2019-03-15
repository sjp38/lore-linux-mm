Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6870DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 15:32:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B5E5218A1
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 15:32:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FHRD9vWV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B5E5218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CF0C6B0287; Fri, 15 Mar 2019 11:32:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82DB76B0288; Fri, 15 Mar 2019 11:32:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CF496B0289; Fri, 15 Mar 2019 11:32:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE916B0287
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 11:32:31 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id i3so8949945qtc.7
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 08:32:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=xOyGkdIrK5IPV/udnR6LhVtPVI2Wuv9tLtoha0to4pc=;
        b=JNiGOcjJIImqcvFLnq5aGzAkq+w2kVNKhmY8CT+GKXlwGiaTYAFvx8JodaIl4TBTvY
         SHpiitL0BgM/DZZVTwfzV7ganGlhmdyQHpYvBTSUu4KBAx/F5xAPrqmvWJQ3VoBv78Rw
         3c677OhqJZJtGBCwRBcM/ir0bsvJEazU9zpsoMU2g/T4Q05OIBlSwh3Jtq9/hvCwLN+I
         U0Wjvrsmjr3LKSUC70ypwynIADWfCFEI9kKsoHxqkcCcYi+HM1o+TU/Dc6XLpvwbZV6J
         xJES779Eez/zNWmasemDwgkZK0I5djkZ7Ku9s3g/e6GwJBhCLOxd8ICznR6ActmdrFMv
         Ix9Q==
X-Gm-Message-State: APjAAAWhwoWpVPoR/JgStxztgDWd1yO4UaguJ5HuX0tw6w2MS+0PCeJB
	nyNdHQkfn8DQBhEEqg46NL5paToXd2r/DCFjhliglH2/FxcSHCBYnkJBC1/rKSCulog1NhsjThQ
	rESDL4/Xb5+1UyvGuJJDO9tEAl4zoH2rjQ/yOad0g1i1szY51FiTjBEol3Zg/NUpwMg==
X-Received: by 2002:ac8:501:: with SMTP id u1mr3362873qtg.198.1552663951055;
        Fri, 15 Mar 2019 08:32:31 -0700 (PDT)
X-Received: by 2002:ac8:501:: with SMTP id u1mr3362826qtg.198.1552663950313;
        Fri, 15 Mar 2019 08:32:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552663950; cv=none;
        d=google.com; s=arc-20160816;
        b=jMS+z7f5Qmq5Tie6HI8w39AGq6geyGwC2yK4gNJxcdad8ES3MJ6+cu2M/4ZSvknKh+
         W2UI7zMZ7TYt4lUdTBZeVw/jxYpO+y9r0jHziLuXz700SdptF3utLdTuLrCPQVf9i0c3
         TUdAGVYBBDgdpFA3LI+MNBy0HqptoqAwecH1TC2v/gnVFSjz5okLPboWRB33xXSEmlA4
         LBNRq6T4371RW+sfgBraY6WtrEAcbRDHTrO2sFZ5q4Q5z0JoTP7OJy6QXOEpu2++ArhS
         V5GyrEky8PeF6tBEZX2H72BIWusxn9ItCfTSRYFAhCeqUXcVHdl/sY4tX6a87yNHHAmM
         V7yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=xOyGkdIrK5IPV/udnR6LhVtPVI2Wuv9tLtoha0to4pc=;
        b=dlVf2f0z+JMITjjynLJHKAqsGqdHnzujPx0YfsrdvqlSEj3eE+ZAMgzs+gzK1mnn87
         kFI+iYaLK1oipVG5kIhWTCCVSAM6r9/mhBfOyuToubmPiu5CzqAmUdO7WROb0mZUDCjd
         pO3gGwDy8f3YDs8XQghaL+lFe9MeZEb6L7BEA5+GTt1CCIW3zrwCNdgkSdsuDoXHz+F0
         1+wx2SFRPR+Uvcmiv96n/VCpI9lnmlK5mUgWukUCABHpsq7D8dOXNO4b5qcyThM2B3HV
         1P0JuHsOKBvmmcDpyrFV1xmJi6Vz0fVEhNxibvWaJV3ZAQ1h9xIwu12SMkNgEyoFr4Pc
         jysQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FHRD9vWV;
       spf=pass (google.com: domain of joelaf@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=joelaf@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r5sor1416033qkd.60.2019.03.15.08.32.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 08:32:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of joelaf@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FHRD9vWV;
       spf=pass (google.com: domain of joelaf@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=joelaf@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=xOyGkdIrK5IPV/udnR6LhVtPVI2Wuv9tLtoha0to4pc=;
        b=FHRD9vWVtXg5WbgPFPPZwOK5nExIOtLoWEkBTWXIKecp8HEBtnN4pZdIUAU8gyDagu
         e2RFLrGc1/tBw+8GujU+82SnI5qoblzht6Fe5/Fxng3QRQ4mVzRyl7gDbcEsX8VVBDs9
         0RLv9I5bBbE5LGjtSCqb4wddN8rzhFahfhEgsxf7Xc2MIhWOwLE0EuB+mcyljpTQ/pzx
         RL2PPSlT4j+y6iVeZb5zfAAwvi0LVN+XvYEHr+yI8kgOHBLyThscxB+9Im2RNjSdPYbG
         SMtzM2zZ0K9sbd5J49efk5U9ZHDOiliok6vLzpo2EHPS6Dv5PjzOiAo0rJV9qvRf/06l
         tTCA==
X-Google-Smtp-Source: APXvYqwBFQTwkimZ3+rDjQhLtxLYc3ohHHXCvdwBVE58Zte7LaU9eqxUhjk6CrgQ3qS6iUUFse9CRGKeFsHO6rxNUiE=
X-Received: by 2002:a37:d91c:: with SMTP id u28mr3190268qki.99.1552663949854;
 Fri, 15 Mar 2019 08:32:29 -0700 (PDT)
MIME-Version: 1.0
From: Joel Fernandes <joelaf@google.com>
Date: Fri, 15 Mar 2019 08:32:18 -0700
Message-ID: <CAJWu+ort=_YTh2B=y7iPuhFGVAP2joJugNrmgg3K0yun4uPFQQ@mail.gmail.com>
Subject: idle-page marking in page-types tool
To: Christian Hansen <chansen3@cisco.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christian,
I am looking into idle page tracking and noticed the page-types tool
in tools/vm/. It seems you are only marking pages as idle if the -f
option is passed ("Walk file address space").

I was curious why you decided do the marking of idle pages only for
files and not anonymous pages?
As doing in the following code:
        if (opt_mark_idle && opt_file)
                page_idle_fd = checked_open(SYS_KERNEL_MM_PAGE_IDLE, O_RDWR);

We mainly want to do idle page tracking for anonymous regions to
determine howmuch  of its anonymous memory is a process really using
actively.

But I was curious what was the reason you did it this way?

thanks,
 - Joel

