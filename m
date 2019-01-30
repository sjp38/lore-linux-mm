Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4FE6C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:53:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7423D20989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:53:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7423D20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00F0A8E0009; Wed, 30 Jan 2019 13:53:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDA658E0001; Wed, 30 Jan 2019 13:53:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D804E8E0009; Wed, 30 Jan 2019 13:53:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D04F8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:53:14 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y27so520698qkj.21
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:53:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=guuxJdgPBvKsXmThLWItDwSAkwmOTBr+oijU+Z/x72c=;
        b=RRMn8pXoDlbn3+NkIkzBthDZKKRaMnpf4CxQ13mQPGxWcZ0p2ddooy7+JhLDvkVr1D
         IH8XeMHJ4HNkopyq4vk3xCKQt4ngGZ7rMpVhJbqkSeOtTAV7YLMj8GcsG8WU5Lr4NXub
         pifa39otRekOj5S7TWnnX+pw8VLIntGt3kqenUSXZs2GgFngKLetM768v/r34g7D96cb
         rcyuUaUUgSK7o7LfaAvGPVseNBr5x2phLmcJp4O+M7OI/fJ5sN3teUXHNndqJBDKp8VF
         qF4JdKzA2z/OhcS1P5LMKO4WZCulmpjkkG9KuGXP7au1CRuNH4jhYKArm8kMMxizWKo5
         4b5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfIXNHB1d7LE6aYrvpbcF42Zgvbs4D2kxmJDzb2ollsfhrLqjQ7
	HeuXGBzjulOaPfuFHsrAb52Qbpcupz07KOoKI30xPNDqdFJmKkBvqfD5Da2quJ1sgWgPzVzjl+F
	G8wlymT3vepvGB++GQIu9haqGxpBJ0Uhmd2wwu3IN/D1sIO9d4JQN3+WBFNMPfYfQZA==
X-Received: by 2002:ad4:5004:: with SMTP id s4mr29544864qvo.109.1548874394404;
        Wed, 30 Jan 2019 10:53:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7gUEwStY6LmGf5QMNaG3irCor46iCJx1lwrODTTHE1/5+xbbP7X9Z4cdktm5fEJfgK/sUm
X-Received: by 2002:ad4:5004:: with SMTP id s4mr29544835qvo.109.1548874393874;
        Wed, 30 Jan 2019 10:53:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548874393; cv=none;
        d=google.com; s=arc-20160816;
        b=a7HdzCK+PXv3QHZWHcFkuUMI1pDZDZePa0L2tM9fnXphYswbFIpRp3LvjzxkThpa7R
         xmf5DPs7jUwPlDSZxk6KDb4a92kMF3SeC2D4KAUMiz3R8MhUlh2pA6SH5VKGEy37xojA
         0T7bjsdbiRsYZo+zWcLTueAepRNrYDr8Ol+8Xna33FRASh0QxiBlUN9QE91giLJ0r5cR
         rsYaz+mqUcdDgF1GoTeE1ErORbkXkyRZdAGGDpawVYTpWwDmvCL3Sqr7udrnDB0ZmQuB
         YV8zdvRGmXxkizoPEdt3HKLUeATvi1X7emyUVteny1Cv/JZxlDl3sm7wFapaS+qVx6aW
         06Wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=guuxJdgPBvKsXmThLWItDwSAkwmOTBr+oijU+Z/x72c=;
        b=akyjN93ck/3H32S9Jei+GvogZ95hHFn1KEsPL+lvSuFNdQtrSFUgxUfJA01TATK8Zk
         xgL4oGCb6iHs75g8krWyWmvwJsqOPI7yxW7KVYtkU6DuUgqYVEJ5lrzk7ma7JGuyXjpU
         dPTreq218Mc2uUIAmgy8/UlZmKtWgkCSAGVG5zAH8Zw+Q6EcM+2556+uT9XMzdGJT3sK
         vLcX2HktsyWdAegaPy4YDaUsokTD6emlfJspelmzqgiEEjh76Lx1rxeQSQ5fxiBn+QLp
         2Qf0NFGlGaiB4M+Uwul+N8a9cYMEkjJrWo1bs014Xfq5b0zmkG6+SlH0C7ufegpHPQ/f
         4bKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q11si1505663qkc.214.2019.01.30.10.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:53:13 -0800 (PST)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 516EE88E5A;
	Wed, 30 Jan 2019 18:53:12 +0000 (UTC)
Received: from llong.com (dhcp-17-59.bos.redhat.com [10.18.17.59])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4CD515D787;
	Wed, 30 Jan 2019 18:53:10 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-doc@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jan Kara <jack@suse.cz>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Larry Woodman <lwoodman@redhat.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	"Wangkai (Kevin C)" <wangkai86@huawei.com>,
	Michal Hocko <mhocko@kernel.org>,
	Waiman Long <longman@redhat.com>
Subject: [RESEND PATCH v4 2/3] fs: Don't need to put list_lru into its own cacheline
Date: Wed, 30 Jan 2019 13:52:37 -0500
Message-Id: <1548874358-6189-3-git-send-email-longman@redhat.com>
In-Reply-To: <1548874358-6189-1-git-send-email-longman@redhat.com>
References: <1548874358-6189-1-git-send-email-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 30 Jan 2019 18:53:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The list_lru structure is essentially just a pointer to a table of
per-node LRU lists. Even if CONFIG_MEMCG_KMEM is defined, the list
field is just used for LRU list registration and shrinker_id is set
at initialization. Those fields won't need to be touched that often.

So there is no point to make the list_lru structures to sit in their
own cachelines.

Signed-off-by: Waiman Long <longman@redhat.com>
Reviewed-by: Dave Chinner <dchinner@redhat.com>
---
 include/linux/fs.h | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 811c777..29d8e2c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1479,11 +1479,12 @@ struct super_block {
 	struct user_namespace *s_user_ns;
 
 	/*
-	 * Keep the lru lists last in the structure so they always sit on their
-	 * own individual cachelines.
+	 * The list_lru structure is essentially just a pointer to a table
+	 * of per-node lru lists, each of which has its own spinlock.
+	 * There is no need to put them into separate cachelines.
 	 */
-	struct list_lru		s_dentry_lru ____cacheline_aligned_in_smp;
-	struct list_lru		s_inode_lru ____cacheline_aligned_in_smp;
+	struct list_lru		s_dentry_lru;
+	struct list_lru		s_inode_lru;
 	struct rcu_head		rcu;
 	struct work_struct	destroy_work;
 
-- 
1.8.3.1

