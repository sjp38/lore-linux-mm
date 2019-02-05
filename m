Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC562C282C4
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 01:22:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2430B206DD
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 01:22:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="fgcKx0If"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2430B206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7932D8E006C; Mon,  4 Feb 2019 20:22:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 741A38E001C; Mon,  4 Feb 2019 20:22:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 631398E006C; Mon,  4 Feb 2019 20:22:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE048E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 20:22:35 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id m37so2047961qte.10
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 17:22:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=/vDaxBVASW6iBtYKKCds6dLngrOLTNYFBovgl2XcSN8=;
        b=tpzDEfJ2y8DdOuNBEuQ+aFMLdcnbx3WTUVUaARy6pcLvYJy4/5dPvR1cqQQDxNMni1
         t7D4NCIVbndaehZEBghOjdXQHT34Vqik90Aqgzgezd3sUq+DOF61zWFCcgdtEEGOiftB
         +BZfdpqeu7a6D3Xq3dMMMnu1z+KtSrzCHmySoeOuIgYZ3j6cOsd9/QN+zDAx9lKW0Vv7
         2QsVbW6I7ch05y5reJlFmb94pa4VdqYDDH7wtaks3zZuc0OouS3P4LLvbsAse0OIjGNY
         R0XDsdZ6RLdKnk7MlBoO8YcuIXeWQ6kQwiB7gJeBYlDcn5YS2yUJ87DQq6UBZ3J2Rk3q
         iXeA==
X-Gm-Message-State: AHQUAuYA2/gTIL1K507TO7sISwNMEp0KXXpKHYACJNC5FG6ZOg7pYqdJ
	4Jey/7cqvqUwQLURWgdJNHr4UvwJYphnlqYJ6sD/uTGer1pO43yxGN9kdKZAGSyMelWk0cBBys2
	Bleitk/i7L4CE2xD8iG6msQji1s8VVXnI2TAtsTXO5jCphhWRd+OLe9h3TAHSS7Gqb4XmeN8exM
	sYyeHqUElSEp2Li2abVCuAD67Sr8HvuhA+jAbulAROt0BGwcrHUWnYMmtBv+8+39X/6z/CyCIz1
	a9TgjbfuCT0VDqn7koFTwbVAIXFXkSrjbooE4Ub7XEaWzPeETfOUKNNTZx8mfigmGMD2rdCcXYF
	XhCLkWxjKj8NOwqzDw9gRYPJ4/OWLqrFDOZzrKG39P14CeYiTVf/ZPtrvSOuOj33Qkj/SajIf3X
	e
X-Received: by 2002:a37:d1c5:: with SMTP id o66mr1664417qkl.293.1549329754950;
        Mon, 04 Feb 2019 17:22:34 -0800 (PST)
X-Received: by 2002:a37:d1c5:: with SMTP id o66mr1664398qkl.293.1549329754298;
        Mon, 04 Feb 2019 17:22:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549329754; cv=none;
        d=google.com; s=arc-20160816;
        b=pm9w5wh7MXM+AYUOF4OCP6k/BqjW5JMLaoR3VT4y5iOzc9X5ZKCr6IF07G3af6g/lF
         oM28W7n3ZKY//6L/0lTugqfp/gBan2qjDGYeaMjnuklnbTCbVVKgGkhL7XTsoCoMImIu
         +ObmbAeshfUVq22JJAQ72hk6+ymApuFrSac7AENSvw2uznGQGC2GmiKojw32I11lxGho
         h3x/XqvaJZJWrJb5ob10z8yHx29AZOag3N0EfuRzlMPa7Sg2Zw323JmgpuligIlXcvKv
         hwETHt2KudzNQc/cbrVcfTpF/5HdIKuxAIsxOH1NRnIIHLHQOciHh8+mUzuIlYCFcLSU
         8L9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=/vDaxBVASW6iBtYKKCds6dLngrOLTNYFBovgl2XcSN8=;
        b=cx8RtZA7FMvKvbE0M7wbtRf42e6dPJqET9xGGvDCD8xOLSar4z8/wyT+VCWhmb9Jk7
         SP4juYgYasc/lmIVdn8KQHRqjsL3w7N83HWrNmBmzhksHVGYRyLw7Nkyf+VNRWm6Ek15
         vfEhilQkzS3u6Zdz3KuuOHOinheBnIw6Eusq5qXWcshsV1qsXI9Z2a3I2fQNMW1L5wFn
         NG5C5qkJZGJwCYhpkydX5aE7UkdupZ8rt1t9HQ4maE9CT1R4nlWk33oHDzH/vsklQBcu
         JkM8LHHhWh4/QYnvzyEhVxbyFRNqSV+mAnZ67LaMHFyILbX97RjkXEfM6gtP5p9TSQgr
         dsoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=fgcKx0If;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u9sor25710726qtq.66.2019.02.04.17.22.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 17:22:34 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=fgcKx0If;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=/vDaxBVASW6iBtYKKCds6dLngrOLTNYFBovgl2XcSN8=;
        b=fgcKx0IfCGlfbxb4mk2vOLKuRBUo18bqf+XVKJ4FDJl5hF/rZQY+jf07fH2fGi8nZe
         oC9KhjsJd+C1k8zKkkiLqvvHRMK+Ei3k4/RPWmW2H6OKk73yKulD8VIitWASaK1RQSzF
         Yfr3tWa5JCTamf0IK2nQm07cN/79/PFaKaBwRQsrKA0OqXAGJlG0O8JOm+mABUnJ21bp
         CHUI/l8Pi5syh4GMw+U2CVHZ2U9x8n89onx3Hi2KF6cNFKZkya+u9CiJ8Q0jkIy+8N2w
         BnrNBougZBlGz5Z8JscyPSOamn2Q9awbT7aTndrJm0sjNJzenvYnu5POfM6egtjQuLGz
         MrLA==
