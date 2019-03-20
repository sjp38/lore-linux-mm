Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDF44C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:55:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D81B218C3
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:55:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="UlM3Ag0s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D81B218C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DADD6B0003; Wed, 20 Mar 2019 16:55:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38AAB6B0006; Wed, 20 Mar 2019 16:55:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22B296B0007; Wed, 20 Mar 2019 16:55:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id E545F6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 16:55:26 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id y129so4934401ywd.1
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 13:55:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QQYLVXkrs82mdvyVr+o8qJgCSfJ2t/bxI7yFaYhe2ug=;
        b=hxmRzidfqYeM/VidnkIT/2E1avTNeSGgQ1ZX6rD+Rwpm/CI7r0KjxuGIL4EE+IwqWf
         UbiH6K7wbD1CaOV9XeOHzGITbrQSZ9Y5M2dm+0Y6qTJox3saYHTmUZ/IFzFDodMpP7iZ
         Wbb9ZV+2L08OaZXsKq5UUFhYnoluOPaoClblGYNIgscFNxE55QABUXmq9xflhX7KvWWx
         pjaN1wJQvGL3exzXX+gZlP73W5mu1rpgcXxr5QzlNvuBdA0EtPfI2zAm2/4uP5sPOLip
         LdMZVOCukBxYE6WEL48ePF92DAPokTxw9sgoWxk4IjhL8c9pHr6zOgvTq7Wug/gMvf+f
         PA1A==
X-Gm-Message-State: APjAAAWapNAdKulYFKjmMoD6PKf4u0OEWlh4DrBMUO9hZduWuqLlvVQf
	JrGwB1Cb0Bu73DnVVhY65IvTXP0oG9wbqFHie4zKGKZDhPEAE7gsOkZ1giPWHGmFYNWsOTI8Xt5
	WEpv3muWDAcG62MSKer0/1sWW2ndng8EO23lEv/DQn77BumcAQr7pC3vkAg4qjUnaCQ==
X-Received: by 2002:a81:3dc8:: with SMTP id k191mr117645ywa.139.1553115326678;
        Wed, 20 Mar 2019 13:55:26 -0700 (PDT)
X-Received: by 2002:a81:3dc8:: with SMTP id k191mr117607ywa.139.1553115325918;
        Wed, 20 Mar 2019 13:55:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553115325; cv=none;
        d=google.com; s=arc-20160816;
        b=Hm+wFYaRNb/Mk5RiU2DD4WX7JwobnMGuHyx4/G1WAvFYkpQMETZhoCieCWtgNgV6gL
         VSbvoUxjZiarAEteYI521P9wS2Ah+aNm40y8mTc53X5iuzwnp/YEISgcIsuc3f/Rsl6J
         g2MnuA/S3n1sN/I7T6ELkP/sYP3DzUybkUzYSoW1Pz0uA0o9xMZp212Dla0F2e/yQMwI
         9u+IL2M8h21coIcvpX6DxfT1U0LHJOphg97qnCRDcGg4CunELv0XG/Jos/C4ndslEALS
         w2bKk9SVbhJwqKFqP76xRjJacdkjEqiM+Yl5Pepd4/5274XQKxlZILrpe/wiRty7x88Z
         v24w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QQYLVXkrs82mdvyVr+o8qJgCSfJ2t/bxI7yFaYhe2ug=;
        b=obHdkcSmJ7TiIfgul7n1/ABvByAW4rt78Mwpi5Q2rvNSp0bW5f0HIuqv2EzbFBux8f
         ju6U0dxc63ecV+AfCzP3qkW5IAZjSuBssv23Iyy7BngaHUmZnqke2H7Ik3G8VFBY5nCQ
         H7pisOQbiY35YFZF+akfpe5BQearNc4UJJ7JKOjlo/Ek/7xo7Lw6b2ftmIs5aE8o6JU2
         8+kdOqWIEFBcCyEJTMU8eWo00G5F7cLCR+07UlUOEU5e7C55cHLCt7WUoowtXNWD4b/D
         QT7d7E9/tLVGm0FKRxN2x9V2YzG7nbH5tWBW9tmbBIeiuNX1DE657ZHVeZGR8uj0w36A
         3RrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UlM3Ag0s;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j188sor1063937ywf.153.2019.03.20.13.55.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 13:55:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UlM3Ag0s;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QQYLVXkrs82mdvyVr+o8qJgCSfJ2t/bxI7yFaYhe2ug=;
        b=UlM3Ag0sHjKm6b60Xzruo36+UDlJMrcULXCsz153tfTpIzb5RNHWobPLHgqI/mhWmy
         nAzG2b60WzKXMmT44qvypKs/MRK3dAvTvsH7FaGR2TvLZdw4/xJW8HsjT5RsKvT2l114
         IxT/BWtMIDwxGR3Rmfw37IsijmQCBbzByTYNMnfL5Pqrmqbt0ycHo6hbZZnw/ciMk73x
         cPcXJLfScHgpDqcmjbfZuTV1rp0MyTLNKhI28W8pS3bGyOp6RhItnuEcuUJOy2Kdykwv
         PxWIWOxISeF3vhf5selrKImaCqn1ve35lBZip8IjabpLC+gzrspIs30WY8hjdR6M7M8X
         2FsA==
X-Google-Smtp-Source: APXvYqyIbRSYuOZ+T6cPUs3nMP69qxZ/A1CkgW2QQVmoCqQ+qIU4OgICrzlh/aj/ZsVwMkaKM+QPbw==
X-Received: by 2002:a81:2c85:: with SMTP id s127mr107964yws.255.1553115319248;
        Wed, 20 Mar 2019 13:55:19 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:b52c])
        by smtp.gmail.com with ESMTPSA id j15sm1001794ywa.7.2019.03.20.13.55.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 13:55:18 -0700 (PDT)
Date: Wed, 20 Mar 2019 16:55:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com,
	mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v6 2/7] psi: make psi_enable static
Message-ID: <20190320205517.GA19382@cmpxchg.org>
References: <20190319235619.260832-1-surenb@google.com>
 <20190319235619.260832-3-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319235619.260832-3-surenb@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 04:56:14PM -0700, Suren Baghdasaryan wrote:
> psi_enable is not used outside of psi.c, make it static.
> 
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

