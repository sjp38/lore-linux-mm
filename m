Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2901EC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 20:12:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8D92218A1
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 20:12:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="His8f3pj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8D92218A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 721588E0003; Wed, 27 Feb 2019 15:12:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D0598E0001; Wed, 27 Feb 2019 15:12:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 598B88E0003; Wed, 27 Feb 2019 15:12:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E34E8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 15:12:23 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id o56so14962141qto.9
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:12:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=ZTxkyP7MX2AvS9u1TFjA+FXPrStBYSRU8F/HnJNz8r8=;
        b=AO3vwLWXjMJvOXByFk8L+dSl4HQ/h938EzLCxG4jqgLn0jiIU1ljzRjRdA5hpVutej
         ZTV9aUgK6rqsB9S46Vt/bFEFTMhAjRFUp4jGM/Fjgvz6EFFcrqBZX/KkANY3jFIAvl2n
         808172xeDeqNgOzC5dyzBGw8mtY2AnrDz0UdKPCJCSUXKGy7jGLarQ//y+zkTvbbADoI
         jy4TlG4MyXzjnMxJhkRz9/skP1BVmHCAtsIz7gh0oGlXYGAghfkBxtqqFma8ulRoJywC
         s2504KL6WrOw7LZXPfddd9/VuGRDTEL513yvvh4j/mNyRd9hQLqlkOT4B+e270bGYd94
         iuNw==
X-Gm-Message-State: APjAAAXuGv03yOATtExKodFKpr2aF19aEvsYIaLc84TpIN1lwJJpWLb4
	P/YJMHDY3ygiFM2niaWVQunPgMT7M7XNRMZEk9XVtiJOZqy7Ybf1PQBzsbkzjDLOzAr/+zwX7ko
	WfGEGaA8sQlTbsCim9v6NqESmtal8yHuikUbUCD0TrrAe1xSaKI5u51wii4n+4Hb9+Vmw5CTHL5
	3jDKkna32K1/ddXZCZsJdDM6t8F8y+lH++MHmnDGmfeIk6wtSnqLh6qbA8hjMl7TgdzPs4pF2bK
	P5dNi9dR7LQXubKUL++p22IT2Iz1N23JIPfi223EGsqLxgtC4+A6IiVKEhUjqze/TSnqB3x0Di8
	UwLUEPoUKxtv5fqGThRCQTBy+Znw9pVcJcf5VwFCZJ6NXLWW/U/NYdLC57E6XSsiXY6+GjMzzyG
	Y
X-Received: by 2002:a0c:88c9:: with SMTP id 9mr3393071qvo.178.1551298342874;
        Wed, 27 Feb 2019 12:12:22 -0800 (PST)
X-Received: by 2002:a0c:88c9:: with SMTP id 9mr3392995qvo.178.1551298341736;
        Wed, 27 Feb 2019 12:12:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551298341; cv=none;
        d=google.com; s=arc-20160816;
        b=cGyNatKmPGWl07oktRQkZ9dK0p0+s7swhV9B6OY6s1s7qKjvL4pvnpz8jcNDXXXO9T
         0Nr1LCOItdgd6P3EwkW2EOeAPHTSttfSL6mTCMUpYULSFXsI3TyH8TR8+Sq2M+Y0i8QS
         UNJjPTt4dhuuHqlXOqJyIvpEHNT36W8nvmsFg9iZLKObp0QZVE8SD8neBJlKnl/TeS8X
         VkErm1T4XblEhoTqqt1g2GV0ZIny5jxKDVxWeax3AtL5lPegiQMJHUHqMoLGBk+lp8I4
         jb30vYNU97OqsJzy3YDKe0q6gghJrbBg2j/N3Ggy+YIDWerEq8sumoIfQtEpg3RBaLij
         b7GA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=ZTxkyP7MX2AvS9u1TFjA+FXPrStBYSRU8F/HnJNz8r8=;
        b=sF0NmzRrPc8qp13wjF3TlA1bNrqe7jsVO9FwlNvueAZ7oPYYYt7aJQG5yJbHX3XZxS
         6H0rXlg59/rXF3msX/TybQEBwLyE6SkKkgQzyh8PVpYQECAyiJjeiJcbpUqG+ByrTheb
         UeyN9maMmmu0CNzFjk8CAEsdo69asc6954hM7zGVkf61ZL2JN95FGLIhcNGHO74WK8xH
         0MA3r02/ujG3mfLpV/mOi02RsLMigYuNr8wWuhBCH1JqPxxLD6yQdYpRg7A+OlIgJNrh
         Aj4BFsJ+38MjJy146R4DLRt6dRaP0B3ZaN9mfRU81Jfc1HXNKmz6HnLY+e6ngkaHhVIT
         KpHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=His8f3pj;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1sor10431978qka.119.2019.02.27.12.12.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 12:12:21 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=His8f3pj;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ZTxkyP7MX2AvS9u1TFjA+FXPrStBYSRU8F/HnJNz8r8=;
        b=His8f3pjjg9z3yTcOTRS1nqVxgQzrIguuuVsWBVL9CXK3UYQ+fzUxfi/AfrtujyIs6
         uzXXVHJdJPn3mnbJ2HTUxZZaDtfY/i/2e1DUzDvgz4A26v0JWTRC7QngEnIFoCDg0CKC
         tduYVbavNEPNgMwlpMB/wuI1isdNpLgtzAUF3Yzd/LwxWdCRcgnFLk5h4aC89WKG4Cz9
         YH2n1geJfgZZBMTri2o73/gMeF9Ydbwj5hBGCn0zV23fYaSNcK6K4fNzUUzINaovRQ6s
         5hpgG5OUaRWMGzv4XMpOcigjpgRZc5Eyvlj1gJctIOjxzl7+rRlAv01/nM3jr+57V8c8
         CqAw==