X-Google-Smtp-Source: AHgI3IYIJQfQ0lRcRNH2GuySKqa7VlZE+jw/33RiTr2diDYvcv6jKOoXazv6IbLRcLheJh+VKiak+g==
X-Received: by 2002:ac8:6990:: with SMTP id o16mr1729486qtq.185.1549329754031;
        Mon, 04 Feb 2019 17:22:34 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id d7sm12466946qkk.71.2019.02.04.17.22.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 17:22:33 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: mike.kravetz@oracle.com
Cc: dhowells@redhat.com,
	viro@zeniv.linux.org.uk,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] hugetlbfs: a terminator for hugetlb_param_specs[]
Date: Mon,  4 Feb 2019 20:22:24 -0500
Message-Id: <20190205012224.65672-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Booting up an arm64 server with CONFIG_VALIDATE_FS_PARSER=n triggers a
out-of-bounds error below, due to the commit 2284cf59cbce ("hugetlbfs:
Convert to fs_context") missed a terminator for hugetlb_param_specs[],
and causes this loop in fs_lookup_key(),

for (p = desc->specs; p->name; p++)

could not exit properly due to p->name is never be NULL.

[   91.575203] BUG: KASAN: global-out-of-bounds in fs_lookup_key+0x60/0x94
[   91.581810] Read of size 8 at addr ffff200010deeb10 by task mount/2461
[   91.597350] Call trace:
[   91.597357]  dump_backtrace+0x0/0x2b0
[   91.597361]  show_stack+0x24/0x30
[   91.597373]  dump_stack+0xc0/0xf8
[   91.623263]  print_address_description+0x64/0x2b0
[   91.627965]  kasan_report+0x150/0x1a4
[   91.627970]  __asan_report_load8_noabort+0x30/0x3c
[   91.627974]  fs_lookup_key+0x60/0x94
[   91.627977]  fs_parse+0x104/0x990
[   91.627986]  hugetlbfs_parse_param+0xc4/0x5e8
[   91.651081]  vfs_parse_fs_param+0x2e4/0x378
[   91.658118]  vfs_parse_fs_string+0xbc/0x12c
[   91.658122]  do_mount+0x11f0/0x1640
[   91.658125]  ksys_mount+0xc0/0xd0
[   91.658129]  __arm64_sys_mount+0xcc/0xe4
[   91.658137]  el0_svc_handler+0x28c/0x338
[   91.681740]  el0_svc+0x8/0xc

Fixes: 2284cf59cbce ("hugetlbfs: Convert to fs_context")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 fs/hugetlbfs/inode.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index abf0c2eb834e..4f352743930f 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -81,6 +81,7 @@ static const struct fs_parameter_spec hugetlb_param_specs[] = {
 	fsparam_string("pagesize",	Opt_pagesize),
 	fsparam_string("size",		Opt_size),
 	fsparam_u32   ("uid",		Opt_uid),
+	{}
 };
 
 static const struct fs_parameter_description hugetlb_fs_parameters = {
-- 
2.17.2 (Apple Git-113)

