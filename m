Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDE1DC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:08:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FE04218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:08:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="HGbUe8Q1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FE04218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A6AE8E0002; Thu, 31 Jan 2019 07:08:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 256328E0001; Thu, 31 Jan 2019 07:08:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 145EF8E0002; Thu, 31 Jan 2019 07:08:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C96168E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:08:06 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so2213011plr.8
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:08:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=YS0NO5yiH+hzqGNX25wsvINs96sN7hTYyApoqyUzdY0=;
        b=Yr7MCpM6G8JBO2VxKBqMV0KIDoEq2kvhH2RrmGBr8d0QmfnMukANDidc0OsHfJQWX0
         Bdyyntm62eImBrluKOyZ2ZcoryckxjsTz4AStoWdt1Q9RkCjK1GliVaRIltCELQe/EZ2
         AdtfTHdL2+H6kcIMaT2751bmS2Fmlvp8EPDAo4UElfOhxzi6gS3E/iI/HDWXkqWwZt/4
         YBK1c8i8igP/5T2kupfglqCGVgKONLIlri5p2+c9ChN9gYRCaFhylkeOYtYsC1RoMzJy
         q2NegWyUXiVBUZ8qAIWJGMhi18fEWVkSh/z1EvJf1IMdavr6sFGEMZ8L+cE1aTsjgssA
         F82g==
X-Gm-Message-State: AJcUukcHbG9JUI9PBTJEuWka0weqkuJdnJVu2cO9W3TL14ji+83w07AK
	m2B01fXh56NpRVsbkM2CcnCTgFNc/5QnN0UQmxmAJRtxjINLmzm8Fb5E41hjeFRbCHm+MMxOs5G
	cjG0vZ6/t6wTEKmmVHvoELgSB4u5lTLSWgD13Mcd5DNlQCLvALGCLdsJWxJheAPzitQ==
X-Received: by 2002:a17:902:7e44:: with SMTP id a4mr34596500pln.338.1548936486465;
        Thu, 31 Jan 2019 04:08:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7g4dBg4pcIXygkh5j61UNYap6vIS3SMrqBwPWYhfVpWY8xaD4TVqURSFUyuvpgZaoVraPE
X-Received: by 2002:a17:902:7e44:: with SMTP id a4mr34596459pln.338.1548936485851;
        Thu, 31 Jan 2019 04:08:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548936485; cv=none;
        d=google.com; s=arc-20160816;
        b=bc0oJEAcodmFCP7wGOJX2H9ZA9S8Y9izmFu2BbXxHMnyaamb/VgCWhirnOvlSpUEH4
         F67RtpJfX+K1q/gKzA5Ty+S5GtBmmjTj1R1RvYQ9B6X+7kjEYx6dhgyOnT+twBqWru8/
         oUVw7GnwG4ACPnspvdO0VAWvUW57q5+Od0x6S74/zHe38ZoDiKyP51isA/MZMKoz2JDq
         Kc9efYS7ruV4ppDvmGA6Ppk8BXLLWQv90CwalSGz5kh8B5RXJKw5DMs9thJybTtTrrSJ
         k/+G9uFdfzvw7ZhxZCLIOVCQE0SfkKVcJwBXD5goVRfrpWGrABoipJt2ecDX4qFWBDH7
         LMhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=YS0NO5yiH+hzqGNX25wsvINs96sN7hTYyApoqyUzdY0=;
        b=BFeSVFP3AifzCDvDdkY2aQMXlbY3YjctWZcfgwzzBGHxl8AQiY5mvP7fpVIoAQsFhy
         8wLJIP8PXqwEoruzVIDbDxK6kK01mU8jqHfNDGIr1WHNIUrOLPbxHCSUIuIbh4KmPZRP
         mu4vmw2JbjKbFJfWC0Nnw8pJJmNagXmyEpajZx9odN04yJsfTT9U/VaGRWYIkRPYGueg
         7uCgXCzGcc8yUVEdCq0Anzs8qR61bI/C6O6UQOJpsGb2xfs8PccAa6PBiiTH8du4AE6R
         Qy+3yLYKO5pC4AafVPIGlAKyqKC9Fqkw5BUPji93aNNTOJmQB9SM9iZt5f5GIRWuwwwO
         k1PQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HGbUe8Q1;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 193si4058773pgc.220.2019.01.31.04.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 04:08:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HGbUe8Q1;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from pobox.suse.cz (prg-ext-pat.suse.com [213.151.95.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 823272086C;
	Thu, 31 Jan 2019 12:08:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548936485;
	bh=8xiqhQL74NPCiIrNIibRzSqNG12ZScZrkr4RT+/ftLI=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=HGbUe8Q1y9wvs/YPD5E+gnIYoMx6uM84L7B+qKScVKjTy3XS9bKf3oqMNjO4lIWaJ
	 mtmeCQSycFybNyNiIhRtBCY8yioMvLQ8WsXzv2sI+VsohOMh7wvEnIrEkcA7TZbDp8
	 5qkehS+eB/MhingrKgW+FQP5eleT04QyLDTmX4xg=
Date: Thu, 31 Jan 2019 13:08:00 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Daniel Gruss <daniel@gruss.cc>
cc: Vlastimil Babka <vbabka@suse.cz>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
    Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
    "Kirill A . Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
In-Reply-To: <aea9a09a-9d01-fd08-d210-96b94162aba6@gruss.cc>
Message-ID: <nycvar.YFH.7.76.1901311306570.3281@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz> <aea9a09a-9d01-fd08-d210-96b94162aba6@gruss.cc>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2019, Daniel Gruss wrote:

> If I understood it correctly, this patch just removes the advantages of 
> preadv2 over mmmap+access for the attacker.

Which is the desired effect. We are not trying to solve the timing aspect, 
as I don't think there is a reasonable way to do it, is there?

-- 
Jiri Kosina
SUSE Labs