X-Google-Smtp-Source: AHgI3IZpEx4+Dk35xm0gudLF7+nvka/QYL7y/lhNAmqZvg4YCx2SGwWvIS0FRcp9tH1jhVAiK0vMBg==
X-Received: by 2002:a37:4f45:: with SMTP id d66mr3695557qkb.81.1551298341321;
        Wed, 27 Feb 2019 12:12:21 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id o51sm7294040qta.24.2019.02.27.12.12.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 12:12:20 -0800 (PST)
Message-ID: <1551298338.7087.5.camel@lca.pw>
Subject: Re: [PATCH] tmpfs: fix uninitialized return value in shmem_link
From: Qian Cai <cai@lca.pw>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, "Darrick J. Wong"
 <darrick.wong@oracle.com>,  Andrew Morton <akpm@linux-foundation.org>,
 Matej Kupljen <matej.kupljen@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
 Dan Carpenter <dan.carpenter@oracle.com>, Linux List Kernel Mailing
 <linux-kernel@vger.kernel.org>, linux-fsdevel
 <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Date: Wed, 27 Feb 2019 15:12:18 -0500
In-Reply-To: <1551276580.7087.1.camel@lca.pw>
References: <20190221222123.GC6474@magnolia>
	 <alpine.LSU.2.11.1902222222570.1594@eggly.anvils>
	 <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com>
	 <alpine.LSU.2.11.1902251214220.8973@eggly.anvils>
	 <CAHk-=whP-9yPAWuJDwA6+rQ-9owuYZgmrMA9AqO3EGJVefe8vg@mail.gmail.com>
	 <CAHk-=wiwAXaRXjHxasNMy5DHEMiui5XBTL3aO1i6Ja04qhY4gA@mail.gmail.com>
	 <86649ee4-9794-77a3-502c-f4cd10019c36@lca.pw>
	 <CAHk-=wggjLsi-1BmDHqWAJPzBvTD_-MQNo5qQ9WCuncnyWPROg@mail.gmail.com>
	 <1551276580.7087.1.camel@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-02-27 at 09:09 -0500, Qian Cai wrote:
> On Mon, 2019-02-25 at 16:07 -0800, Linus Torvalds wrote:
> > On Mon, Feb 25, 2019 at 4:03 PM Qian Cai <cai@lca.pw> wrote:
> > > > 
> > > > Of course, that's just gcc. I have no idea what llvm ends up doing.
> > > 
> > > Clang 7.0:
> > > 
> > > # clang  -O2 -S -Wall /tmp/test.c
> > > /tmp/test.c:46:6: warning: variable 'ret' is used uninitialized whenever
> > > 'if'
> > > condition is false [-Wsometimes-uninitialized]
> > 
> > Ok, good.
> > 
> > Do we have any clang builds in any of the zero-day robot
> > infrastructure or something? Should we?
> > 
> > And maybe this was how Dan noticed the problem in the first place? Or
> > is it just because of his eagle-eyes?
> > 
> 
> BTW, even clang is able to generate warnings in your sample code, it does not
> generate any warnings when compiling the buggy shmem.o via "make CC=clang".
> Here is the objdump for arm64 (with KASAN_SW_TAGS inline).
> 

Ah, thanks to the commit 6e8d666e9253 ("Disable "maybe-uninitialized" warning
globally"), it will no longer generate this type of warnings until using "make
W=1" due to the commit a76bcf557ef4 ("Kbuild: enable -Wmaybe-uninitialized
warning for 'make W=1'"). Anyway, the generated code is the same using clang
with and without this patch.

    d_instantiate(dentry, inode);
4eec:       94000000        bl      0 <d_instantiate>
            ret = shmem_reserve_inode(inode->i_sb);
4ef0:       2a1f03e0        mov     w0, wzr             <---- ret = 0
    return ret;


