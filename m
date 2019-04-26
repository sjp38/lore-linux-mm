Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E5AAC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 15:24:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E7932077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 15:24:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="a1z6ESlx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E7932077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C97446B000A; Fri, 26 Apr 2019 11:24:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C45F16B000C; Fri, 26 Apr 2019 11:24:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B356F6B000D; Fri, 26 Apr 2019 11:24:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 994BA6B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:24:25 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id i124so3019899qkf.14
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 08:24:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=ALmtrPU+FyjyIGvxYdiM4DkEmpDksNeNpQjWCn4I9O4=;
        b=g0AMTXONoTT6uJEG8Yoil7ilqqoQIuX9Iijq0eLLzgZ8idRwX9/tdy4AzCu1o/O06T
         Z6xcFWzACo4wjtHtbY+XKl9n1U3ZDAllstLs5oviAqW/K2RsavC+PBaBjy4ilKUBvAXz
         sggJ+Q3e7a7V/wOS2PF2rbktSEK8zqmqoBpFYSZ/mL7xY0fMwaDuU5fXSmHuQdXQhdcx
         edvaAukbq4Cg8zgTdiDSIJb5DS+lN0KGtDHbtFNtabMyyyThhzcCDktW0y0M2l98dHNq
         913fpDBrDkLuGGoOj/DWmVTQRYMO1lSE+TV/06Ur9L0daAnMbJCLVy3c4kf0GzDNXRp2
         LNkg==
X-Gm-Message-State: APjAAAXW45ZSvgNePge62w2WtX/C7+F2o0q3CVDSeQCxjU//p8XTPRSG
	hPBllv/4vmeCJ462GdN1QDg4hiRIu2eqcrEQxtjvOlaxUThm8U5VZqwNbI9PUJOPtb11MBd347Q
	h51H6pBpelJlXX9SWcDu9dE2g5hC1BLCGV3CxK1bGAYLZp0eQp2aeOVJP8m8orts=
X-Received: by 2002:ad4:43cb:: with SMTP id o11mr19876180qvs.71.1556292265389;
        Fri, 26 Apr 2019 08:24:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKffEIYOEDEx6AGck6VbjphAGZGuFxkJeC80fSkMXMuydkmKKV1M5g0BtcZOhYVDwBqfnV
X-Received: by 2002:ad4:43cb:: with SMTP id o11mr19876142qvs.71.1556292264843;
        Fri, 26 Apr 2019 08:24:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556292264; cv=none;
        d=google.com; s=arc-20160816;
        b=B8L+i6mkn7UOBDyzEJIApIszT+9WR22Ld9iqp2h0eF6IHyP0atg6DnoGsF0oizZD96
         9eLsyJCwNyGMD2/A2jXkEbFx6ZeRO2a00FULs2WaWmEGDQGWGubo6p1HHt/cJ2PjhqCF
         UZ3WUxHZOA55vEvUC/ev0u5L4BtWPHSvWAxi2/zl3xz78nsZNtX21VyxT7/WkIO2rEQB
         BMycPF8U+Jsp2oi0mO03SSDETS7HYDnMinfb2ikroofFQ/oIXmeiUnyDnMpnhc1tEEdJ
         1dzDbddZ9V04ZJ7ej5iZCrwwOkZk+Rfkycbb54T0qcAMvhmxBdRsG/nig97cQsoJ/rht
         Mb/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=ALmtrPU+FyjyIGvxYdiM4DkEmpDksNeNpQjWCn4I9O4=;
        b=SCFzSE/Z9SDSNaVY9LORrsU61GKVjJnGqEJcPtIkVYqxg21T0zQyzEWN7PiJGFjEpM
         IkaY9kt5GyoJz4z60EleCksgx1A5UQ2bTFXPbqOA1tG60CxvPrGi04Es1/4oAXpd+Hcq
         GRuAB6cqFNCkln/SuOxUdpO0Sa8Mt3vWO8M5tRnBJYAtFBZCdpQSRCz6GD1cvyqMdzGk
         QsnrTnMBxaKy6hxJSjxn+vvJArqxvw6SLLjC32NFQ9FMu1q0WXy3bioU0ZNIwW8DSZ4X
         38ApKJC7cblLi5WD7GHgxPOuWsFN9sa7kE/eIVLkUwLi9rrmdxiYyn/SsrGycXuWUrwl
         h56A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=a1z6ESlx;
       spf=pass (google.com: domain of 0100016a5a3f6121-e7ed483e-bc29-4d75-bd0a-8e3b973529f5-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=0100016a5a3f6121-e7ed483e-bc29-4d75-bd0a-8e3b973529f5-000000@amazonses.com
Received: from a9-37.smtp-out.amazonses.com (a9-37.smtp-out.amazonses.com. [54.240.9.37])
        by mx.google.com with ESMTPS id k63si8513839qkc.86.2019.04.26.08.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 08:24:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a5a3f6121-e7ed483e-bc29-4d75-bd0a-8e3b973529f5-000000@amazonses.com designates 54.240.9.37 as permitted sender) client-ip=54.240.9.37;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=a1z6ESlx;
       spf=pass (google.com: domain of 0100016a5a3f6121-e7ed483e-bc29-4d75-bd0a-8e3b973529f5-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=0100016a5a3f6121-e7ed483e-bc29-4d75-bd0a-8e3b973529f5-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1556292264;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=ALmtrPU+FyjyIGvxYdiM4DkEmpDksNeNpQjWCn4I9O4=;
	b=a1z6ESlxgzd3G0crCTtKbTvr+mqzstFzSaiZPg0lk9nXaKS6z69dp2C2MVu9hF60
	sdJt5OvWwl39SsUxZ/dqrDDOlhVqmQiu7cOgurwsOpZSXEihIPXvxFGHakjVnQOMR6n
	IUX6/EltlGJP1PbgEboreeLc/GPwxojlWQeu+J2c=
Date: Fri, 26 Apr 2019 15:24:24 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Alexander Potapenko <glider@google.com>
cc: akpm@linux-foundation.org, dvyukov@google.com, keescook@chromium.org, 
    labbott@redhat.com, linux-mm@kvack.org, 
    linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com
Subject: Re: [PATCH 1/3] mm: security: introduce the init_allocations=1 boot
 option
In-Reply-To: <alpine.DEB.2.21.1904260911570.8340@nuc-kabylake>
Message-ID: <0100016a5a3f6121-e7ed483e-bc29-4d75-bd0a-8e3b973529f5-000000@email.amazonses.com>
References: <20190418154208.131118-1-glider@google.com> <20190418154208.131118-2-glider@google.com> <alpine.DEB.2.21.1904260911570.8340@nuc-kabylake>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.26-54.240.9.37
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hmmmm.... Maybe its better to zero on free? That way you dont need to
initialize the allocations. You could even check if someone mucked with
the object during allocation. This is a replication of some of the
inherent debugging facilities in the allocator though.

