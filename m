Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56BDEC7618E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 10:42:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24F5621655
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 10:42:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24F5621655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B44AF6B0003; Tue, 23 Jul 2019 06:42:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF5A66B0005; Tue, 23 Jul 2019 06:42:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E3968E0002; Tue, 23 Jul 2019 06:42:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7986B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:42:49 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x1so36042001qkn.6
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 03:42:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=N4xK5veZG09uUkAaPdHZto+xy99VCECeBtRkb6sAB/w=;
        b=Ur26KVf4yA9JJaGeGVT39R2rXgujsiX6USXXCx3VmKMTrIIb+apsLFkf4f9YxkUeCm
         LTE0MIn+TMA4bkLMgM+0IMPmo38HnezHNvaz7vXsD/CAtbjpexY+DB/KH3rCfgACrLs5
         TFL4E8Q//wEDRxqcq0o/v0qL+P1wIRND11mM9mweDubbmFMwqcMHaPfTXGQbPloa76Gh
         HPDfPi+JSSUrPv8LXaJoxtjpKxFiwYwnA7VMWMICAyY8m/EXkhb+uVpgyOrcX4LFpNrV
         wx6vcGNtWK7kuBf2DS7wFrjVsuQa6B37jEVQEBFwY3PoWgzaSLLfOaC3UsiJfq6SRePh
         I/4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXeel4g2QG2pJFgyVDFePGVClWZPiBI5LT4wjjKRECiTlqmuXYJ
	L+761dr8HAGJtm7icPVZa8UJE6loWLay0JI49J9JHsGOfXfRcA83qGoHoi8pTqVjwahcs6xlAXb
	Lq5SB6DFJZy9F+Y4bPPSDgcsjer0oKeypXwplWHMQbrHuH5B2/fY7SNo+LZwKJqyKcA==
X-Received: by 2002:ac8:3364:: with SMTP id u33mr54354891qta.115.1563878569301;
        Tue, 23 Jul 2019 03:42:49 -0700 (PDT)
X-Received: by 2002:ac8:3364:: with SMTP id u33mr54354847qta.115.1563878568552;
        Tue, 23 Jul 2019 03:42:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563878568; cv=none;
        d=google.com; s=arc-20160816;
        b=btjPOM4fEaD490hsNJOd2WrtORyPCVRom5tJf8YFG2KnEdDRHoqvHb43e45ryKcNF2
         EQ5dvgcWRZPfnUbVJbbjdZIPKuQX8HP59igeyId6cBxnYqYYaG5vXcW3oinup/zqgI2L
         4Uydbee2M4U+nsLjHHnzZvLdWIKkHt9SNwCbXxyjQOROR1Bozniw19k1zQY1DvhtJf4F
         JKtA8oldbiAW/UebdXEd4k3gkBJLfuMDzbCZ/u8LgHGCBhtzKqjrQweNo6JURsUchoD1
         thGFd0wsb95o6PAURzrG10xDWdkfAOIOC77rgBgzXHkjphF0raqIiBCNF9FR7E5YwcA3
         3DCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=N4xK5veZG09uUkAaPdHZto+xy99VCECeBtRkb6sAB/w=;
        b=VvzkKoAgbTgdj1+K8vgDS4AAsrINVGtbBOn3QNY2GA3mpLDi1UtJtX3tLczA8E5h2X
         V5zWoKywOgOGweJGLlAl2HEGKeBJDOz4pSls+9gFzfBzzZyGQBkQg+/OVFQVZWggwk50
         KjGNe7MiHQLVztYfEgoc8Mgl/ruf/kVFb1DiWhufdSdswBKV/tSpi+pRYnVJ7V9ErTij
         M2JXA4yNQXmSMEwFrmaQ6EiB1NgMiJ9LPxlZnfkWU8PvL3TLhQunXT+J141LK+FtjEnY
         QAzoLSzLcJi+jO0LNOE/7d39w5AuPYQ2xZ0SRyOROr8qHoUmRH1lkIPBnvCF1YS42CYA
         xZIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i47sor36095996qvi.54.2019.07.23.03.42.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 03:42:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyaExRlYw/QlDd/NWuqasay2jAYk3JOBnWzJfjESy3cklpZQkiKPy3zfhsnVUYaS/Q/QI1fjQ==
X-Received: by 2002:a0c:d4d0:: with SMTP id y16mr52541534qvh.191.1563878568268;
        Tue, 23 Jul 2019 03:42:48 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id b7sm18536990qtt.38.2019.07.23.03.42.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 03:42:47 -0700 (PDT)
Date: Tue, 23 Jul 2019 06:42:38 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jglisse@redhat.com,
	keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190723062842-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
 <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 04:42:19PM +0800, Jason Wang wrote:
> > So how about this: do exactly what you propose but as a 2 patch series:
> > start with the slow safe patch, and add then return uaddr optimizations
> > on top. We can then more easily reason about whether they are safe.
> 
> 
> If you stick, I can do this.

So I definitely don't insist but I'd like us to get back to where
we know existing code is very safe (if not super fast) and
optimizing from there.  Bugs happen but I'd like to see a bisect
giving us "oh it's because of XYZ optimization" and not the
general "it's somewhere within this driver" that we are getting
now.

Maybe the way to do this is to revert for this release cycle
and target the next one. What do you think?

-- 
MST

