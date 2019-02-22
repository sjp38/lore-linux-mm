Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37FA3C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E93672070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fnTgPPWF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E93672070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5ACB8E00FC; Fri, 22 Feb 2019 07:53:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB7A58E00D4; Fri, 22 Feb 2019 07:53:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE3E98E00FC; Fri, 22 Feb 2019 07:53:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4CCAC8E00D4
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:41 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id f4so953617wrj.11
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uDDn0ivyVadTQonBIumHfFBd6mG/pAa/u+KuaaJi/B4=;
        b=ifeNtJQkyncQjPa1ds+NvZNnkWDjnN02SvVJXCtC0ZY2PUmf0aMdNQek0QvKfzyg/5
         9Z3/p68H14btA9pu9M5CBhNpxxhE+737Ro904mTTNVQsoTWQUjrSmrhj1vcnrCqWp/Sj
         GeMzcpS9IPoycSFHoKARch4/n32YJmSvjJTPiixjpsJsRnfdxjZVDHMwHAJ+PSUWWVBO
         QbdL4atIsH/ZPyGJhJ03v4BvfSZP3qYbebSZe0m1E8kYm2rVlrKmhZ66OaaIMNLMHqga
         7idJNgwje1vH6a2Q/EYyvxWYIqagyqFsL84ApaBQejn+mUhAUMQb/48xvVYuhfhZHJQ3
         rcQA==
X-Gm-Message-State: AHQUAuaKQrSlbMTjEr9aHVTxG0hJTbCIR79zWxuOp5WWjYL1gSXSJmlp
	KEvq7IZnfhNLm8ECj+eV8F7Md3saom2ZN710fn1F2u6z5QaOsx3cKP+ApwwrmdfRup7kLl6P3oT
	px3lhOJa/nI6+mxbbgh7s9uREeljtmzPIWnargMTlfIEChLgjbUAxiLu+ANX9gpwtWK92AgrrHm
	DPp8u7sPYXaV4DVDnO9AjhKKCbqwBMILuStuTdy7jdVMfuvNN2ml8+qwAky7ckRFVJOKCzXIBST
	8sqrkGZpsRUpDapr63peAuRjOIiHPYlNHi3LNlXLW/7lULW6pRUI4DhJ3Sl4CA7sCZmL0q1tUBQ
	myePF7nD/ZNORUM1WZfiHFAu5rEWlE0/ikKw4nH/81LVOvCycbatsnCJLIXdJw+ONJgBoiXNEtw
	c
X-Received: by 2002:a5d:4804:: with SMTP id l4mr2973094wrq.177.1550840020861;
        Fri, 22 Feb 2019 04:53:40 -0800 (PST)
X-Received: by 2002:a5d:4804:: with SMTP id l4mr2973054wrq.177.1550840020183;
        Fri, 22 Feb 2019 04:53:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840020; cv=none;
        d=google.com; s=arc-20160816;
        b=Z6K7ro3RjwRs0WuktY+JqRpDSEGFXDaWJr3dbhWzEyjn24eZGoCagWD813hj/dkOlD
         s6h8Z0Xg+kfMj6JMGCAl6rb7nAU82OIf/s6nemTHtiF6+vRcUZErHBX1LuqgAMrG9dDj
         fr69h3LfZV17ltGUyLi7V33p/8C/e2CSi17Q0IPnJJ7qd4W1bBrsbA5rxbJGpmaaKo6h
         BJF4DHCepDXTQWcdSw+2gAY5t1zb9VeU8y1OGIYJJec4cIR4vWDIpOkUuZmBSq73OcM4
         lw8LjBcWw+YLQfXWToWp3sG/b5HAbCDYzsnpv7th0nyn/G0srVSEYaLHpaPlRQijppgK
         meGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uDDn0ivyVadTQonBIumHfFBd6mG/pAa/u+KuaaJi/B4=;
        b=dTjfh32DG9/YaLFfAMkmEHs4/C7O/oXYJ6MKlsjQ7iXCQCxXzdUNwVGN+sGVoFXBsr
         ltKgskcZX4ZHRdCWHVM6ywU8cA9dfwEstwiHWp6B+fL7jDEWQhNSE/x32TX19CXISnVv
         g3Bgpk0h09zXaipjrn2fOZuIhVbEyGpme3jqv1qvJ4DSDDNQf7TDKQb+mBa+DtQzaPBh
         QiydW9zkaq/TmcglD3d0PH503CujPGbsFVkYEy+qRVTey5XE2miPicbk/Is/n/sRIHaY
         WjClz3EH+NZgvB7hDi6hfk3/IYSnH4WirBYpZSPRcUPydbQPUabfDcMKrUW0OcRKuied
         PcHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fnTgPPWF;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1sor1100946wrt.25.2019.02.22.04.53.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:40 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fnTgPPWF;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=uDDn0ivyVadTQonBIumHfFBd6mG/pAa/u+KuaaJi/B4=;
        b=fnTgPPWFbhryzIzggFc58E4JRsSfK1IU6Sw4LOT9BmgUYGkt3wEcfANoHsXQNUfzc9
         iq9GnYboQsHAKfaKEMrayX1hTXWMMzN/I+6xp02HRbDpZSbRDDjWtj8CtbTOO+dIfC18
         ltrqDIgvui1Exhs0Vsi5guo+6E3eT4Wtp8hwz3ZjUu7OWeuvZHwtR/+mz7N5pObt7Jyg
         o9MWPu/ZGZA22IZSghjyRMXWOy54fhII2IqGEsHjXbEZzuq4hcuupqXge221UVGDnEs4
         VFRnbwlpME12B1w6MdCak9Bm0Q10KMMEgKTJkafiFF5n0MsmyUqd2OoKz/ClD7ZF5Nsp
         o7qQ==
X-Google-Smtp-Source: AHgI3IZUynwk0jQkzXh/fkOnLsB6yWgKr9nX+ibOmHPHqGghLVkrUAqVS0J+X+P7S91mSoisvLsmzA==
X-Received: by 2002:adf:e548:: with SMTP id z8mr2994894wrm.52.1550840019712;
        Fri, 22 Feb 2019 04:53:39 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:38 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v10 05/12] mm, arm64: untag user pointers in mm/gup.c
Date: Fri, 22 Feb 2019 13:53:17 +0100
Message-Id: <12759ef1c30887dd9fc7a04498f5a434a67f98d5.1550839937.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <cover.1550839937.git.andreyknvl@google.com>
References: <cover.1550839937.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mm/gup.c provides a kernel interface that accepts user addresses and
manipulates user pages directly (for example get_user_pages, that is used
by the futex syscall). Since a user can provided tagged addresses, we need
to handle such case.

Add untagging to gup.c functions that use user addresses for vma lookup.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/gup.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index 75029649baca..b6eda1608bea 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -683,6 +683,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!nr_pages)
 		return 0;
 
+	start = untagged_addr(start);
+
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
 	/*
@@ -845,6 +847,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	vm_fault_t ret, major = 0;
 
+	address = untagged_addr(address);
+
 	if (unlocked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 
-- 
2.21.0.rc0.258.g878e2cd30e-goog

