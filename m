Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A107AC04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5797E2087F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="C5Bzseg2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5797E2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC2BC6B000C; Mon,  6 May 2019 12:31:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E728B6B000D; Mon,  6 May 2019 12:31:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C29466B000E; Mon,  6 May 2019 12:31:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A50AC6B000C
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:11 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d64so1397802qkg.20
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=3tB4TRcqPwl6IgCCTq3FyKBtrVczmpENbbiRumQIu5I=;
        b=KEWNqN7WnUS1uaAKvKkS8dHVadrnZrIECxEk0mQux9nPwQokz8xNskXFmEb3ARjBnW
         FZUqOaRLDejaI1aGtgUQfgv9CCBkkgZssBHgp3HBpehSVnvG42kl56HN9MD3tcuvgpTb
         09iLp7Eegd6Y3UGvOzaWUnMRZYjcJTHVdWSENOk1SUqikcj1by8O7QPJg+e+RDX8m+lo
         QbyP09Wz+L7XEbaoNZpp9oPU4w0ljBNXPm0qcTMEyArJKlzyOd4RWT0wfNIhsKTFS16L
         b4t/OGN51sPC63iV2FjCEwss4fbxNtbQTktpEHMQq8v3p1jkTFVBZjquMyB9EyKoUMk5
         gtxg==
X-Gm-Message-State: APjAAAUsE5J9eAAGHNS4MIbeP28mvtYyFDNvT4v7tIXEPMXrToayI1/6
	kwZaeTxn1jT1SLr5BcvOO3XRJUhs6YCe3MXiEEjfo6jZEobck6CqW9Taz5YKXmx4UhHG1T98Utz
	7J4BYMa8ikOaRpYqRIUcQ0lf28hhM9NHXrmflkPE/qS91lt8KlpJrLEwHwat+KhGSrA==
X-Received: by 2002:ac8:3496:: with SMTP id w22mr4123692qtb.282.1557160271316;
        Mon, 06 May 2019 09:31:11 -0700 (PDT)
X-Received: by 2002:ac8:3496:: with SMTP id w22mr4123652qtb.282.1557160270767;
        Mon, 06 May 2019 09:31:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160270; cv=none;
        d=google.com; s=arc-20160816;
        b=rziV+Bb/9Dg8J/RE/0EYZuumLJA9Z4+3GlwN4OFI8Clhj5mfaW4+CRLFVRWy8cPYVl
         Cxr0y6N8AwNJGLhfEOMR08wtkDy0LIECF8XZniLban7J+yg5W/td0vEfyf1mPPQGyU1+
         9bUvh4CJIuUF01E3heC4vTuWpIKqKWv+Z0fQN4abGFUT+N69BpsaAskPbAkFeEHHzP+z
         NVzldMFOZlpw33ylfYrYReFXpc8ddXeuBCt71x6xvFz2oEnRFI/r4cURVTwDcci83Lpi
         rutTi8sqh8brevfqp3md7sN+H2Y7h6FeJ7Db+YNhniIpcUHYoBJUvWUV0/Jflg1wRVu9
         GmDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=3tB4TRcqPwl6IgCCTq3FyKBtrVczmpENbbiRumQIu5I=;
        b=yVdRxGXYPkf4eurUbIzR32XXuzWmBSrtfEFLWtzreQhAsBifuW9IGnhUehK47uMWQP
         B2BHCC1MMLrRKE8hWPcYPfk5g343Dq+YPXNietTUVr/o6zVHPUgDeNDbmIXChCEUnhF6
         y3QWAsh6IjQ5cBWx4EKoo6Yms0+mG19QFZ56ZjQg/4z33M3h9Yec7IN+QnK6l6Wekrw5
         GmQTMqARauxo/NNt7mUlVO7s4UsZYe538jbcAXkUuGMJXqu1nb4aGmBA2y2W+YCMxxMh
         8RGsxxlfArccXPtNKnvf3f6z4Wxx9Tgql8QGtKqP6naWVRGbbuMiASCMHwziL9MvKB8/
         fZkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=C5Bzseg2;
       spf=pass (google.com: domain of 3tmhqxaokcd8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3TmHQXAoKCD8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id s23sor14667551qtc.5.2019.05.06.09.31.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tmhqxaokcd8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=C5Bzseg2;
       spf=pass (google.com: domain of 3tmhqxaokcd8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3TmHQXAoKCD8boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=3tB4TRcqPwl6IgCCTq3FyKBtrVczmpENbbiRumQIu5I=;
        b=C5Bzseg2BAkWez5di4p65TqBX8PhS2fPXqJjrcuborrGzdIMmjBkEGS1oepu/kO4gi
         ZrAiwZ1YbirX9TOQW6iDBsdtMTgTZyQlBla9C/k5+v0DS9Eu7yTQTxvIZJRaIMRpa57h
         rZkszsH1RsVjkBjXJm8Nw6zDYrexUGyc9BNsDlgeAocqmj+aaO1LdZJjYgfxEDSFYcJj
         gjdVUEcQ+veFKjzDustw9+BWdSodbg3cE0gzjdewRwKOf7czWg4u+rE0852iiQixBdas
         JIw3pQAvoPC6IfNeEfBV09Q69TtafbxIB+dc/sgJQwlLGyiy5Ze3tqDZ/eiYCNwSry9q
         rXvw==
X-Google-Smtp-Source: APXvYqwDoIRoTGaFyeue7qd81SpE5xeykRQrED4HzbPSjcVVRn6t+xvIGHOhvH8ghp1kYB1swN7rJoVGjZYp31y2
X-Received: by 2002:ac8:3390:: with SMTP id c16mr6277321qtb.315.1557160270425;
 Mon, 06 May 2019 09:31:10 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:47 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <67ae3bd92e590d42af22ef2de0ad37b730a13837.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 01/17] uaccess: add untagged_addr definition for other arches
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To allow arm64 syscalls to accept tagged pointers from userspace, we must
untag them when they are passed to the kernel. Since untagging is done in
generic parts of the kernel, the untagged_addr macro needs to be defined
for all architectures.

Define it as a noop for architectures other than arm64.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b10c21630f5..44041df804a6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 
+#ifndef untagged_addr
+#define untagged_addr(addr) (addr)
+#endif
+
 #ifndef __pa_symbol
 #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
 #endif
-- 
2.21.0.1020.gf2820cf01a-goog

