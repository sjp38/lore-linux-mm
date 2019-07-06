Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,GAPPY_SUBJECT,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4BDDC48BD5
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 17:32:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D6782083B
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 17:32:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nWzW0LYp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D6782083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24A618E0003; Sat,  6 Jul 2019 13:32:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FA4E8E0001; Sat,  6 Jul 2019 13:32:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E94B8E0003; Sat,  6 Jul 2019 13:32:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id E6EE48E0001
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 13:32:56 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id s9so10365635iob.11
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 10:32:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SEvZkE5vJAPhuJRsrqZsuhS+PD5Zgh6qAYTfG4/9RWg=;
        b=uO0iz815PZpcE6WaUGomVzLcA1kj7v4ZJ30fKcKIR8e3i6Qo1xX70J6L3cnctsmtEo
         o4hOMJqspivIm+MsWJYjNJwONTgvuGRslrG1aV65iKGNfH7Ft8LXtRi6u0Pt3KhvBwBB
         RA2xHEkmHtQFD1lhoLZSA5pJ3AwvbnAuVbUtfbyu2TVQjxojdhLdM0NnF+2r9IYepc6+
         tCYLApdAUOFpBPC3pLcFIQ2OtaoY/tqDL77t7qGm5mDUukrK6QM1jNHsG/Xc621YVr51
         aSRRFjNJg+aK0IsSVs1DRFigEo7ek0z001ua1nElcqt5oOc4YtbPRhGSF+hscaJPh82v
         mX+g==
X-Gm-Message-State: APjAAAXeKgUn8OX6ggyxgEV45vGJ/XYdDf6/nkPjEc5NlBxBuXB/A7+O
	CS7CmLaKqxz+Quydl3E7yD8kuuMv9R5FE/xc99xP6opXz2xl4racYuVvjA1EYEGMUV2fpnVVFuV
	DI3bD850DC73VO5WrRPnNwW74Ev19EKrviqNOvl4BtuEJXDDY42M9QyhzCg1H+jVsUw==
X-Received: by 2002:a5d:9c46:: with SMTP id 6mr1766040iof.6.1562434376755;
        Sat, 06 Jul 2019 10:32:56 -0700 (PDT)
X-Received: by 2002:a5d:9c46:: with SMTP id 6mr1766009iof.6.1562434376219;
        Sat, 06 Jul 2019 10:32:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562434376; cv=none;
        d=google.com; s=arc-20160816;
        b=Z8nHQwzx9HJBJ90h+OkDKlSWze54xi0WojNccTqz7RHBmstjVAp6tFEsszZrT+IPgj
         ys5YxXQeAtulmgNPB6EcDF9SpqFOF3DSKOaBvG9Dn2qkFHR5+s1zpB/oNAo/bLASvogA
         dgM/VpSobMbTizinD/wEyXBLZsq2DUip4Uwunsml9fHZxTcUlGThrJgsHDorDRGXNZnn
         viC/IiAJJeWklI6JeXoOgvRtA0PavOI8I4TGRpqFL8Ob+MH18qNy+g4FsIvoZtA1vPha
         2UbFO9i3M+En8E10F0wO1ecx+Movq0TRjZbdo1DqiZt6XCmYse+K563p6emsdA/XZFis
         7oAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SEvZkE5vJAPhuJRsrqZsuhS+PD5Zgh6qAYTfG4/9RWg=;
        b=ncL2IlWbISDb0227Y21c/vf/X1URSMP0bE7qFB5GHp88LXI3yfhI1EXW9tQcUNLjAP
         tljsNKfObDgjYwEevHZGTZFIPaH+k6eFcd6kbzKU3x6k9BOKTCDMqgREONjMxub6p33u
         cktrRzYo1VQHisWIaryioG3TOtNTa1tsKwVe+4KUeCsVy6ZryxeNpt1UbY2BSV8blDJb
         28aIaYx5infMT5xPhvEUXd+NP2hzWbzjJFiCM5C9lfc9gdTy+x15rijTTUZAGrTkG/tD
         kk543gwlYEZTAUpTL1gnii/wmKbFKDICyP5eZokJJwO9ybhAoEIX1uMpQIapXXz4Lce5
         GJuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nWzW0LYp;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor8871573ioo.94.2019.07.06.10.32.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 10:32:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nWzW0LYp;
       spf=pass (google.com: domain of s.mesoraca16@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=s.mesoraca16@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SEvZkE5vJAPhuJRsrqZsuhS+PD5Zgh6qAYTfG4/9RWg=;
        b=nWzW0LYp8W1LDGaS//1OA1RobxIc5VU0heFAxlgRyqaRrd+E2vAbJ4IWUqPpzxC2NP
         bKxbljkcUx7zP1VqQoZ//yBYx5ZTuHeYNIf4AayhBSngZ3bQdhLc/WHHnhKGTTJLvjS6
         93hrs6Cmz8+cxn3rWw4bx5pAEk8hwA/RlID/aaMy9V1EtaLHrJil1i9raoOLYqwLqkab
         UVl8m8aB3oFCRjd8RLByYm/s1DnzV+V9DBXfXeS8YRUtWDdyroDxYWReVoDcXVz7Tub9
         PRKECViw+UqsNKcfLdE9qKgy5flzI/E4UCiF1ey1IluSuOVuvdYTTkNK7mVigb7uFnfw
         mBQA==
X-Google-Smtp-Source: APXvYqyZhsWPUJypEBlw3iOzCCnc0Z8Ysl6psPw4ayKhk+owN6/VPWptNgnm20i2NBMKtNRWNVS5yDY40eR5lXoOP6Y=
X-Received: by 2002:a5d:940b:: with SMTP id v11mr2834210ion.69.1562434375888;
 Sat, 06 Jul 2019 10:32:55 -0700 (PDT)
MIME-Version: 1.0
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
 <1562410493-8661-2-git-send-email-s.mesoraca16@gmail.com> <4d943e67-2e81-93fa-d3f9-e3877403b94d@infradead.org>
In-Reply-To: <4d943e67-2e81-93fa-d3f9-e3877403b94d@infradead.org>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Sat, 6 Jul 2019 19:32:44 +0200
Message-ID: <CAJHCu1+hmA6cPH78KArA2PYwWcTy6US3Ja5XcNVy1bkamddjfQ@mail.gmail.com>
Subject: Re: [PATCH v5 01/12] S.A.R.A.: add documentation
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-kernel@vger.kernel.org, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, 
	Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, 
	James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>, 
	Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Randy Dunlap <rdunlap@infradead.org> wrote:
>
> Hi,
>
> Just a few typo fixes (inline).

Hi Randy,
thank you for your help!
I'll address these and the other fixes in the next version of the patchset.

Best,

Salvatore

