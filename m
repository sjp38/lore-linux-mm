Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFDF4C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:09:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57E812083D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:09:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="dDkDuv5m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57E812083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFEEB8E0003; Wed, 27 Feb 2019 09:09:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D843D8E0001; Wed, 27 Feb 2019 09:09:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4CDB8E0003; Wed, 27 Feb 2019 09:09:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9566C8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:09:44 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z198so13288527qkb.15
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 06:09:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=JDwKNo4Q1ugW00DDQqC89MJQTNZtVSoArGLMFxH2zRs=;
        b=TxFckvG+ertO5OmRrX+zkjJuTCtyRXnc1pT4xIqajimOSeI7cpZpASh+ZBK9Donk0b
         QHNdhO2nOaTctoDT9kJi1BScAhBwuuepUbOhhhNj9+vaITE433WsqHibJPa7t7Avg9Nj
         BewjQLHPC5VhmyHxK6Fve8FMBTq8jtVRQ71BEUvYyk2MLgW6WtFWct7trCnKALLMdC7F
         9X0DFWYzu1H/GhozdTqlYCGOpmOEAJcwr4NFjhdaQNLqugR08NvJskNwOLzr1F2AFx6q
         AL9Ne9cUa2ZMjnFf/gNS3sDuKykDKlc6LPG6KV/+vQKMZmqJmFlg+ZWdFSYT0riMXKE/
         iYaQ==
X-Gm-Message-State: AHQUAuawf2MDIKByVHoi9tlm1Vz39bvPU7eyVmMtF1sUnAS5k9AGTOmL
	nTNq2YzF7P0aYnnsT9blKDHq4nW5ypKmvDIySo+vzoiny5SH8QCqeVoWZDk13ijiTPATvZ0bA4j
	An1Fx3hPGU7MHUNOhe4tPM32T5Hzda3iqmCEHFi1C4wGVPncKXbWJD1VcyZ76vUNU7r5Aw1WV2h
	JlMhUgD7R4tO6kd75JDbd9XY6t+MqNmXOFABSzrsSMrnFw0/juiu2Lwg7jrTw08zhdF+j3grWC4
	6NkvqzoNNDcwXvS+PPl8odbgqNA5wfgsfd3Z1F+oblfHdzUC/4CwYFFHfEUVkZkVOWhIR1qXS5h
	dm+ccTxVzT6UsdtI876LJXzxzSIZY4qyRlOBva9LAOQ6/+N2ylEmmN3Hy0039oq8L2qjmNfWw99
	A
X-Received: by 2002:ac8:1a64:: with SMTP id q33mr1833222qtk.274.1551276584298;
        Wed, 27 Feb 2019 06:09:44 -0800 (PST)
X-Received: by 2002:ac8:1a64:: with SMTP id q33mr1833127qtk.274.1551276583132;
        Wed, 27 Feb 2019 06:09:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551276583; cv=none;
        d=google.com; s=arc-20160816;
        b=Ny7L3JMXpd2aPp3EqDUkAGvuPjScIxKMAEWLF882d3+UW10Z3dc1TJisvZmFeiQE+h
         hFjwP0FmDTgDo7tn8QWzqN99hjS2dv8YhI761sCH/1IK+TmS1NERRO7mW/sqGKxaz1ig
         I47sEtuvQM4bv0bpikE8BLz+c/2b2Cx/lWgYBu+GY4CM4O1acKmnHatAxWOFWWnH4OZ0
         zqz8g5lt8YE3UnnWwaOk0ie4S4ZtAW3fCZePLrvTRW2ScD73icuWhywuvNw70Xmq9KPp
         6NuCqYiAFazi8Ljd4jq6hUz/hQ2tKRlqdzAj5jMQDR/yeiommQZ90Rg5iu/5236uNUjk
         T6Lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=JDwKNo4Q1ugW00DDQqC89MJQTNZtVSoArGLMFxH2zRs=;
        b=tFcNJ2TBqBfXhWWSuPDS5jiyIlK/n7YiXij99fTK5VXXwGuFl+rTXIuNYxzY8Jzrpz
         YeDrVU6NXEudfOqO8f6eyAzdpTwZZI67h3ZMFUrjRuwq+xZ4GwdivQXZ0YR13Wniuuoq
         zKYHTLH0ElZFRadky2YT8m51CHtnFIUrjNJfBXzlNKx3IM8fkIyo85KcAynq99mJ2eec
         /3ONIvCQKruOMetm0WXQ8oOQ5kDXmuLIaaovwDm8fYCy/BS/OxMvxsGhXrd8A2tEpx7d
         Y1dg7RJs87cc7ySZM0Fst27cQsA3qtZPjLEvryoIbpey14o1g30AKBDw/BNPaWweWUR8
         jEHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=dDkDuv5m;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d127sor8862499qkg.114.2019.02.27.06.09.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 06:09:43 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=dDkDuv5m;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JDwKNo4Q1ugW00DDQqC89MJQTNZtVSoArGLMFxH2zRs=;
        b=dDkDuv5mievBTLrLh0a6kPCLvcttWxQRHOZHcmFRX5LzxlI879UKPFmgR+zlZU7eUi
         wydriob7LhTjRjZVfnQrnzEnPLgBVoXdwzGYtISIW4ntLMVE/9JIcVrtrxgfC9rwcPj8
         Mvz13VqJ9GDMS2igwKnjZb5OHR9RYHHpGA1qstteWRyIKIDZILuPjsnKL9rghoMkpU1R
         46l9S1fryRvZXVoOXdp7kO603tJhuc4ujfJCbjE7fePStI3eBf4P3XCjdhb+s5aVNYZt
         FJl2Z2P4kfHrNAJ4qC7ov9LWUtD7s/3JQShdyV2wPYsjIAOLrelQxJJP1MILcf6ZS4Jb
         sKhg==
