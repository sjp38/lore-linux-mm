Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 386FEC282C5
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:33:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8606218A1
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:33:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="VCwEHtpu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8606218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 779238E0046; Wed, 23 Jan 2019 15:33:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 728078E001A; Wed, 23 Jan 2019 15:33:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CA438E0046; Wed, 23 Jan 2019 15:33:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 17EEE8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:33:31 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id ay11so2282154plb.20
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:33:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=v3jNlULmSE1VwiKJZu9XoB4X2QYGbn4gc7r4/sN0uaE=;
        b=UyKTCNP6U1deQOXefLjBBlCiJyrxTLcYuyeGOYo3E7ZHtefVzBTIG1KUmyz5lgo4Rg
         6AzoEhAgICTkTMCSVDU8tZ2mRseRrQAQvjLI9BsxWR7buw5tEPVU09M4LCbbq8uTXWAM
         9ywO/sgUQN7YAKUJNX6EWdpANAUMyijVrDeGTE4R2QDFkUcAr3DJHwHDIBzRJtlJxkeM
         x9UIY01LXjBUq3UPONY7j8JfvcjTdTwJXAuYO90F5k0YevxhlUssNfuS1h0GhJ/9ZYzY
         rVugdPSQHSK7sdVZT7PkYbZnAKvbohMbAfBka1JA69TNeisC+20/SJm2x0qIRBpUzXWd
         fa5w==
X-Gm-Message-State: AJcUukfjrWvCy73ZOlnmzZeFQRL6ff8PrILGcdOsJJT4xNIstR+qxM5p
	k1jcQ/8qLuhIPHi4+yHAm/XYzzB2uuIgg/f8RLTRVKoCdr0As+Rfq2GYXoG8sXjReaCIDF1tO7C
	9X6fwfOmmdG6Zpem2+N8Bi8DnBLle+bV5AkcaX0SjDNoVNt55+QWLW1lXG5skn58SVQ==
X-Received: by 2002:a63:fc49:: with SMTP id r9mr3286592pgk.209.1548275610592;
        Wed, 23 Jan 2019 12:33:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5cliLvG2K5/TcJxg/JmOIDiJlQBbvGmwEf266IJIbx+sG0umvHvf816X4gnxgFjO9KcYGN
