Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4321FC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 21:25:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 023E22145D
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 21:25:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="T1RtYY+H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 023E22145D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A54916B0003; Mon, 15 Jul 2019 17:25:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DDCB6B0006; Mon, 15 Jul 2019 17:25:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 857956B0007; Mon, 15 Jul 2019 17:25:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 484AC6B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 17:25:27 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o16so11221506pgk.18
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 14:25:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vGon3ATt/7W/iMCxhCNIhXvyVdMGXaZNpkEgJTpgP9g=;
        b=Z8p3o2ZPx0KJY6oS3bIqH+msiwkbY/iMiHlz86y9I/riRzzKy04E5rI5nthhpJJXkn
         2ZB8cuxDnOgj6ON+gRu66+6AaFbBC5QLyD02tnHkQvLc7PjRDL1nJoe36XlpnGDpljHO
         A7fwXhLFkoCO43W6uSWqG7rwCsIyW+oI7nn69cHopTB3CrxvxphnVrjaXU+nO7urn6nG
         O6hPWKneAJqXebBcdJUyPnszKZn+EvDB7DXIAI1BDBf6dRwZsShiz2J8OQ6jDAK3l/vi
         A9eCX1r3QbJqFBfuOg6mjTcIsJmSAgLsr09KMt9OAYBGgUy2jp2RCxFLnkOLK84WFRNl
         trhg==
X-Gm-Message-State: APjAAAV14HErXNLpAplh2CQAyZlUucB+F6FrPNw/YI3bkoNe9Jn51dwe
	twnl6u8pFVJguHOOqoBRoBKTUtLmPiScrMwZphX+UDGP5lZnGnVD6zn8P5jJ0e2D/k9ekT7rFvt
	2ol64AWk4+YT6KwysE/ORBNsX9gSw5WwDszfan6BjjSgBogZV+oCvCB4ZKngsLdNefw==
X-Received: by 2002:a63:b102:: with SMTP id r2mr28794617pgf.370.1563225926830;
        Mon, 15 Jul 2019 14:25:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/7XOxseIC6SAkPR79y2iskfmlnTQdVrLSfAFs9dZdyPssU+DMnuQ0AwY+W2mOt6PpaAp9
X-Received: by 2002:a63:b102:: with SMTP id r2mr28794558pgf.370.1563225926004;
        Mon, 15 Jul 2019 14:25:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563225926; cv=none;
        d=google.com; s=arc-20160816;
        b=eRYE0aA+oJOdkI6uCb11qzvcwzKLo7+wguWv0vTaF6ZsScdkMTzt7FDAHx8DbBS5qf
         iPWQhB/Wdlha3bFum083OFjBBe9/gLJS2Es3XVz3YeC/aOLEBnsoliAv+aYlXDHdAPoI
         v1NU9Gus7FQTP3X3wRUaYxD4raIwKQIck7LfLefYMTwruQ5+UsJe+DNyPWvgLcD1Lebe
         Exe+8XXI7nuZt/0ykChWraS5MgZGiWVYaJkTW7SML6vQZYCEhARovnlcSGL7ysqnOZNq
         58BULCY55s1MxOq+KU8hE96pXb5zercAQ7WGLU2OQ2OnilMuqV1SdJ6cH0pIU4h8K1Xx
         yPlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vGon3ATt/7W/iMCxhCNIhXvyVdMGXaZNpkEgJTpgP9g=;
        b=xfWSDhbUmdqfPBL1Dlvy/MdueJqg2xPQbaMPb7heKc10jDBdAyNMt8VEddEZz3RRAY
         57AuzKTbp0ZR0WA5bMdThLryTfudRXtBlgHTHM5osnZofwPGFHpWO61yM/ITg0daVcfi
         uVIAogqU/js/eJmG6M2MauE9RT7urccRD/CDPTs2gVMovgMllMRqQirOYpnzTDRZX71X
         /SJzxxmQZbO980EDDOMSggyoqpeDPLmsGshPhrgp2M6HrYbABUvZ2HlmMQxr7pdoJnXE
         kf2yM38Z83x+n+pvcYFu5bnkWKZYOV5URXff4/sU0EvVA4WYHXJ6ZESFR6r4Tg5eL78G
         g1Og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=T1RtYY+H;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a16si15952922pju.24.2019.07.15.14.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 14:25:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=T1RtYY+H;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 78B7C206B8;
	Mon, 15 Jul 2019 21:25:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563225925;
	bh=gu5L//UCY90oTE7oYavnazchCMSkZepvdlSpPTeCuZw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=T1RtYY+HJJpAjuysHg6gP4dkiE3BuBBpABr+5IMyGEe+QCozDkKo/h9T7kyeJvsot
	 PvYU7YEfvM1NzcVoTs8luyeDs0HtS3POfO5V5adbDYe36go1azq2HGUuxRY3lPjCvW
	 e75m9JKCKAVlIgZGP9gKdktG2zvG/KTsYn/om7gs=
Date: Mon, 15 Jul 2019 14:25:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: howaboutsynergy@pm.me
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Mel Gorman
 <mgorman@techsingularity.net>
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-Id: <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
In-Reply-To: <bug-204165-27@https.bugzilla.kernel.org/>
References: <bug-204165-27@https.bugzilla.kernel.org/>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 13 Jul 2019 19:20:21 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=204165
> 
>             Bug ID: 204165
>            Summary: 100% CPU usage in compact_zone_order

Looks like we have a lockup in compact_zone()

>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 5.2.0-g0ecfebd2b524
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: howaboutsynergy@pm.me
>         Regression: No

I assume this should be "yes".  Did previous kernels exhibit this
behavior or is it new in 5.2?

