Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0B9CC4360F
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 18:52:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 786112086D
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 18:52:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 786112086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11D0E8E0003; Sat,  2 Mar 2019 13:52:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F2E68E0001; Sat,  2 Mar 2019 13:52:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F241E8E0003; Sat,  2 Mar 2019 13:52:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C80208E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 13:52:18 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id h6so1128477qke.18
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 10:52:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=p294S3ouHPUIV8PTe0QimWfREFPhgIOO+zNrdEjSyss=;
        b=UufvCqaez8KRRnwwpPedBR66NYfGU6Dhoj6wVKh34SARz0JvQTd/ZCkLSkB7E/q7PI
         8ubykL7I0sP5xSTl31o9p99DFMUPNANs/MwW844ce/AIsrh4UBsfjCt9epHICbvwKr7n
         sko3enp1+8Mmcb/1WoiGWZX7pdDef0fI8IUALEyfALbmPZI6gKL4Z09wR/vm6xekcTrA
         fdT0Bg5ULwKRPi3cUIPUi+xLObgFpeRTHbAmQJZUqwKUQa+9zKUpTxZdILcE22WbxhDg
         NCFwYpwv12E1sEHVBiEa31RbzY4MkA6oFnurMVvp6t7ubiLswpiQiMw9KsnSaGWX4Dou
         oPKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXhc+HFMyOxvrLEjUrAftqGtaovYEcSt1R2rBJJ2C4H/tzxlnPk
	UGbpZPPreX7jKmpwrlNrIF5oZTbRGM+2hPZf7WiTLyFA8rzCetne0cGPa1+wC6TgEp24Iza96eo
	bfg74hAmYKC0B/fNQuUj1PRfPkH1QOMoIyHCx8MkzWM8eZVxkGzo74WgVGmG/dJm4ng==
X-Received: by 2002:a37:3d6:: with SMTP id 205mr8308177qkd.223.1551552738581;
        Sat, 02 Mar 2019 10:52:18 -0800 (PST)
X-Google-Smtp-Source: APXvYqzxMI2ErJKuxOfBYYZlWieC6BCWBbVh4oOqKX89RckVNcUbgWi3KaIvPzCsNQaT4rUnTkBK
X-Received: by 2002:a37:3d6:: with SMTP id 205mr8308153qkd.223.1551552737985;
        Sat, 02 Mar 2019 10:52:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551552737; cv=none;
        d=google.com; s=arc-20160816;
        b=H6whDoKROFe/jMtQMaqBW4nx16fxxgFip/E3/najKq36KtV0hceNCQWJ24WJTYVz+d
         FL9XZ+Us0Krt9ubD7+uw767hD49BI5g6VG5VJIewYk4psi1BiKzqUWE+sQ5EX1Ci3f3m
         I64yLq4U4gIvXbZ5FmzjFWSSr6nkqJsA3UysbH+gBwuqpj0K5n6ASKsvetlCnKjuV8y2
         3YHk6vxjK/TNt/gUrQV7wbBsGx7yNkaueJ6yiVv/xxbQoWQMer2VMfniJsV9XwkGMcXO
         g+H/qdt4ZKcRDs53l1Qyz7B1xLbvkScT8ThDNqo6HBA0ZWikLQprHgQkNAjnfMaHzD3y
         Nj3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=p294S3ouHPUIV8PTe0QimWfREFPhgIOO+zNrdEjSyss=;
        b=wqe88B4i8aSl82NPBqfsXCZxy7jvyqKKqb8XsEy5ymQ+Qe2IB7zNQhtLij/SqEo0KH
         XbFblRMmntbZJpWxTjLmfJsHO9sSIH6VJbFRGKIb25eHG5ff9mu/QJoIqX8YQ4S6uLmJ
         DtXGPsLUyDXM90xB42ZorZmYyvYA6Qa6QH5ieIbqQcv/dgFH4niKCrOjY3JNyVC7i84r
         AmT/iBQu8RBvc1982/DWCiE4FU2cnhlJuGR6QDiGs9cH4dfU4if7FWSji+V1o1Njvij4
         9DqKfQxdysmhIrbrAxTuLp3ewI50CdGSDLJx1dvk1+9pDMooUYAAsaOhT+SpduPkx3bt
         Q+fA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s38si797869qta.174.2019.03.02.10.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 10:52:17 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9C5D4307CEB2;
	Sat,  2 Mar 2019 18:51:47 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 220315D70A;
	Sat,  2 Mar 2019 18:51:45 +0000 (UTC)
Date: Sat, 2 Mar 2019 13:51:44 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org,
	peterz@infradead.org, riel@surriel.com, mhocko@suse.com,
	ying.huang@intel.com, jrdr.linux@gmail.com, jglisse@redhat.com,
	aneesh.kumar@linux.ibm.com, david@redhat.com, raquini@redhat.com,
	rientjes@google.com, kirill@shutemov.name,
	mgorman@techsingularity.net, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/memory.c: do_fault: avoid usage of stale
 vm_area_struct
Message-ID: <20190302185144.GD31083@redhat.com>
References: <20190302171043.GP11592@bombadil.infradead.org>
 <a5234d11b8cc158352a2f97fc33aa9ad90bb287b.1551550112.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a5234d11b8cc158352a2f97fc33aa9ad90bb287b.1551550112.git.jstancek@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Sat, 02 Mar 2019 18:51:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Jan,

On Sat, Mar 02, 2019 at 07:19:39PM +0100, Jan Stancek wrote:
> +	struct mm_struct *vm_mm = READ_ONCE(vma->vm_mm);

The vma->vm_mm cannot change under gcc there, so no need of
READ_ONCE. The release of mmap_sem has release semantics so the
vma->vm_mm access cannot be reordered after up_read(mmap_sem) either.

Other than the above detail:

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks,
Andrea

