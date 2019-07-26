Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87411C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:02:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 405F822CB8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:02:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2UhTedPZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 405F822CB8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 092578E0006; Fri, 26 Jul 2019 19:02:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 042E88E0002; Fri, 26 Jul 2019 19:02:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E735E8E0006; Fri, 26 Jul 2019 19:02:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C08128E0002
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:02:41 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id p29so25703970pgm.10
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 16:02:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BEx2zcFeEtfAB4XQfFJwjvl+7gtayffTdx0wL9QSa1o=;
        b=cwW6jgIeZ0Xsl7691cTzpy8e4rrU4TbjVpqmLrK9rOkdwwNT+PnS0ZUr3fIslQuhHE
         KtBt+MrpyafK8bzDHJNDJjQUr0e4UIz8j9eX9WxUXKIQHxO3H5+ZCPXapunB/7HSCHr3
         QxFLwHcQ8T6A/B1wwfAQU0oObI7hjv2udFlqzZYTEHB26A+bzlZdTaxrRdI0065unCYF
         JkjrEALVi6jG0XeMzDkUwHroCZerayd8KHXNCpxBmlpgfyIEAoQiJPhvluObJPydTF5N
         bYAlRN1xd2G8HVty6fGdcj2vqlgDwGhkwDfcnG8qi/nZS92uHmCxJQzYOW5O1ZzHGnha
         JugA==
X-Gm-Message-State: APjAAAWsj8hlMO3220rXiTq0sCscCdIa4HJHdbU1zfz2Z6kzJOOl4ppL
	dZT5oMuJCl9Scl5W/6LS7Hlln/QOcOXniFVzRBHZpXDoF1jTzZQbXkx1DHq/6P26u61XWuoDEXr
	uMYpSfJ/8aK84fAFejexzpEn1W5T1OR8RjSO77CbUqapsE3WaaeYWX4Va/XMp5GruHQ==
X-Received: by 2002:a17:902:1e9:: with SMTP id b96mr99361296plb.277.1564182161386;
        Fri, 26 Jul 2019 16:02:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWOIJi0cWYiLLXy+SBIxfmVhaKcKIporlMR51OF0OcKCuO3xj80f35w3OtUD1lNchTqYO2
X-Received: by 2002:a17:902:1e9:: with SMTP id b96mr99361251plb.277.1564182160764;
        Fri, 26 Jul 2019 16:02:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564182160; cv=none;
        d=google.com; s=arc-20160816;
        b=nQ9D4BCFWau6p/D/tuTl6LQRyAYfeW/QlDbTmfxaiAqMf6Uea6FN1onzlTPfq85Tmj
         BkvknmwbbIK5+CNmqygQL6kYVmcRMF/vH9YJ/Y2M42eNTrtkpA+UmmYqwC9sS+Kyw3uw
         uKQiMthoL2HnfFBhVDeQO50Iy1AX0JV7ArNPVUx2jNqkAxzVSsy6bRbTe7fJSCcAij0r
         mk66lPezbboBD4iXZcMWMBTUVJjq1GC3W8wpwZWYMb7qbdoeXUYknLvs+eimdBOpCd6F
         umiplCfcflmcvQRNxwG818QtRog9S39oPU/2tg5WmskyjHrN5sna1cB3VmOAFTxRjOwL
         2+bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BEx2zcFeEtfAB4XQfFJwjvl+7gtayffTdx0wL9QSa1o=;
        b=Qy3vxmoljkL9G+GWFEgQEcN4in5+qsJ3yaupY5opi19tNnH00nht3SUx2Jifgw1aFz
         EBSRT3fKObBAx6DG4Z/zPlshEnIMncojKOLm8XP0exwtl8TpJHETr/5uxGQjrcKN/IBY
         E/vMN2Yhs6twono2DcX5dMAUkR0VdVQHnzrJrNiRygOiVs4hvSidsQrEV+N/jmd4MaSv
         Wx073ccqUJQfsbrHy4pLfM6hhDlqybVU3gS2AM+zZT/w3lyRW4oguofejD8itYQKkKc/
         +UR+MHMEMaP4D0L3qHtwtUoUJr5jBgIuFnAao2eiqYtWZAF+A7Cua7YeW0TuQLgMqdKP
         3YvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2UhTedPZ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u3si20444250pgb.317.2019.07.26.16.02.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 16:02:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2UhTedPZ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F11A921994;
	Fri, 26 Jul 2019 23:02:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564182160;
	bh=uog7xDvm2Trfq+568RxA/iEycB6CRRejnXbrvr8BSdY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=2UhTedPZgajbGffiDMPEjqh9WvdDSCfJpTpcwge1EckBFQeXPRAAOUE224YbTQlOS
	 m3Y7UOcKHobcI4Ihfus2az9muFpUFcpJhLNy22x+4J/gwhKkUZ5lPIp+dPpJjz1Fgv
	 rlMlOoGOJE83ZjTF3wGfOM25M+WcnUIekcZo6eTw=
Date: Fri, 26 Jul 2019 16:02:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Song Liu <songliubraving@fb.com>
Cc: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
 <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
 <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
 <kernel-team@fb.com>, <william.kucharski@oracle.com>,
 <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 4/4] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Message-Id: <20190726160239.68f538a79913df343308b473@linux-foundation.org>
In-Reply-To: <20190726054654.1623433-5-songliubraving@fb.com>
References: <20190726054654.1623433-1-songliubraving@fb.com>
	<20190726054654.1623433-5-songliubraving@fb.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jul 2019 22:46:54 -0700 Song Liu <songliubraving@fb.com> wrote:

> This patches uses newly added FOLL_SPLIT_PMD in uprobe. This enables easy
> regroup of huge pmd after the uprobe is disabled (in next patch).

Confused.  There is no "next patch".

