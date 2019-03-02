Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D745EC00319
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 03:27:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66C622075B
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 03:27:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sFxmKbnF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66C622075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C84AD8E0003; Fri,  1 Mar 2019 22:27:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C35C08E0001; Fri,  1 Mar 2019 22:27:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4C358E0003; Fri,  1 Mar 2019 22:27:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76EAA8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 22:27:32 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o38so2546545pgb.6
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 19:27:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=YmQ/nfEVWxvZmt65MH989j5HW22Ux+Ri7rIfiwpkWEo=;
        b=Il4Ih1b8RBMRMqAiMCa7IR7/7RvFvh0OvFulTUoNKHCQ46bdgfRVXm84imsKVstO7F
         4qY1yluaZTiaC9LWJabXKnK0njUXLaQoHDgsbCe5oT4sd47dkCnV/3sNedzTFAUZK1x3
         /3p4/2qrpcIxoOzcBJEDOfkoX6RGsnE6lTv1RIic8wjCbiOSv/8DZKkr7i+IJc8vWnln
         uUhpK6n0w0wJEyOo7G5DWhszPjvec0Jgj3n3WV+s5F+/7oOjA5wnWGduDVHS9XsqmQpw
         c3tK2zb1r0/eVK4gX7NGnxRTg8joIHVDeKlw5WN7kN7hcaJvPl7t1QVE6Ruxth1HLHcK
         tHFA==
X-Gm-Message-State: APjAAAUprjt3D30Lb7lKQZ06tAl0YIxndovv/afYjIsT5i3aMxscR7kM
	qrpinaj+XaGnc3/xfZ/987mYD7Y8EF97PVmNI5jJwvTS91ZB5G/g50xhiFu9/xRHiR8dvsQvS+U
	RkP9psb3Iic2apIsZTaDB4g7K0MkaJGTEcW4mcpg86Qv8TSyitKxDt5eAVIudoB7jAC77Q4LH9z
	EGbhR1uXSMNhvwZriznDp72O1eaWTP5+SPAhhKhKOl8X5YNUtw877S+UkaXevDHwH+Lm323F4z6
	3qp8d0GaOCw25yCbLWHDGTGV+4vgcizVgfL7NFPHsG2OosJckE1CsSEdrvsLWr+pZgkgdHQxKdr
	RXVr6KNluVMJjf6eE2S8gj3h2lkEqbYdy6fYdRuNc8oXfYtCA8y6iSs/fS3Sq0eKv6tw6l+PTkK
	q
X-Received: by 2002:a17:902:9683:: with SMTP id n3mr9100064plp.333.1551497252089;
        Fri, 01 Mar 2019 19:27:32 -0800 (PST)
X-Received: by 2002:a17:902:9683:: with SMTP id n3mr9100024plp.333.1551497251323;
        Fri, 01 Mar 2019 19:27:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551497251; cv=none;
        d=google.com; s=arc-20160816;
        b=rKmLFIw7djlEBTDHwMoHcVX7r+gw0L4uklOMWNO0o/XBP5uSPLqKw4BaxvwaGbiIC3
         7x7vYXUN0uySpnzasIarTm29YOc9j5tOUBZtGoadCw28vbCMcvIEaFv5YBET3EUl/Y9f
         YoOnQIyGLdO6aRvpmc2C2WEdtU8heWxqf/zu2+9ox4xnP8QxAFAvF/oqpBwx7I5RZfZJ
         duhbgIF+N7DI0yBqWb6m3L2JlLIjXfxQG3oirKtb/yqLvZBbb/LCyuv/eUB8iMxnUm7W
         m0q8W4JCb3ka1h3LSdUVCuf3GMrZc16eC5VXuZyAIKSl+7es13GYVjseIR7oUp+2mVTp
         RDpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=YmQ/nfEVWxvZmt65MH989j5HW22Ux+Ri7rIfiwpkWEo=;
        b=tKO6MO+3oPMg2qJBuSkdKOR6dDt8Nsm5eiQ/c8xXAvvdvCjuDAR4NgtXosbOa+zvdV
         f0Xgf30zjda7AniDJZp+DgaxQU1Uw+nYHMDLdN2AUrDHVueEHsaSqx0jFnDfhUblLRfN
         /aotHh4JZXtq009xQcuf2tIldR89tP/6Pa5d4IqFpOyNGqbRK2i0yXfEY4XV91ycvyub
         ckvWotbAr8afjEAlp23XX2AjdZrbiJerz7gx99xpRb689kAe+PI0yGfolWHPbhv37fDn
         ww65tnbGFRoWX2OmSR5KF/xUggPiyR90C1TwokzzIc0XXMkDQEgBPkgTvCtYYD4GBj7c
         Irow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sFxmKbnF;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f6sor9287503pgf.26.2019.03.01.19.27.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 19:27:31 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sFxmKbnF;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=YmQ/nfEVWxvZmt65MH989j5HW22Ux+Ri7rIfiwpkWEo=;
        b=sFxmKbnFVy/0QqNNNfDX0GlfUlrWGlFU28kdU1K+xJeNiv1ltZJ0MeXKqYPO4iZQa4
         CIR7rn/vYnodO2kYg67p+ISh/Zg/2eth8GR3jvHdbaWtdS9bixdR8i+KRyBDAkVFLzan
         5YnKK3ZJyPu5V4wA+9j2wdZrtHBW22Id4vzF2FA+9cVBj0oxXDfQYbLSFZ85kRfiiKeG
         bt1AyeSY+/Zx4vFKDSWw3UmDW91o0jwfrJ99ZUqOLeYNdPYaufJTvpApDPrHinImuAyH
         +YNBL2PSxyeSjKaqNlH5e0aTp0z3VuRBWixWKMwDo7mj29M22gNPBmxy3D+7NpHKAPo4
         t7hQ==
X-Google-Smtp-Source: APXvYqzMCGDSneiNFYjfJ/1ov//ITmiz09EMVCu79pghl7ITloB+qLtRnJZhE1x9LvqnaGIEf6kc5w==
X-Received: by 2002:a63:ed0b:: with SMTP id d11mr8123928pgi.435.1551497250415;
        Fri, 01 Mar 2019 19:27:30 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 63sm42312273pfy.110.2019.03.01.19.27.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 19:27:29 -0800 (PST)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>,
	linux-rdma@vger.kernel.org
Subject: [PATCH 0/1] RDMA/umem: minor bug fix and cleanup in error handling paths
Date: Fri,  1 Mar 2019 19:27:25 -0800
Message-Id: <20190302032726.11769-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Hi,

Ira Weiny alerted me to a couple of places where I'd missed a change from
put_page() to put_user_page(), in my pending patchsets. But when I
attempted to dive more deeply into that code, I ran into things that I
*think* should be fixed up a bit.

I hope I didn't completely miss something. I am not set up to test this
(no Infiniband hardware) so I'm not even sure I should send this out, but
it seems like the best way to ask "is this code really working the way I
think it does"?

This applies to the latest linux.git tree.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Doug Ledford <dledford@redhat.com>
Cc: linux-rdma@vger.kernel.org
Cc: linux-mm@kvack.org

John Hubbard (1):
  RDMA/umem: minor bug fix and cleanup in error handling paths

 drivers/infiniband/core/umem_odp.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

-- 
2.21.0

