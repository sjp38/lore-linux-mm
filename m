Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10829C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 07:08:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9B1020870
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 07:08:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="KaAhDXQQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9B1020870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 537338E0002; Fri, 11 Jan 2019 02:08:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BEA98E0001; Fri, 11 Jan 2019 02:08:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AE618E0002; Fri, 11 Jan 2019 02:08:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id C48AD8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:08:29 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id h11so969998lfc.9
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:08:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=APfuF3eni2ygNP5lvzz/+mFQk3/YqgPBk1fCHYe99PQ=;
        b=bXoVdml1Uc9VyhuRmbimZ818eg+oFU5jxP/2Zhi8NT6XHxH+758gCv9Vlvxs/V4jQS
         QXIpQOUM1E6ic118PXTzuLpQjHSwlcufTspk+PkGwGyPewewsJVf6VN3bMBALu2vjiZx
         CzGpZcP4l1whQMvoCDU9/FgOwL7NoyeCI+S+FTkWZ982/0rpECRASrQX9dsXTTjeI2As
         1n7gonMz/nZif6912/kuRA23kTMg8cQRMd+6r4ifBbpvUfIAkqvPvS9/fxkYgl+gcmGp
         DEep1hV/IC8VQobh9T2EfBF87mDuX4EzX1/N+M+xp2N9xBr8Sr6H+aOy8V5wbYK4jPRD
         jCGQ==
X-Gm-Message-State: AJcUukd8zaeLX7DjFQBNagBpWQxeqv2VN1N/4SPdMMQm8HriSiqNIrzQ
	pjKKYlyCGkvVyUNsGTL4jlgxpSNbM7WlLfkh80/c/u2k0tnXBLp8DYi68cqYyBUD0sAT839fdGG
	rU/7quVE4TA+gN2rJnifTpuPpwIJ3U+LNYCoZsQRcbqRYdxnI9gLIVbUWf6aVUUejiZmda1PPQW
	0GIoDQ6R4VOhrnq2/hfDexVFeSKhNRj7T9D/Yy1kbBLKbvQjVZLm+NFQnmjbF8G6Rs5DlN4lEkz
	hul+O7tPT5pWscg+14xABAgTIlED03uHu2D3tm/ceRHqhjMdB1LmtBGxb5aHtjHYmGbcJHHgnJn
	BPyt62Fj5LPZoYvPDlXeIFkJCdkuZcr3gkOd55LDzDT/hFeQicQHiq/+yU+ZSJSxM9qt8cjqMTU
	M
X-Received: by 2002:a2e:b1ca:: with SMTP id e10-v6mr8588171lja.16.1547190508964;
        Thu, 10 Jan 2019 23:08:28 -0800 (PST)
X-Received: by 2002:a2e:b1ca:: with SMTP id e10-v6mr8588119lja.16.1547190507832;
        Thu, 10 Jan 2019 23:08:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547190507; cv=none;
        d=google.com; s=arc-20160816;
        b=z43rruUnzktiXzhCpkfAVTjZPmjalVH84d8xd4gNxas9ZCUmFcdpMHWNhqKSn/NDTo
         OyGw4ToFuUesGhSMNYwAfJTZmNetCnWG7wxvYtNW2kPSz315Zn4L8jyAC8t5pkzlLnj2
         e2h7Ki4YfLu+kOOnbaMGlmy5A9AYMgmTHKi5ZskWh4fbdh7DyLB8vJDqsErkOIMYL3us
         +wzEABQk2ZZkUGGwrRiy6hgcsHtpRsNmYZB7omhnVQM4yPF6bqCiyRNsA2dHH2Yuuj0a
         DVmiyCP3vGMD0nku50LAu7+oxmaRsNCCzN05D0NAo/jUoo2TDNbH+TxDmpjoriu0QmFY
         Hxyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=APfuF3eni2ygNP5lvzz/+mFQk3/YqgPBk1fCHYe99PQ=;
        b=Di5NCz/8nLR6Mj7o+jxDdfH0Hpfl4sYnWFtJ6GDCHD3kqM4Xefa8pAaA8DZeDhg2NJ
         U+Ohs66PU1KAoBfl2nHPACEQmunsyQ8Gr7jODtvTrhHvoBys1mtCjgM+kn8O981o1yYI
         +urB6gjMhj0ghPopzlgXoFGPE0HA4J8aAHbnGLv39ZurKkQXP4Oi6Sm02epmtLJNxYiS
         GxPCWsj2xsyIhBAk8FPeMqjvltLYVdNgdhyQwL442LTaliBxruNqwHFXGcWQYOduBkBi
         nheqT7tS/btEPwocqoUrs7fGTZ1RInGOiaVs7Gup34ek9eS97PBshzIia4stUMU0W+ZR
         QlLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=KaAhDXQQ;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13-v6sor45513079ljj.25.2019.01.10.23.08.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 23:08:27 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=KaAhDXQQ;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=APfuF3eni2ygNP5lvzz/+mFQk3/YqgPBk1fCHYe99PQ=;
        b=KaAhDXQQhxGTkyOQB6Zh58GYoR47yKzSYXFs3Y79Su2l+DQ8IGmpxW63UNcyPJHGvv
         wQSnFdupBpBf5kL/saiWXY7SVolfqC+pL7zukscGHF4TCC1oK0Iksd3zAdJbCDOUP4Iz
         vb6CbuwOenMcanKm1zjhmiiAMFArdcfsSSBsk=
X-Google-Smtp-Source: ALg8bN7+X7zjtF0mobbdjDS7YUUDFD/OP/ObPYiloXQB9Fpy8bHaz8o2I5HprkC01jywKSITO4THEw==
X-Received: by 2002:a2e:9181:: with SMTP id f1-v6mr7573524ljg.64.1547190506027;
        Thu, 10 Jan 2019 23:08:26 -0800 (PST)
Received: from mail-lf1-f49.google.com (mail-lf1-f49.google.com. [209.85.167.49])
        by smtp.gmail.com with ESMTPSA id q6sm14280660lfh.52.2019.01.10.23.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 23:08:24 -0800 (PST)
Received: by mail-lf1-f49.google.com with SMTP id c16so10076630lfj.8
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:08:24 -0800 (PST)
X-Received: by 2002:a19:6e0b:: with SMTP id j11mr7920507lfc.124.1547190503820;
 Thu, 10 Jan 2019 23:08:23 -0800 (PST)
MIME-Version: 1.0
References: <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard> <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard>
In-Reply-To: <20190111040434.GN27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 23:08:07 -0800
X-Gmail-Original-Message-ID: <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
Message-ID:
 <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dave Chinner <david@fromorbit.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111070807.Duz9Kw44q2e-mg-WNSfzNq3oEv8jyN5jBAMa7CJuBSk@z>

On Thu, Jan 10, 2019 at 8:04 PM Dave Chinner <david@fromorbit.com> wrote:
>
> So it will only read the single page we tried to access and won't
> perturb the rest of the message encoded into subsequent pages in
> file.

Dave, you're being intentionally obtuse, aren't you?

It's only that single page that *matters*. That's the page that the
probe reveals the status of - but it's also the page that the probe
then *changes* the status of.

See?

Think of it as "the act of measurement changes that which is
measured". And that makes the measurement pointless.

              Linus

