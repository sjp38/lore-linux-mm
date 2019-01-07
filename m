Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB991C43444
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 14:39:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94A9B2183E
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 14:39:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94A9B2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 119F08E002E; Mon,  7 Jan 2019 09:39:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CC2F8E0001; Mon,  7 Jan 2019 09:39:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8A7D8E002E; Mon,  7 Jan 2019 09:39:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B99E8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:39:43 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so376858edd.16
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:39:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LFZQrU8fTXYe+4yKyznILHyyYdOjuztNdiLALRdIzAY=;
        b=W/ot4HpxKJvhvMpRDTDZBLj3xrEQ/T+HWLa/jPrYU9TcnbnipBjs+/N9SEQpdbx6Dt
         qWqwLcZzIkoRMpj2FI0qFs22Ncf6hZiPKXdRuSWAJNH3n4vb8ILjFhrQLSbHAEcv0r2V
         SU8AHjVJzWZZjJAGwa/oMaSgW4IuEV9k1dQ6DHGlpbn2Idxna1rdxGoEzmymCoUbB3kb
         CjMTVXuzftP3z3iI2iuxKMp+f8+COy4LKIc47SVNGKWL4OJAn48rR4uXRhK76+y8mFRw
         cp3AttnlgIgBqsX1VR2ApDHi0KiyIIw8acoyK+MSUcg6HoC7hPd8UY3Dzr9C2YjSa5Lc
         fKAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AA+aEWakuEzTEiQrC2gwokRHZgRXYgKSY88DPYbAVo+07FbhUo7GZ56E
	Zn5HmV6FeGOikbI6qpOJUFpLzNtZaDt1SdX5JvsUHTzjYYQToZ3DSTaD6EluyOPJDcuA9npZCi9
	jmRUUYie5oDuaGl1BTlLlRX/39Y7384vfcQlOUeju7ioKzQKCKhDGCI7EADmxiGSVzUHDalaIUX
	hoornkkZ6z6U3PGbX2xCOKYrdegHnzR09b7hiAGEa8mKltUOzaByT40aXaLHZxgt5XQuTNBbwNS
	d4huGk3J1rEWValqsv7m5D9QY02ffbiX8jbwbqxBUU1V4kVfxJ+xhPeqOdWN+7p7BdlacMPNwzx
	su6g3ua2gYI2AwFK8659Mnat0e/DySjqu8W3yIR0RWCQfWDDHNqOhIJ3/ReLT3zyMkh3+DVqHw=
	=
X-Received: by 2002:a50:8d8c:: with SMTP id r12mr55243304edh.105.1546871983057;
        Mon, 07 Jan 2019 06:39:43 -0800 (PST)
X-Received: by 2002:a50:8d8c:: with SMTP id r12mr55243251edh.105.1546871982175;
        Mon, 07 Jan 2019 06:39:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546871982; cv=none;
        d=google.com; s=arc-20160816;
        b=NKe500z5fDDWEuOUh4/5wB8r1xa076SvuWXrfqZo3El3iJukubRoy7kVVThoKP7m+G
         cYFqDb0M/N6ZAGVkRXQZpf52sCGS3FUAnGH+EuUcnfROfe/u5n9+ZUgn0x9zmONvc99z
         DugQrnhNImK77F/4nW9fU7AfGV6jkzCDd9IcACwD5qwmYB4sONxP4bUN/3WtEtNAIEoX
         ZSRJnT1Hc0XI+iEQwBEl3yg8EgPuzRzdd7v7PlyRw9f7n2tqVkDXF1euLXxhSu12L4sP
         AZvGlngWUGkZKJ0cQaDpYQHBX7TgpLzD0ffhTI0ax8vG9hiZduW8xrA5SLwN9dWmY/Fq
         aOGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LFZQrU8fTXYe+4yKyznILHyyYdOjuztNdiLALRdIzAY=;
        b=nUz0XKxiuwFTORTl/Fw+pehkDNNPvpdZIPYE9Rd5z6oJ2/iTMvbpT9MZKql8U8wgCt
         H+U2oS4N2sXV8viRXWhJZJBUInMl3tg3eu/o+76PG5TdyRkHHgi/L2hs3gqe26Nt8o3O
         nqLTFgxfh620e98irNwzrrFmVk4Kd0FCUFpUB1/NJhN4vL6L3PMnJQZaVlRDW4ZvQ2Zm
         rxkedA7vhokeZvtVTbNyM/STjf9VeApuIYq0vhgOvoSF47RhL4QkMZp2+38kkpjsXdjd
         0kpIa5VvmEzFlrGX1SPkJwRBcWPpTVfOmxpcLKGwe10zbSR5DLunME60ojbcvyjjIZ97
         rtGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bz3-v6sor18549802ejb.17.2019.01.07.06.39.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 06:39:42 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AFSGD/XDwJtPft+7e+YBwwRMOEFJiiNj0lmF71HskZs7fiZ6HzWFIE7LfZHsN6DrG9+SFqQ6YZXLew==
X-Received: by 2002:a17:906:d191:: with SMTP id c17-v6mr47364442ejz.27.1546871981554;
        Mon, 07 Jan 2019 06:39:41 -0800 (PST)
Received: from tiehlicka.suse.cz (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id l18sm29285813edq.87.2019.01.07.06.39.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 06:39:40 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: <linux-mm@kvack.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 1/2] mm, oom: marks all killed tasks as oom victims
Date: Mon,  7 Jan 2019 15:38:01 +0100
Message-Id: <20190107143802.16847-2-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190107143802.16847-1-mhocko@kernel.org>
References: <20190107143802.16847-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190107143801.Bb32kWpVYfSTl5Klaf5ieYP1vQsU4dh2rkPYqxOmWpI@z>

From: Michal Hocko <mhocko@suse.com>

Historically we have called mark_oom_victim only to the main task
selected as the oom victim because oom victims have access to memory
reserves and granting the access to all killed tasks could deplete
memory reserves very quickly and cause even larger problems.

Since only a partial access to memory reserves is allowed there is no
longer this risk and so all tasks killed along with the oom victim
can be considered as well.

The primary motivation for that is that process groups which do not
shared signals would behave more like standard thread groups wrt oom
handling (aka tsk_is_oom_victim will work the same way for them).

- Use find_lock_task_mm to stabilize mm as suggested by Tetsuo

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f0e8cd9edb1a..0246c7a4e44e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -892,6 +892,7 @@ static void __oom_kill_process(struct task_struct *victim)
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
+		struct task_struct *t;
 		if (!process_shares_mm(p, mm))
 			continue;
 		if (same_thread_group(p, victim))
@@ -911,6 +912,11 @@ static void __oom_kill_process(struct task_struct *victim)
 		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
 		do_send_sig_info(SIGKILL, SEND_SIG_PRIV, p, PIDTYPE_TGID);
+		t = find_lock_task_mm(p);
+		if (!t)
+			continue;
+		mark_oom_victim(t);
+		task_unlock(t);
 	}
 	rcu_read_unlock();
 
-- 
2.20.1