X-Received: by 2002:a63:fc49:: with SMTP id r9mr3286553pgk.209.1548275609883;
        Wed, 23 Jan 2019 12:33:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548275609; cv=none;
        d=google.com; s=arc-20160816;
        b=Xm8+8p/sH4TNxaFOakOFmBhd1soiI6e8I3RKagIDOGxVUk57hiKXW2DgT0NbgP/Puc
         t7Hr4IDYdo+CqQwL3l4dOq3bRaZz1XeImdFQmPX59eFtowSww/5yeP5eBEtc0bb8Duvx
         i2JoV9zs0guzgnJI/01s/9vfBx9sk8M7b/iVKRnWVjNgIg/1r6RVCRTBV+6TYj1QEDlB
         DEseoYd2fxxFw8/HawrDAe8Sm5jFFBPuwPA4Lib6JOO0gB2wogK7/KloJ9C+aOgwkeSp
         bkvtW+Y+43hfrvf9FkS2d7TDrpWays2e7WA8znxZZsRicYIWKIZ8Y1G4bT2dgfVGZRZV
         xCqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=v3jNlULmSE1VwiKJZu9XoB4X2QYGbn4gc7r4/sN0uaE=;
        b=zlxs9quqklTQlSZQllJ8MssF+AFuwc1Stc9N5nND4hv92DOiyTh1YSmy49UP/z+xHa
         waJmYhjFEJBLeEjt9zaHA5cIhi6oj6JJfBnSaFyhvLOWWmkbrqDVk1fEnbWAhZltUwlG
         VhXE5gvo2TqIW9rxhXp8/o/wtH1+F4l0Xag1eJGgv6S65ZN3Tt6DHWOxBSkym3rI7It/
         /LewBXMUrIDKcLQSuyw08ByN/rGFJXcypqy7RterNykVlwf8htvrskeKsQxqyfkV0qv7
         71ecGhF/kqnFSGF3xcsEyvTuniJO+eNHS8873vttNl1QcXk5m0MyoBka3OKwNey7mCnW
         3CEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=VCwEHtpu;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id t184si19573706pfb.22.2019.01.23.12.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:33:29 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) client-ip=198.182.47.9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=VCwEHtpu;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (badc-mailhost2.synopsys.com [10.192.0.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay.synopsys.com (Postfix) with ESMTPS id BFB4124E08FE;
	Wed, 23 Jan 2019 12:33:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1548275609; bh=/YPzUCBU7GMseM6oGutvXPyXevw5WaEZWn2TeW3rLb0=;
	h=From:To:CC:Subject:Date:In-Reply-To:References:From;
	b=VCwEHtpuLINV899uuD3C4uvwIg3nf3I66r7K0NjIWgk3/IIsqDYzJjrhU6Rqoo7Zh
	 QPegu7LIcLeeQPWfeHoJUNic3qZxpPlMmIaibbNObQE2S/tYvtx/01U42BEBOkJKlh
	 HUJmlEeR4SDC/TuNN1RJwppUYEQiIyhWIIqv95LpyHqFT+VVmpvffsyzTA8+L0NCwX
	 uNHAUx4T/Iq6k29s4iYvIdtfo5LwBtRIi0pWzDt8WNw5y8l7FFX4DHWYY3oLcCAMgj
	 hZ64fDEo+IfbFBe8NDaGsjxVSjTnSFCJhUMfokS/5JYqcLV0kZD4aXXv0UVYdA/pPG
	 T1W+VLqargwgw==
Received: from US01WEHTC3.internal.synopsys.com (us01wehtc3.internal.synopsys.com [10.15.84.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
	(No client certificate requested)
	by mailhost.synopsys.com (Postfix) with ESMTPS id A765EA0066;
	Wed, 23 Jan 2019 20:33:27 +0000 (UTC)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WEHTC3.internal.synopsys.com (10.15.84.232) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Wed, 23 Jan 2019 12:33:27 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 24 Jan 2019 02:03:28 +0530
Received: from vineetg-Latitude-E7450.internal.synopsys.com (10.10.161.70) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 24 Jan 2019 02:03:25 +0530
From: Vineet Gupta <vineet.gupta1@synopsys.com>
To: <linux-kernel@vger.kernel.org>
CC: <linux-snps-arc@lists.infradead.org>, <linux-mm@kvack.org>,
	<peterz@infradead.org>, <mark.rutland@arm.com>,
	Vineet Gupta <vineet.gupta1@synopsys.com>,
	Miklos Szeredi <mszeredi@redhat.com>, Ingo Molnar <mingo@kernel.org>,
	Jani Nikula <jani.nikula@intel.com>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v2 3/3] bitops.h: set_mask_bits() to return old value
Date: Wed, 23 Jan 2019 12:33:04 -0800
Message-ID: <1548275584-18096-4-git-send-email-vgupta@synopsys.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1548275584-18096-1-git-send-email-vgupta@synopsys.com>
References: <1548275584-18096-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Originating-IP: [10.10.161.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123203304.AkXufxqrSKZYydGOFqvek0V1DJzja7dfn4jrM-N73WY@z>

| > Also, set_mask_bits is used in fs quite a bit and we can possibly come up
| > with a generic llsc based implementation (w/o the cmpxchg loop)
|
| May I also suggest changing the return value of set_mask_bits() to old.
|
| You can compute the new value given old, but you cannot compute the old
| value given new, therefore old is the better return value. Also, no
| current user seems to use the return value, so changing it is without
| risk.

Link: http://lkml.kernel.org/g/20150807110955.GH16853@twins.programming.kicks-ass.net
Suggested-by: Peter Zijlstra <peterz@infradead.org>
Cc: Miklos Szeredi <mszeredi@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Jani Nikula <jani.nikula@intel.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 include/linux/bitops.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/bitops.h b/include/linux/bitops.h
index 705f7c442691..602af23b98c7 100644
--- a/include/linux/bitops.h
+++ b/include/linux/bitops.h
@@ -246,7 +246,7 @@ static __always_inline void __assign_bit(long nr, volatile unsigned long *addr,
 		new__ = (old__ & ~mask__) | bits__;		\
 	} while (cmpxchg(ptr, old__, new__) != old__);		\
 								\
-	new__;							\
+	old__;							\
 })
 #endif
 
-- 
2.7.4