X-Google-Smtp-Source: AHgI3IY9PZN/dSGRZlYObwCFODMzKfeM7FT6Yrwc+TwCy8NYeM9JtopE27+gLlfRhzdWpTldtRmnlg==
X-Received: by 2002:a37:a316:: with SMTP id m22mr2322448qke.194.1551276582817;
        Wed, 27 Feb 2019 06:09:42 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 70sm19121483qkb.39.2019.02.27.06.09.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 06:09:42 -0800 (PST)
Message-ID: <1551276580.7087.1.camel@lca.pw>
Subject: Re: [PATCH] tmpfs: fix uninitialized return value in shmem_link
From: Qian Cai <cai@lca.pw>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, "Darrick J. Wong"
 <darrick.wong@oracle.com>,  Andrew Morton <akpm@linux-foundation.org>,
 Matej Kupljen <matej.kupljen@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
 Dan Carpenter <dan.carpenter@oracle.com>, Linux List Kernel Mailing
 <linux-kernel@vger.kernel.org>, linux-fsdevel
 <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Date: Wed, 27 Feb 2019 09:09:40 -0500
In-Reply-To: <CAHk-=wggjLsi-1BmDHqWAJPzBvTD_-MQNo5qQ9WCuncnyWPROg@mail.gmail.com>
References: <20190221222123.GC6474@magnolia>
	 <alpine.LSU.2.11.1902222222570.1594@eggly.anvils>
	 <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com>
	 <alpine.LSU.2.11.1902251214220.8973@eggly.anvils>
	 <CAHk-=whP-9yPAWuJDwA6+rQ-9owuYZgmrMA9AqO3EGJVefe8vg@mail.gmail.com>
	 <CAHk-=wiwAXaRXjHxasNMy5DHEMiui5XBTL3aO1i6Ja04qhY4gA@mail.gmail.com>
	 <86649ee4-9794-77a3-502c-f4cd10019c36@lca.pw>
	 <CAHk-=wggjLsi-1BmDHqWAJPzBvTD_-MQNo5qQ9WCuncnyWPROg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-02-25 at 16:07 -0800, Linus Torvalds wrote:
> On Mon, Feb 25, 2019 at 4:03 PM Qian Cai <cai@lca.pw> wrote:
> > > 
> > > Of course, that's just gcc. I have no idea what llvm ends up doing.
> > 
> > Clang 7.0:
> > 
> > # clang  -O2 -S -Wall /tmp/test.c
> > /tmp/test.c:46:6: warning: variable 'ret' is used uninitialized whenever
> > 'if'
> > condition is false [-Wsometimes-uninitialized]
> 
> Ok, good.
> 
> Do we have any clang builds in any of the zero-day robot
> infrastructure or something? Should we?
> 
> And maybe this was how Dan noticed the problem in the first place? Or
> is it just because of his eagle-eyes?
> 

BTW, even clang is able to generate warnings in your sample code, it does not
generate any warnings when compiling the buggy shmem.o via "make CC=clang". Here
is the objdump for arm64 (with KASAN_SW_TAGS inline).

