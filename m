Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F3F5C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 04:57:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29FD220857
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 04:57:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="qj05xz3W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29FD220857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97BDD8E0002; Thu, 31 Jan 2019 23:57:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92B528E0001; Thu, 31 Jan 2019 23:57:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F2EF8E0002; Thu, 31 Jan 2019 23:57:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50BF08E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 23:57:14 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p24so6530951qtl.2
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 20:57:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=ZyfqNSgV7sbHHKf6GgHwEJjj9JK6z7ZkNg8CfEE8r3I=;
        b=l9yj3JOUrKuZtg31op8HGJaYw+FeJvKM36xC4cAO2CRNaoqQpi0yzTbkNa/A6lFs3s
         LJijjrkhijkqc32+Mi0vo1eNArS+cQRY9XL6Z9WNfqBqpFJ7eFowRTjh/ki/hmDGOpa1
         WH2YmtpQPPwC4yDGQ6mmb/DbT/n1CKw7/MHEbEgpovvzBeHsY2IsaY6NL2W6RSU2pyxj
         SRAydV4tZlbljPgdkWp0SoIFYzV+FtXBO0iYKbQwgDAxsyj8tFrbouUwIv08GLp/Bk7o
         BE5Gobha7xpXfJBzX2+vX2+OvYgRCTK6DLyVBnKTSfk8q4Z8g/rmj8zO9vJ/ZOU5lMD6
         YtGQ==
X-Gm-Message-State: AJcUukfN4Tliry1HiAJPEFYaxM3oMfKLz8bmChYtxxK39L6dnZ0bQUOg
	7dPZCi0draStGPBmlC6eJ/G8aqmhG7RifoFYCypSqrxw4oRPc12CadkQK7lCXDzsy0LTbJfDEk7
	IE55FkZX/ejgwxRuYPqGYgYU1ERlHpzeBBhPr1tYkwqyWtS+qNQVBCKJN7vUD2d6r9nAPvd9oG2
	WM3MBNAsXIooo9+QUUIpo3CPJlc4ynOEZNdyfVCioPZqLi475cE6HkmxLndjOnZHQSPavPY/8uh
	K08LqMzjp27xbYJWC3qdw7VLynypxrglmB1tUDpLx91bg/0DHqZ8cXUCda3YNiKm9q5bjTqdhM9
	ehR80h4LJFOWYHmyeQFMR6jrPz9OJfnDcPnzkDVFU0Ah5RQBlTKQRH7O/EE68KNXOTc41PUszKg
	3
X-Received: by 2002:ad4:42d1:: with SMTP id f17mr35142638qvr.59.1548997034056;
        Thu, 31 Jan 2019 20:57:14 -0800 (PST)
X-Received: by 2002:ad4:42d1:: with SMTP id f17mr35142605qvr.59.1548997033288;
        Thu, 31 Jan 2019 20:57:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548997033; cv=none;
        d=google.com; s=arc-20160816;
        b=ssLy1BlQ7oZwwu/NIOJD9FHkAH/Dgz53I597OSnkd4lJ7HkuiRrxAqo9fuNCKwM+Sv
         dcvz5Kw8hpxOL0Ez0oSKpYDpfZMzUCtEOH6BF0ZqC96+Sg4BuH4bg7EZnZtozx4axsPI
         FPm1Dt3DtI2uTXG+mNLDY2XGzca7pQauAaP8mCb6+ijDPNoBlDjb4P8fpAV4f6BAdoZY
         0ZEQDFN++tRqTr8XU6B3d0oz6MFj/rvlsR/OPr0abh+zi9mVLmzzTzYHLs9rY6zONdKd
         CCB9OO9uz1dylOXDCzhy4O3aWUTMpiP5yCcp/MTXZxQjMXcVEyHgt0RF6PQlF8mbsU5u
         +gGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=ZyfqNSgV7sbHHKf6GgHwEJjj9JK6z7ZkNg8CfEE8r3I=;
        b=RlEYY2bljZBg3VkdXfo5TO544pnRpnxBGlBxLeL/ILwdmKJ1Yn2iyJs3rG/zRIIVUb
         wRSaGJa9TEgteEBf6dI7Kq4odYf9RXE/iLIqMyk641fut6S5xhhEF65VUQT9a6PpBvOK
         lXBQlgfMTz6/Q0iKj3VlXXlvGPOljnDGxNqDheBPeIU3Ux/unCKA4+LpAKVK7ntTh85z
         nLbHd1PXPqo2tqsEHHVJHQ0ry+jTiJSF9e7EuAAG1YvMo1BxOeuS6a/kXVopt13ZdJ5Y
         Of+BXT7c2E1YSu7zleYswnFvN937J0M2sExP4foOyO6JR8v4PlzO9lPOO5KBdO7FZ9ej
         MIGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=qj05xz3W;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g125sor3650012qke.13.2019.01.31.20.57.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 20:57:13 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=qj05xz3W;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=ZyfqNSgV7sbHHKf6GgHwEJjj9JK6z7ZkNg8CfEE8r3I=;
        b=qj05xz3WgtljNNSNzrUl/+5aWQIJ56oIIBdLbo95C8lC3RoRbf1Dnk3pKF0YWZakDA
         U/gkYIWajbXocX3JIHknN2rYGqm35i1QhIVy2mnOP59QLd/OPPqeM9LKfdNK4xRxKt8l
         X1J4VfVTn5CAdOjcS7mNBXVokP4Cb0Y2eyi8Y=
X-Google-Smtp-Source: ALg8bN6lky0j7eyRR8l1KOMYo4dQ4KTM3ZIwK7hNi4saong4PPJYdTlx4rmfiM+LF+ZalHu/+2Xb/g==
X-Received: by 2002:a37:34f:: with SMTP id 76mr34530117qkd.347.1548997032847;
        Thu, 31 Jan 2019 20:57:12 -0800 (PST)
Received: from localhost (rrcs-108-176-24-99.nyc.biz.rr.com. [108.176.24.99])
        by smtp.gmail.com with ESMTPSA id o8sm3924052qkg.60.2019.01.31.20.57.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 20:57:12 -0800 (PST)
Date: Thu, 31 Jan 2019 23:57:11 -0500
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH] mm, memcg: Handle cgroup_disable=memory when getting memcg
 protection
Message-ID: <20190201045711.GA18302@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

memcg is NULL if we have CONFIG_MEMCG set, but cgroup_disable=memory on
the kernel command line.

Fixes: 8a907cdf0177ab40 ("mm, memcg: proportional memory.{low,min} reclaim")
Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Signed-off-by: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/memcontrol.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 290cfbfd60cd..49742489aa56 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -335,6 +335,9 @@ static inline bool mem_cgroup_disabled(void)
 
 static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
 {
+	if (mem_cgroup_disabled())
+		return 0;
+
 	return max(READ_ONCE(memcg->memory.emin), READ_ONCE(memcg->memory.elow));
 }
 
-- 
2.20.1

