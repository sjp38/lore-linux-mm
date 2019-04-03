Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 743A7C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:46:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BD79206BA
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:46:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="LGvJA7Nx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BD79206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A39E66B026A; Wed,  3 Apr 2019 11:46:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C1A56B027B; Wed,  3 Apr 2019 11:46:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88B446B027C; Wed,  3 Apr 2019 11:46:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD4E6B026A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 11:46:42 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id g25so14873530qkm.22
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 08:46:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=6XY8pbpbyaWXCB41R4IE/Z6UBIB05nlbL3Txf3roPcY=;
        b=fCinytmnBythiUwaKTiTdqHkHAudZ6yzBP1LQjO39yXH0lquyQXNrbzRhBIUk77j6a
         FyJAyUaa8oyRGJ9bqxZHp2YZfFxJtHhfZPj/3/0ALK7vcmUvikgbVUfn+LDYchCFfMd1
         1MdsJC6JlLomT6XY82T1R/g6cf91jhzCyLidDVCiIbibLS79URdW7yXbc1oTEW6+AYWi
         k5nbiCAVXu189OQrEBHMzrNfN8udi1EkKZZnJmc/nLu7YbefT5vyI6pi9rGPkTlarJos
         UOvnU9I/v9xUUDC4wjTLH3IEqj3G2LALl1qMdT95rgqD+66EQbrzXLTqUJQ+Y9X39m0f
         R+JQ==
X-Gm-Message-State: APjAAAWXtR7pDeJYZ5FFuVy1Op/DEGp7xucJfj8apuU7Qny5qV1AxL8P
	b+3ttFqpCua/43Aagok4IoEIllbF/nVfHiSMRJ3GnS6GnZ8i9BDHQ7IqgY1Cw4M7VafzqVJUbYQ
	t2GV+WQecMbRAtLJtiem7yQsxPtDcznM7KaqqGAr9sWquecinFTsXs9Bnra+WwXQ=
X-Received: by 2002:a0c:d0f8:: with SMTP id b53mr243141qvh.46.1554306402245;
        Wed, 03 Apr 2019 08:46:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgLVh2q7K4B4O3Wd8n9Sp01WMFD0WAsmSUtnDzla2hOWAXJzXEPe9FCws1p+94Bo7jSLL/
X-Received: by 2002:a0c:d0f8:: with SMTP id b53mr243111qvh.46.1554306401777;
        Wed, 03 Apr 2019 08:46:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554306401; cv=none;
        d=google.com; s=arc-20160816;
        b=Lops5OzYU2YJxhfwF+lDnSGeRs9H+2ZvzW5c7kZ1WjG4GokBzSVdwSIqcW3vJHTCcZ
         kwzRolAJLa0N+J64PPVGpXcjsHvvj2wh98KKei+frfG4Kh6pCcGFemskpf2UW+3Up5Dl
         ZO1Qz9kFHgQOFtX8yocaF+nesKbxyZ6Awfh14V1amdiZTkv8tKNj5DdAETBbv4nHfPyt
         nFfXf6rWsFpVUPbklJ9K8a9vG0UHgqlHzOu8FUZEFhMMRM1UT75aavNL2al4EO/fn/zQ
         o7fxe76aEAK++aKRpolw7HoPwD+JnoWmXbHX1xHTOQbXdWBBnyhPrYqz24IH2SLvluJz
         JZwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=6XY8pbpbyaWXCB41R4IE/Z6UBIB05nlbL3Txf3roPcY=;
        b=StyvWQFDZCHtFdVmSXxvRR4TCmLWNbYhmj9GhMI0AoZQJogcTWqZil2yVDRBj4R5hG
         QS9OyDwf+uZNkI3UcnwVknYQsgGZpfMqjNvMBMroNzjWGr/Mepr6RcTe9SFNKbEjy4TQ
         s/FTrzml732bM5/3YYPgSVHP/De87zPOHI9kr8wP8jD8kURFG3hGTfGqChlw7yOnwjUU
         gR/0D6uK8LZ9XsdkOCOhoddBpSHXk2t2jSsfdg7asz/ZpAlhziEHh3MhBqJyIJToVhN/
         +4TL+s6Ru6QO2KFy4saeVhQLFiCpSlopZri+DxrY5BhKXFVs51w42tPd/bOFKKD+4Yny
         HaYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=LGvJA7Nx;
       spf=pass (google.com: domain of 01000169e3e183b8-d02b46aa-106d-486f-bdb4-8a2e7c266293-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=01000169e3e183b8-d02b46aa-106d-486f-bdb4-8a2e7c266293-000000@amazonses.com
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id v25si10596884qta.108.2019.04.03.08.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Apr 2019 08:46:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169e3e183b8-d02b46aa-106d-486f-bdb4-8a2e7c266293-000000@amazonses.com designates 54.240.9.92 as permitted sender) client-ip=54.240.9.92;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=LGvJA7Nx;
       spf=pass (google.com: domain of 01000169e3e183b8-d02b46aa-106d-486f-bdb4-8a2e7c266293-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=01000169e3e183b8-d02b46aa-106d-486f-bdb4-8a2e7c266293-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554306401;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=6XY8pbpbyaWXCB41R4IE/Z6UBIB05nlbL3Txf3roPcY=;
	b=LGvJA7Nxe1aE+Dv96y2lic0lnsv9uDc7IppyYHsWw0K2ACmhWuxEBSeHN8PHgnJO
	rS3faYJJS6jWNtDofTwOeL+1mwCPBlzrXoTlalysiW3N7EqfRrQuoEBeXg97w1TyzSL
	VU0kGFTjCLw5pP8OT6wcpzKqlaC6K6DCwgnbYIls=
Date: Wed, 3 Apr 2019 15:46:41 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "Tobin C. Harding" <tobin@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 1/7] list: Add function list_rotate_to_front()
In-Reply-To: <20190402230545.2929-2-tobin@kernel.org>
Message-ID: <01000169e3e183b8-d02b46aa-106d-486f-bdb4-8a2e7c266293-000000@email.amazonses.com>
References: <20190402230545.2929-1-tobin@kernel.org> <20190402230545.2929-2-tobin@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.03-54.240.9.92
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Apr 2019, Tobin C. Harding wrote:

> Add function list_rotate_to_front() to rotate a list until the specified
> item is at the front of the list.

Reviewed-by: Christoph Lameter <cl@linux.com>

