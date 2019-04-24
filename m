Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA679C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 16:14:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B45A721901
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 16:14:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B45A721901
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lwn.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43F7F6B0005; Wed, 24 Apr 2019 12:14:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EE9A6B0006; Wed, 24 Apr 2019 12:14:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 304956B0007; Wed, 24 Apr 2019 12:14:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 099B56B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:14:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h14so12359907pgn.23
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:14:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=k9zqLKiedwoTlErYQZEKQSxxUtNrFe7kZXxbcVHJny0=;
        b=nR5dsSVisnPysgTculYf9veE/Eiut20TFdIThI54fYyXoiB7yTVv/bjzRUS3Klcz2z
         pl8H2YxY7wIJVN1ZeAyskmlsNFYfCbei2FXw6DxeZZv292TVimcLO6WTzohOvrzruCqF
         CqbtOumcaqkWvKJd4GViqFSo4bQgeSzjfjZ7CS7+UdIIFy70hfRLUyCD8sD713HXMmN8
         ZrOW0JydtupuzGOI1AdzqRhnjyMKBFKiwKnRwCcmkq4Hf855VFXpFpXbR0nyU1pb//Tv
         wNTQOZnUMkV+8zhqI9GL6yGUlmzdM2y9XqA1KX3cp3wioCs9rl1IDc1UGpxntBAF3Os5
         znBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
X-Gm-Message-State: APjAAAW/d3IdDSbHigz20+eKuxI38eoRMNsZGcZJIzhDaS5Ch0e6AS0+
	1+hWBrhPCkPoz5x4LlZCmYOSydGsSZwuNN3qAPlZUUm5+DgOzDFSZ/S3KFKrYMyC9U2lI1utT40
	R4NBGRSMva17RhsqKEoEFF83a/Z/gtETa5zvup2KlwCDJSkYUY6S6WwdmIXOpwKHY6g==
X-Received: by 2002:a63:fa54:: with SMTP id g20mr31585334pgk.242.1556122498158;
        Wed, 24 Apr 2019 09:14:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+7B4nmE87AIcke6olKhMxtd9R/HM15nWGJcNWVhMDRugUswlXU7RYAJ0kY9jwHibrj+8j
X-Received: by 2002:a63:fa54:: with SMTP id g20mr31585279pgk.242.1556122497368;
        Wed, 24 Apr 2019 09:14:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556122497; cv=none;
        d=google.com; s=arc-20160816;
        b=Z0Sj/JxhREIXTGZ7P2zMsF63jiPkETebZ9Nieitrf296LsUu5yWpZKM5lEi6KLmNXJ
         lgAoLAxJY8aSvp87YVuNa1ZrvFg+/53VwPa29B9OuSMbvY39pG0zR64rmUTbS4m76NoJ
         d0EAWkB9N3+fYyvd3suMXxORFiEvaZsAOGqd870diMVULXyVbpWgiwCqMhDR1RCU2nh7
         Yv46+qjVXuFX2oxyCYOYCgazvwNUvnzkknTGHceVF9EwXjqOiwV3iFNibqSGQnYVhvKf
         +aNVAuMKvYENA9lYUbe+tQSpzuFElNdev02qC/8Pe76r5zr3oqIWttFoGdIiwY0M/vXZ
         WGBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=k9zqLKiedwoTlErYQZEKQSxxUtNrFe7kZXxbcVHJny0=;
        b=Pt4GqJqhnOlXOHFwpdp5EgPwXR8WSLQttqP0pcXx7dqqJxOeV6/c/n1z7CDiRgPAzi
         8W98wTSb8RdwoRdEu3QCNWeu+RrQYSkiTkr8PvHU1wns0y+uHSBzN4iiXITAKxZEd5ax
         MLr5UQ+6CJvy/a3QekEQZxlouG1IfLZIN/TKrT7PhtVcYgNE/Uxea9gK/30fDuJ2MQb3
         Ps0ueW66H5F6k/4nyx0/LbtIhnrosEKqgD8OXRUw59OtuOtA6jfSR9PQa8BJ+aTWZd31
         LQ7qBY5O65Pnczs0Y3tlVdk3do7ufSSfMIzOap3qUS8WKmECLubV5vycywkpz//UB/2L
         by+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id i33si18103504pld.374.2019.04.24.09.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 09:14:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) client-ip=45.79.88.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from lwn.net (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ms.lwn.net (Postfix) with ESMTPSA id 8E6621AA;
	Wed, 24 Apr 2019 16:14:56 +0000 (UTC)
Date: Wed, 24 Apr 2019 10:14:55 -0600
From: Jonathan Corbet <corbet@lwn.net>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] docs/vm: add documentation of memory models
Message-ID: <20190424101455.12cd407e@lwn.net>
In-Reply-To: <1556101715-31966-1-git-send-email-rppt@linux.ibm.com>
References: <1556101715-31966-1-git-send-email-rppt@linux.ibm.com>
Organization: LWN.net
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Apr 2019 13:28:35 +0300
Mike Rapoport <rppt@linux.ibm.com> wrote:

> Describe what {FLAT,DISCONTIG,SPARSE}MEM are and how they manage to
> maintain pfn <-> struct page correspondence.

Quick question: should this document perhaps mention that DISCONTIGMEM
appears to be on its way out?

Thanks,

jon

