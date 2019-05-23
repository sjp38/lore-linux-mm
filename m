Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67A19C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 13:40:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2FBF20881
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 13:40:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="lRjVvwQ6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2FBF20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=szeredi.hu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 666FE6B0003; Thu, 23 May 2019 09:40:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6168F6B0005; Thu, 23 May 2019 09:40:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DEA16B0006; Thu, 23 May 2019 09:40:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19B696B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 09:40:29 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id r7so2876046wrn.8
        for <linux-mm@kvack.org>; Thu, 23 May 2019 06:40:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=RXihqgrNhKefCvhDY/iKcvpsKDscNPTah/22A3/ltTU=;
        b=BKdd/C2+N6PPkaD13dAq8kvffVUJnZd/4sq5JolBiDIfIPcPHu/EYSr0koepGbwPmy
         O7pMQYX4Nsg3L1cxAUIjBszgJDvKpvGza147mnP0h4TNRF1xvgekAdqQZYDe6NLU3PEQ
         Ebxg65MnG9Nx5PX8SqtuFA02F8ccesx7gg6xuVds3Qxqup3urS8HqQXcd9q4AufIqTQF
         6iR/BjRmVXa3xvic/EYcACBzDT/0o1L5pAm28EYba7RXM/leGvGthubRk3sZhCX/WqNN
         ijgtp4wE34do5Yc9khQQAOa2v6Ay3Wrx1YyXM9nuK+aNgD2Y4Z1m9khclibo4Znv+c7u
         ybXg==
X-Gm-Message-State: APjAAAWpQdpQrEC78miNUFCdvzEq2KFS/c47OMnhZs40lpGocsxAdJT3
	WiOThQ8wuQWFdi2ilaFfieZ8lcPswPZIW7MklWs2nZY9kqBP6gjn9mlTyYaAfL58VvGBDtRl1F/
	bj1a81L1ObKI/GrzYVvdCJDkRnBCFVCbiY695v1FdRUvYh1dDRdiiKt+8/RdeIonySQ==
X-Received: by 2002:a5d:440a:: with SMTP id z10mr18819175wrq.157.1558618828572;
        Thu, 23 May 2019 06:40:28 -0700 (PDT)
X-Received: by 2002:a5d:440a:: with SMTP id z10mr18819122wrq.157.1558618827727;
        Thu, 23 May 2019 06:40:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558618827; cv=none;
        d=google.com; s=arc-20160816;
        b=wFr5djXAx6YdV6u5BeUIvKbvIU50dOIjqiLOnnsZ/0V1TPHLMnrW7zGJcd/HLkpJKE
         +rTZtEzCwntPR/wS6e+DuJWLgai2AXksn/vICTPKwKgLQBp2untfz04jpkAStjPkFqaX
         YqLXbEp9QYGkOjNf+qm+7XAlsnjWyFeeqqZw4zefsXqCRiFz6UWovnVulaWKmNJdDXSq
         IUlbebPtfbCTNIuBqkHHRjb9pvWov8qS0atfwjDH8C7bzQhnd9vpMFwNnckdZSXXEqBJ
         st8S4oJOM1yBfgX6GzrrdPssVkWuQrGsErQdbfRuhROq17iGV0QbFfvlZ8GfoOIgwZmy
         Flow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=RXihqgrNhKefCvhDY/iKcvpsKDscNPTah/22A3/ltTU=;
        b=BGN824/YPg0QH0LoVzG3cXFmMjsdw4DcD9FSp4Y1LOJ1kMEGGbJnkfqw3+Oce4qQTp
         0MBw7a76VtfeKrO5F+CvOb0muwM/Bvy9TGav8+8XRYKIuwECB4r80E/cdbli+VgrqTr5
         /0qFbbA03GDFIJ8BrB8T/fCgRdLl3SjiWGkDZes6rS3p/UbpTeqAwqh8z3WDh3U/Nq3h
         MWkcHNyid9NItoKS2OoYBcC0YBSnP9h1BYTOoOwuBpYIjM4ByDmwGL3O3Ktjz6k+qsI1
         Os0/+rdunqnq/8Rrgf5iQgknQAMjMRuLs9lu4AJ5uxJjLXKwQSYYhyFc5QJLhqEAhAoW
         j7Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=temperror (no key for signature) header.i=@szeredi.hu header.s=google header.b=lRjVvwQ6;
       spf=pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.41 as permitted sender) smtp.mailfrom=miklos@szeredi.hu
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y14sor462827wrr.3.2019.05.23.06.40.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 06:40:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=temperror (no key for signature) header.i=@szeredi.hu header.s=google header.b=lRjVvwQ6;
       spf=pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.41 as permitted sender) smtp.mailfrom=miklos@szeredi.hu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=RXihqgrNhKefCvhDY/iKcvpsKDscNPTah/22A3/ltTU=;
        b=lRjVvwQ6vFpT2oxwiaSw0bJmmjwsLHLsMxSuane+fs6MpbEAOlAa6BrvM/sws+uqAa
         9jaMeRKXBoesqedOqlp4IZeOIQBzCLQhNqE1qMbOGNpNSb+wRHWAwf4++vTPxy9hmLMB
         oaDH6XnBAZ8Nkid/C1boGi3t2Tn0JVIvGinlE=
X-Google-Smtp-Source: APXvYqyfzs4kFhMYoPE1pCvqRdMTJcrzSvFcGgX0u4JoWonqDdXKXudSDcrG2SRwYwEIET33XAdOpw==
X-Received: by 2002:a5d:6b49:: with SMTP id x9mr83718wrw.170.1558618827353;
        Thu, 23 May 2019 06:40:27 -0700 (PDT)
Received: from localhost.localdomain (catv-212-96-48-140.catv.broadband.hu. [212.96.48.140])
        by smtp.gmail.com with ESMTPSA id y16sm13494896wru.28.2019.05.23.06.40.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 06:40:26 -0700 (PDT)
Date: Thu, 23 May 2019 15:40:24 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Subject: [PATCH] mm: trivial clean up in insert_page()
Message-ID: <20190523134024.GC24093@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make the success case use the same cleanup path as the failure case.

Signed-off-by: Miklos Szeredi <mszeredi@redhat.com>
---
 mm/memory.c |    2 --
 1 file changed, 2 deletions(-)

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1470,8 +1470,6 @@ static int insert_page(struct vm_area_st
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
 	retval = 0;
-	pte_unmap_unlock(pte, ptl);
-	return retval;
 out_unlock:
 	pte_unmap_unlock(pte, ptl);
 out:

