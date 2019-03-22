Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0A49C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:38:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B335D2190A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:38:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="Nd4IJAJX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B335D2190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C9966B0005; Fri, 22 Mar 2019 13:38:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37BB06B0007; Fri, 22 Mar 2019 13:38:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23FCD6B0008; Fri, 22 Mar 2019 13:38:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4D26B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:38:51 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z34so3007717qtz.14
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:38:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=t1z9bclqYJz9qIJ/zfgRXzGl2XelZgLxHQlIn9FSkNM=;
        b=W4delmhMJYhianv58fxTl/sJtc6S8kCr8YCgyzw6AEeQMWYO28vqAYqstf+zj4gzRO
         nO6t9RszPwvuk6jniqLmk/Im5dTCkQO1IN78kDl1THN0ClKkFWMpHEZH7TZvvlhXq2ql
         Q9CYGVfapm+rTY6oUC4Lqtp4OFDw04PZBs0ARSl1snQIxUY3ZXszy4vmiZTpSnRuhV0t
         2EdaDHoCbpEl55GL6luKbOXR1lUMZyQFfJGbbf2bTtPl1VGvekjJ7hoT8Ur3eCJXe9Oe
         kyVdksyB/+v9zwqpsHJBOfgH9Fi5eFJxMLRS8I+ru3VbTSgIbHBbTnvUlaVqX7ev+GWn
         hdAg==
X-Gm-Message-State: APjAAAVgb58U7CVhw7bjbcANLCE6Oum3BrnJlVb1fb1+NWyoHcDsY4a0
	9UT3V9ElA5aMfAI0UuklxR1kAlMwiWbFyxD/Cm+P0J5xno3FBPNl9+DWtoFJdmH5zorYdNYv0fW
	OgLYAZEzy2ccmOrAIfON7xDaN6lpBoiTcI2/vDFvLd1k2NNUAkO7LlgFbmaMlaGk=
X-Received: by 2002:ac8:2e75:: with SMTP id s50mr9289181qta.375.1553276330728;
        Fri, 22 Mar 2019 10:38:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzj4RXrmdssOhlV+4/5RniKWT3QSMItenglkj6ZkW8VBV517ILoOJtRRk2V8RYA8Os/YVFH
X-Received: by 2002:ac8:2e75:: with SMTP id s50mr9289119qta.375.1553276329749;
        Fri, 22 Mar 2019 10:38:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553276329; cv=none;
        d=google.com; s=arc-20160816;
        b=BST/dpiA+vmrBPsExxpobos+ttaTL4lz/HG3F9JnH7FTKBTHn38ae+0G4bE7JIKcgF
         23vjWSv6PFmb7+t2ADlvag3J4kvpJTNngmr7754NhgKxZTGTvHPbRR9I5fuPRbjCKmuI
         xdsROT5k7Ouomg8ShjslZdMCoU3v3rIvjE/qWWtpLwtLcgvDfr87vhoH454YJmQryGnO
         jNVROoJWxUOj3WpDeP5AVOkBwqUHMlVGj97jFcZRmvq8eS4pU06XMZJ2xUx93Aaxz+8z
         D2SySqlWHhbu4Scje8+lSlNqKvxrJJyBiKqnpOYFy9NpI0jUpAgXuNdAyVqrcIkkS4EE
         oMnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=t1z9bclqYJz9qIJ/zfgRXzGl2XelZgLxHQlIn9FSkNM=;
        b=j97M8POQ5Fta56IX/ODydRTFnkz2axy13uHjBIeii5J+vik+rK8ze8BhTs7vlmdia2
         SAKQTkCXU7W0aP+dWDDmbVifErXBjCswlm+8Z++h4DGYtqRK/agBBLrv1d8mJEEewsDB
         XS5OIe33PKTKHsA1HMhO48HQiV0Hj6bFlrWr/1EtTrWAXiW5K/xsoYc3uhxd9UwE5lj+
         0szKZ58csBiH1qudz1oEzul00mHwdr51phlUa5+Y6Ridh7AcIoC/3HclD33ItGXM0sVK
         ePBP47i36a/CW2HBD9HIH9h8ODX4xBuH/pGmzTkrxDI7SRCzcOKvxP2I9O1zxJ9JYy1l
         00vQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=Nd4IJAJX;
       spf=pass (google.com: domain of 01000169a67bdd50-bf4ef6a0-c4f5-4156-b458-41885eac10ac-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000169a67bdd50-bf4ef6a0-c4f5-4156-b458-41885eac10ac-000000@amazonses.com
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id x9si3069902qtm.7.2019.03.22.10.38.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Mar 2019 10:38:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169a67bdd50-bf4ef6a0-c4f5-4156-b458-41885eac10ac-000000@amazonses.com designates 54.240.9.99 as permitted sender) client-ip=54.240.9.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=Nd4IJAJX;
       spf=pass (google.com: domain of 01000169a67bdd50-bf4ef6a0-c4f5-4156-b458-41885eac10ac-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000169a67bdd50-bf4ef6a0-c4f5-4156-b458-41885eac10ac-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553276329;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=t1z9bclqYJz9qIJ/zfgRXzGl2XelZgLxHQlIn9FSkNM=;
	b=Nd4IJAJXLmYk98fCzo8idP6HAyo4V4hZpf6qrUB0y5mgA//XLNG/C1SpCJ5k5fpk
	UTWPhHNWCFD7X0vLD48rO9PKd6v/AvtPotP49TaJygzPMJISJOyDeaYvUpAY8sfSb5g
	pFlBaeftFulOATvkj9nCpD2xZB3ZpX2XxZ1qY69s=
Date: Fri, 22 Mar 2019 17:38:49 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Li RongQing <lirongqing@baidu.com>
cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, 
    Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] mm, slab: remove unneed check in cpuup_canceled
In-Reply-To: <1553159353-5056-1-git-send-email-lirongqing@baidu.com>
Message-ID: <01000169a67bdd50-bf4ef6a0-c4f5-4156-b458-41885eac10ac-000000@email.amazonses.com>
References: <1553159353-5056-1-git-send-email-lirongqing@baidu.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.22-54.240.9.99
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Mar 2019, Li RongQing wrote:

> nc is a member of percpu allocation memory, and impossible NULL

Acked-by: Christoph Lameter <cl@linux.com>