000000000000effc <shmem_link>:
{
    effc:       f81c0ff7        str     x23, [sp, #-64]!
    f000:       a90157f6        stp     x22, x21, [sp, #16]
    f004:       a9024ff4        stp     x20, x19, [sp, #32]
    f008:       a9037bfd        stp     x29, x30, [sp, #48]
    f00c:       9100c3fd        add     x29, sp, #0x30
    f010:       aa0203f3        mov     x19, x2
    f014:       aa0103f5        mov     x21, x1
    f018:       aa0003f4        mov     x20, x0
    f01c:       94000000        bl      0 <_mcount>
    f020:       91016280        add     x0, x20, #0x58
    f024:       d2c20017        mov     x23, #0x100000000000            //
#17592186044416
    f028:       b2481c08        orr     x8, x0, #0xff00000000000000
    f02c:       f2fdfff7        movk    x23, #0xefff, lsl #48
    f030:       d344fd08        lsr     x8, x8, #4
    f034:       38776909        ldrb    w9, [x8, x23]
    f038:       940017d5        bl      14f8c <OUTLINED_FUNCTION_11>
    f03c:       54000060        b.eq    f048 <shmem_link+0x4c>  // b.none
    f040:       7103fd1f        cmp     w8, #0xff
    f044:       54000981        b.ne    f174 <shmem_link+0x178>  // b.any
    f048:       f9400014        ldr     x20, [x0]
        if (inode->i_nlink) {
    f04c:       91010280        add     x0, x20, #0x40
    f050:       b2481c08        orr     x8, x0, #0xff00000000000000
    f054:       d344fd08        lsr     x8, x8, #4
    f058:       38776909        ldrb    w9, [x8, x23]
    f05c:       940017cc        bl      14f8c <OUTLINED_FUNCTION_11>
    f060:       54000060        b.eq    f06c <shmem_link+0x70>  // b.none
    f064:       7103fd1f        cmp     w8, #0xff
    f068:       540008a1        b.ne    f17c <shmem_link+0x180>  // b.any
    f06c:       b9400008        ldr     w8, [x0]
    f070:       34000148        cbz     w8, f098 <shmem_link+0x9c>
    f074:       940018fd        bl      15468 <OUTLINED_FUNCTION_1124>
                ret = shmem_reserve_inode(inode->i_sb);
    f078:       38776909        ldrb    w9, [x8, x23]
    f07c:       940017c4        bl      14f8c <OUTLINED_FUNCTION_11>
    f080:       54000060        b.eq    f08c <shmem_link+0x90>  // b.none
    f084:       7103fd1f        cmp     w8, #0xff
    f088:       540007e1        b.ne    f184 <shmem_link+0x188>  // b.any
    f08c:       f9400000        ldr     x0, [x0]
    f090:       97fffcf6        bl      e468 <shmem_reserve_inode>
                if (ret)
    f094:       35000660        cbnz    w0, f160 <shmem_link+0x164>
        dir->i_size += BOGO_DIRENT_SIZE;
    f098:       910122a0        add     x0, x21, #0x48
    f09c:       b2481c08        orr     x8, x0, #0xff00000000000000
    f0a0:       d344fd09        lsr     x9, x8, #4
    f0a4:       3877692a        ldrb    w10, [x9, x23]
    f0a8:       94001828        bl      15148 <OUTLINED_FUNCTION_193>
    f0ac:       54000060        b.eq    f0b8 <shmem_link+0xbc>  // b.none
    f0b0:       7103fd1f        cmp     w8, #0xff
    f0b4:       540006c1        b.ne    f18c <shmem_link+0x190>  // b.any
    f0b8:       38776929        ldrb    w9, [x9, x23]
    f0bc:       94001a4a        bl      159e4 <OUTLINED_FUNCTION_1131>
    f0c0:       54000060        b.eq    f0cc <shmem_link+0xd0>  // b.none
    f0c4:       7103fd1f        cmp     w8, #0xff
    f0c8:       54000661        b.ne    f194 <shmem_link+0x198>  // b.any
    f0cc:       f9000009        str     x9, [x0]
        inode->i_ctime = dir->i_ctime = dir->i_mtime = current_time(inode);
    f0d0:       aa1403e0        mov     x0, x20
    f0d4:       910182b6        add     x22, x21, #0x60
    f0d8:       94000000        bl      0 <current_time>
    f0dc:       b2481ec9        orr     x9, x22, #0xff00000000000000
    f0e0:       d344fd29        lsr     x9, x9, #4

