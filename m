Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29CE9C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 19:49:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB5CD22CE8
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 19:49:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UyzndD2N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB5CD22CE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C2266B0007; Mon, 19 Aug 2019 15:49:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 773196B0008; Mon, 19 Aug 2019 15:49:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6891C6B000A; Mon, 19 Aug 2019 15:49:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id 47BA76B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:49:19 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E30001F0A
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:49:18 +0000 (UTC)
X-FDA: 75840216396.04.cloud58_17126b5047d42
X-HE-Tag: cloud58_17126b5047d42
X-Filterd-Recvd-Size: 2601
Received: from mail-ed1-f43.google.com (mail-ed1-f43.google.com [209.85.208.43])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:49:18 +0000 (UTC)
Received: by mail-ed1-f43.google.com with SMTP id h8so3075960edv.7
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:49:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=4EhcvnOZhT13cfHaUo9rAxd0EORmJgQ6Andkuii4PN0=;
        b=UyzndD2NRQCU7HrbGZAai7pRjUlUDaRpZKIJdZYf3lK3zrjAhz/f8zmGu75XY+g389
         YgwYff25e1rlbzmbHevbSZCiSPonxS5PSvfrl1F1R0/Ytf/eTkDG60WVd6zh5QIP12sr
         L+V/FAh/b0vdA/wku7gGHs6ntayw8M/vZlUq5usu2gXOX1yREgAfpFaSH9jGfrPSyFje
         AJI/lxHeZtzDU4Y5Rw4QU5o2Q5kytS+lVapCFfyZ4/N+9zkP1/kGopTJ3yDTtJj/CHR/
         2fFDgr4GZyD5NBObvcgKu2zfTauUu1JJDlHJ/6S+1PS1+3YIaX9SaQiLdHvDwni4HxSv
         +ylA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=4EhcvnOZhT13cfHaUo9rAxd0EORmJgQ6Andkuii4PN0=;
        b=UGfCI+L9CX/sujMkBBceojdXqN3c4EgZTKXR67OZCbC4PHwPGpbHAPk8zC9GpdCRj0
         x9alv53/HIc/N5R4bgKWFshHfZFz8E9HoA6NlQh8p1F6JFkJtdboUzqlbIL90B29peoa
         n4ZVAk89pFobzDhD1edYakrm6Xio2AKiR0tHAYCtXkGRn+3CA3t1Je35EllmCumkJk3a
         ZuWBdrCnDMo4ff9O5ijuw+/y/Tv1lNmPPgLFIKz2UkaCjaiXP2YXZGU4Dl+4gryyf67b
         o02OYIC8rvgF7DzrKsgNzjabwUa5to7h99K+PKJR0I39H9TC5SMScYchK/+B9A1SQdIU
         m15A==
X-Gm-Message-State: APjAAAXbP9qYYHcVcq347SZTE+h1Sxu9l34TEr3qQSYKPvDakXS2/LF4
	xQ1P4GzJDSHQ3MIZmKDa1UKZVMa6LSJmNj2L7W4ihGit
X-Google-Smtp-Source: APXvYqwMepM5aA5lDPBkBK795iWBCz14QVY61TZoJu4cCPThtogZbMrXpg3kohXHt4NR2GETX6OVcXiagCtRb59T20Q=
X-Received: by 2002:a05:6402:154e:: with SMTP id p14mr27207676edx.101.1566244157064;
 Mon, 19 Aug 2019 12:49:17 -0700 (PDT)
MIME-Version: 1.0
From: Paul Pawlowski <mrarmdev@gmail.com>
Date: Mon, 19 Aug 2019 21:49:06 +0200
Message-ID: <CAKSqxP85cbYXt6q72aajXUTombZb-wbEfoWteBQrjJFO890rfg@mail.gmail.com>
Subject: Do DMA mappings get cleared on suspend?
To: linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000129, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
Do DMA mappings get cleared when the device is suspended to RAM? A
device I'm writing a driver for requires the DMA addresses not to
change after a resume and trying to use DMA memory allocated before
the suspend causes a device error. Is there a way to persist the
mappings through a suspend?

Thank you,
Paul Pawlowski

