Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6518C37120
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 21:51:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80A2A20879
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 21:51:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="hOn+7cxx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80A2A20879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C9668E0004; Mon, 21 Jan 2019 16:51:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17BBD8E0001; Mon, 21 Jan 2019 16:51:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 042598E0004; Mon, 21 Jan 2019 16:51:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D1CDE8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 16:51:51 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so22394902qte.0
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:51:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=ItNSaKDGxoD1aSyvb0fxyYSFutq6GEdD+caS/lRflm8=;
        b=L+GM9DBcomF+4AqzofPBogbwd7DkAxsM3YR5DbXA62TiDUDVtfNnbG/VT6rNr5MdGb
         5yn20CiL+El6TmFApJXjMHe4qu0a8A8O6/DvpvcEoLAFhBJiBdxxMNkXSoc09+K9/DPY
         ckSaC/a0VFEB2Su0alUwZO/krSXel0pqxeY6/xcMxQxtAm8FdE/0VxGvT+b3Hom0LzAh
         xkG5GE/BkDN9RrJT7HAilK04joA9CTgTBOPe3RYtvs5L33FBdjGTTau9DZYwu2qD8hA3
         QIO5mUKe0HhMPDBCXm51JzeesZ39q8wfmNcvHnHarSbAuxp9sEUX+cf0C+N9B+rAuGvO
         uTDQ==
X-Gm-Message-State: AJcUukeJMwjft3WeSzPnrS/AOGkh3AbW3PI5qf5TDYNWYv2gNsWv2J3p
	jIxg5LiX0Hw2jDa0oy/en/rSUeW1xmD+y+uYrq0xkO937YDlHosa4Wwn7zf+gJEqWzc7jXbl6KH
	uqz524r6KTD5dJ40tqWwzEz0mPtv3ftrWN5k1VP2JE8DSYsylqJ8ovc8aXxeTno4=
X-Received: by 2002:a37:7b01:: with SMTP id w1mr26395529qkc.122.1548107510080;
        Mon, 21 Jan 2019 13:51:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7nuWro01vVkj94UIViFfMKn79wWQXDnQXWts8x5GHHAHeII8C/Q5D8/I+uAhtihumjv1jb
X-Received: by 2002:a37:7b01:: with SMTP id w1mr26395442qkc.122.1548107507793;
        Mon, 21 Jan 2019 13:51:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548107507; cv=none;
        d=google.com; s=arc-20160816;
        b=djX7rFqe6AcleWQ0qL83fILvEW5NVMzCje+Gu9XADIO7037Ky5fI569kugGK5XNU9m
         cfKPYWJWKqcFhp/EFR/vKUA5FOLWykiD4BA8mau5itQ/Wok74f8lMX+unrJsq8j9c62d
         SMXhHjYAzefUO8Ajo1ZLgHoSx+E+9ly0meVmCpEZI0IktWnAx9uYexFwdsgryEGbn4GC
         p4+CBr1JM6VX6+S1vBPxpMvccaK44r1NFgYrB0BI2qXLCJSngCm3qu1+xlziOADQGrFR
         s7tYaFbdnRrv4EpjAVPhoz1HP//vmodO5pcCvH3mCUn2/F4hf63hnGn1xShKrA0w3CLX
         WD3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=ItNSaKDGxoD1aSyvb0fxyYSFutq6GEdD+caS/lRflm8=;
        b=rnErlZFuwQs2SVoiNOEXctzjkQS6TfZJowZxtAHy1X5Aok6fDPRn47EBsUCyktE68m
         v8U/ecJxdI1dW2b8ePPF71oj1VnIp9FWHvKyr8dxYcvqGnvto3EgNmdMfY5OlnQvM3NU
         /Ku2NjPEgqLa6rHj48njPxPETXTze54LfQV1aaMUDP7KWP+BTtUQhFmfF8XE01f7dr9N
         Nb9ZuvB49GuSHPkqX7NriXTEFyatLATqqXzLsUBqBjLaMvPdif9dzso8fEZFvS4xeeI6
         m4Rqkp0bU+65IUatxTYf/YPSZXVYMf0GG4uQGhRKg33ndLQyfsyTbgMAyLV+v33NsZNi
         EF8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=hOn+7cxx;
       spf=pass (google.com: domain of 010001687265e644-49af6f45-e29b-41a7-9cd4-50ff8d64b9f9-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=010001687265e644-49af6f45-e29b-41a7-9cd4-50ff8d64b9f9-000000@amazonses.com
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id z12si875305qtq.2.2019.01.21.13.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Jan 2019 13:51:47 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001687265e644-49af6f45-e29b-41a7-9cd4-50ff8d64b9f9-000000@amazonses.com designates 54.240.9.92 as permitted sender) client-ip=54.240.9.92;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=hOn+7cxx;
       spf=pass (google.com: domain of 010001687265e644-49af6f45-e29b-41a7-9cd4-50ff8d64b9f9-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=010001687265e644-49af6f45-e29b-41a7-9cd4-50ff8d64b9f9-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1548107507;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=ItNSaKDGxoD1aSyvb0fxyYSFutq6GEdD+caS/lRflm8=;
	b=hOn+7cxxXuEjteiGeR7rdjymEElIZfAkaGPapPeOkKf8NsmyUvGUt9gqwIgp/uql
	zqPGBTEEyNSwyH+GQbJxkdXhR+I+w1WTzr2+NsCagVOfsoXdxp6uIRHtTBeMXvdfUYJ
	MxDf0DpzxNX5drf9dZ5lRsapvxqxa3tfhYO4Imhk=
Date: Mon, 21 Jan 2019 21:51:47 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Davidlohr Bueso <dave@stgolabs.net>
cc: akpm@linux-foundation.org, dledford@redhat.com, jgg@mellanox.com, 
    jack@suse.de, ira.weiny@intel.com, linux-rdma@vger.kernel.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH 1/6] mm: make mm->pinned_vm an atomic64 counter
In-Reply-To: <20190121174220.10583-2-dave@stgolabs.net>
Message-ID:
 <010001687265e644-49af6f45-e29b-41a7-9cd4-50ff8d64b9f9-000000@email.amazonses.com>
References: <20190121174220.10583-1-dave@stgolabs.net> <20190121174220.10583-2-dave@stgolabs.net>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-SES-Outgoing: 2019.01.21-54.240.9.92
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121215147.F-GZPMUJhFX3p30C0XlCyOUeBuDwxOuFeWgH6EXWess@z>

On Mon, 21 Jan 2019, Davidlohr Bueso wrote
> Taking a sleeping lock to _only_ increment a variable is quite the
> overkill, and pretty much all users do this. Furthermore, some drivers
> (ie: infiniband and scif) that need pinned semantics can go to quite
> some trouble to actually delay via workqueue (un)accounting for pinned
> pages when not possible to acquire it.

Reviewed-by: Christoph Lameter <cl@linux.com>

