Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7F4AC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:55:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2BB020881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:55:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2BB020881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6571B8E0003; Thu, 31 Jan 2019 14:55:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 604068E0001; Thu, 31 Jan 2019 14:55:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CE7D8E0003; Thu, 31 Jan 2019 14:55:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 055648E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:55:39 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id p4so2837941pgj.21
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:55:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=asfArH7nqCXWTRXX1DsBQXvzmYJcN03p8udwXQ78NS8=;
        b=ZGO7CP9w9yLb/t5ZJoeSkrm+DmxLDmPV3eSU56HPrnuNKAdc2KyykVA9Whpf3WSnMB
         aU5Ufmec2LO+9Z+7fbc8EOam6WgrU7kjU+qBodZphM5i9hK69xaRUf9ELGOSZdtRS7+0
         UYprNeHI7pJ7AY8dCWz+etHIb98jNVy0cip2WRCOls+/bNVs6ldsV4RMqAS+iYnAueRi
         A41sLPzTuZJSZm5QZcTiI3uNBAB5fgqNCKdp6Av+tcEo6TVQzZJzNptLoaET1+cXEKYc
         tVlewsTz3lMEMR7AV1NSf542T8PM9gQHzopj48Yw1N8CpZPn3H9NC5IXFSc0RMC0YvMv
         2Q4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukeuWOvnyBMTt1ZIgikrDH797u44vuaeX8di/Rkym7aOhezDIQzQ
	WnZo7c9rJQPrKyLT72q4h+oNHbwNGPXess7J5kYC9a8bOjjc1nsTdjukHs7zAxI5WRwQvVjLjN6
	uv2H9Tt/JHehcjubaoLPEgtOfXn6n1nX3ggtUxG9ywPhu6myPToTNccHp7IWZC728Yw==
X-Received: by 2002:a62:4641:: with SMTP id t62mr35770329pfa.141.1548964538631;
        Thu, 31 Jan 2019 11:55:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN41slTe5HbUkmxt69YWX1yL/wYy+pn05eVmeo5ejllAT46Twh2CkMxGxtR5sHcy9yOcKfWJ
X-Received: by 2002:a62:4641:: with SMTP id t62mr35770306pfa.141.1548964537954;
        Thu, 31 Jan 2019 11:55:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548964537; cv=none;
        d=google.com; s=arc-20160816;
        b=lVw+6MlojlkCg4B95jbDRowdO3t0DHWhsXdkUvwiryVIetor3pTf5npVRivyUdyToX
         jmlI4zf67vQc9eFsg1iExXpu3q2UEpps6JQG24uWC2bGME1Y+e1EovSfmea2uLz+16B/
         8KNCsM/D5bDyKOU1cWcpGEIo82FvwRT9osxtDmW24Gs0gkMKCD9Teci2e4JvYtsiRJX2
         l8DlGWcs4LYwwhvqenGAMbWFNGEmTRMvJTzwDhUCW7kxBep7E+PVRUYS5JsefN8oT9M1
         Q7WhJ+NUkkBlG/RWM2zEP+eCpa5ESkObxI9bjJ2+9T6nw+A36/KwrPnm8nbwMxVeb/qy
         mA8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=asfArH7nqCXWTRXX1DsBQXvzmYJcN03p8udwXQ78NS8=;
        b=QxbF4fNrUnhF4UshQ86b/Ue42jUDjSJI8F2sOklLqpbJGRMBLgLg5FfpFmfPBU49Wa
         eax4co6EjFQpP5PUDoDa9MZ8a61D7RUBcvTX5uFS0TFwjgP+YYw7kn+R9G+SlBtrs5rQ
         IQnDM/JssWROYkVXRtSj3l9AF7dvgWh8l7tV6z+N1AqJQYGeIc/BOHoJIwWfX/ae1eEt
         MaKkg5MKm1mZUJY71iDP2Ty5lNU4TXsF9P9E403NPIEuEV3tY89b1wSZdlJmTsLymFiW
         fe7755/RCqq2mHkrn8gFQpJ6iLIGLsOMxRD9YsRcUmWBSaKQm45N5sK/+R2lPmMmaaeL
         nnuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w23si669785plq.198.2019.01.31.11.55.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 11:55:37 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id B13464860;
	Thu, 31 Jan 2019 19:55:36 +0000 (UTC)
Date: Thu, 31 Jan 2019 11:55:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christian
 =?ISO-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara
 <jack@suse.cz>, Felix Kuehling <Felix.Kuehling@amd.com>, Jason Gunthorpe
 <jgg@mellanox.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler
 <zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo
 Bonzini <pbonzini@redhat.com>, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?=
 <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Ralph Campbell
 <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>,
 kvm@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org, Arnd Bergmann
 <arnd@arndb.de>
Subject: Re: [PATCH v4 0/9] mmu notifier provide context informations
Message-Id: <20190131115535.7eeecf501615f8bad2f139eb@linux-foundation.org>
In-Reply-To: <20190131161006.GA16593@redhat.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
	<20190131161006.GA16593@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2019 11:10:06 -0500 Jerome Glisse <jglisse@redhat.com> wrote:

> Andrew what is your plan for this ? I had a discussion with Peter Xu
> and Andrea about change_pte() and kvm. Today the change_pte() kvm
> optimization is effectively disabled because of invalidate_range
> calls. With a minimal couple lines patch on top of this patchset
> we can bring back the kvm change_pte optimization and we can also
> optimize some other cases like for instance when write protecting
> after fork (but i am not sure this is something qemu does often so
> it might not help for real kvm workload).
> 
> I will be posting a the extra patch as an RFC, but in the meantime
> i wanted to know what was the status for this.

The various drm patches appear to be headed for collisions with drm
tree development so we'll need to figure out how to handle that and in
what order things happen.

It's quite unclear from the v4 patchset's changelogs that this has
anything to do with KVM and "the change_pte() kvm optimization" hasn't
been described anywhere(?).

So..  I expect the thing to do here is to get everything finished, get
the changelogs completed with this new information and do a resend.

Can we omit the drm and rdma patches for now?  Feed them in via the
subsystem maintainers when the dust has settled?

