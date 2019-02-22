Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88AB2C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:36:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DBB820700
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:36:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="DZ2PMD3v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DBB820700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DED598E0116; Fri, 22 Feb 2019 10:36:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D748C8E0109; Fri, 22 Feb 2019 10:36:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC5B08E0117; Fri, 22 Feb 2019 10:36:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8EEBC8E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:36:44 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v67so1736365qkl.22
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:36:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=eA9TxLOANw/lp9h2GPXgTjx5TpnmBtqllhHuKUoL8wI=;
        b=LZSKH3katVl/HgzTYM3tNFFcacNr2iCIzBGxbnREqh9i5zF8LZOFZh/+TyTzyxdz+0
         /mks+n5mmfdgC1ej8zxKx1f8cm6IBVH5hRP2+FxNeLDDpJhIczJIYMJqwxDNttSxgCzN
         h0pKlvfQTh1Lsq/ZJHmMOIDDgUgBr8uDRZh6fhzy1GMhHIaB7TapM9ZHDFrhUynKlS2S
         02oMDrlNPJCdzxHnlucYzbq8DOjME/j+TFhF20Ddpmuf+X1Tafs+2jvMIYp0Pg57AdPu
         tluMAvq/6jpA0xdYX65pu9qtVHvbWoyvtW9iWzvig2bFMupYGnOPVRh24HunvaZtZzdD
         P1nw==
X-Gm-Message-State: AHQUAubO3BRo7jvs3zhpPi+XK4kl2vIU6RlR5gc1gNq8nVnoLAYVUY2N
	LSVQyUMKMLoZDd8t/2KNvh/CF6gc7Ucwxv9ZKq8HXGEm9toEJ3VoH7/thJZSgcHbv02IyX4FScy
	gFHULhy0NKO/Tn3klyjStTJfZjW3wYEXCzJuLlxOerrieQUoVbnUuYbO7HDQzFvs=
X-Received: by 2002:a0c:c60c:: with SMTP id v12mr3551625qvi.29.1550849804383;
        Fri, 22 Feb 2019 07:36:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYwxV2k9qdnmCQPmqLarOrkazOr6nSzG9feOyTLIRPGJhoDWCUbeaZLf/EPTT5UoLmH6Vgf
X-Received: by 2002:a0c:c60c:: with SMTP id v12mr3551561qvi.29.1550849803446;
        Fri, 22 Feb 2019 07:36:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550849803; cv=none;
        d=google.com; s=arc-20160816;
        b=wF9clw1vYYN2ynTh1dLKpo3L6pQ1kRkkn1Ta2gqlSJ1rdyQGWmeLdMorJsLTTuXtEH
         1mSlXt6oqgOu2YcE4L56pDOQL2H6/DyBso+vBCqHDbXB6pM5LLpAIyGVj2dRGAeMUIz3
         DZXoHVqJXKeK1heeieDvnQgPqpzy7/8N8UZB3ABHJ4SEPsUwdxiAWzkYwM/2E7LEH+Sh
         THK3X/swrTXtINngevEr64Bx5U3q9vV93UYU5I4DXoWr/92I2LBzmatFV8DiP4f1UMMg
         WhnUi8SMOKO2rgwC4KYJFAJbXWd9lzkk18Iri895s4W4BjDXcmFi/sYk4EhLcnUySAg4
         kAxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=eA9TxLOANw/lp9h2GPXgTjx5TpnmBtqllhHuKUoL8wI=;
        b=Npj2mIyeuYwFnRWrBKH4aaxAWn2teAk/xnye3ySap5ZIHFGSiRVH4sMVWxr1otf9si
         zDNpj43nef7Lfp5cbnQaTqxugJFkPcNmwb4FuPNAREmzKYNgE7nNU1EQ/MFXevVdZWeu
         cmAON+y1UctqAD8ZBwjoLLwkkEJdeaXqWtoKP1SSLZmRYBeq3KCWF+I6Bru2K1eFGXuS
         67HgJBoI7i4zerh9/4WBc3VW5oXwgYUIKMHZFflsPpkGAlbLDQOXWZHlsuG7RLTr0eB5
         qN9EoftWnF1THRrYd6GYKPTqF0OvsE1KGhvQjBd+QvC6PuIXd1kAVv0QQXSs266yaOR6
         f8/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=DZ2PMD3v;
       spf=pass (google.com: domain of 0100016915da021c-63475bd3-9a4f-4a88-a42e-e47dab17fa00-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=0100016915da021c-63475bd3-9a4f-4a88-a42e-e47dab17fa00-000000@amazonses.com
Received: from a9-37.smtp-out.amazonses.com (a9-37.smtp-out.amazonses.com. [54.240.9.37])
        by mx.google.com with ESMTPS id k14si57092qkj.20.2019.02.22.07.36.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Feb 2019 07:36:43 -0800 (PST)
Received-SPF: pass (google.com: domain of 0100016915da021c-63475bd3-9a4f-4a88-a42e-e47dab17fa00-000000@amazonses.com designates 54.240.9.37 as permitted sender) client-ip=54.240.9.37;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=DZ2PMD3v;
       spf=pass (google.com: domain of 0100016915da021c-63475bd3-9a4f-4a88-a42e-e47dab17fa00-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=0100016915da021c-63475bd3-9a4f-4a88-a42e-e47dab17fa00-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1550849803;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=0Td44XtvSayPcNqe+eB45iGCcZ7zke8ZoEd5cO88Y3U=;
	b=DZ2PMD3vBl07Y+EYZwcNIF59Nt/XbhwL68jK8dXc7+fRXzbaaxHB4/RvDo9sCXB/
	SEsYjQ5Eo/MiSzXcI8Atvvw4pIPRqhxyHq/6P7mClNQGAFE0G0MDMbTZLIlOJg4JwKM
	qATFnrG5CD0piRoKW7JTx5Q8aRl+2BCjZRMFKth4=
Date: Fri, 22 Feb 2019 15:36:42 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Qian Cai <cai@lca.pw>
cc: axboe@kernel.dk, viro@zeniv.linux.org.uk, hare@suse.com, bcrl@kvack.org, 
    linux-aio@kvack.org, Linux-MM <linux-mm@kvack.org>
Subject: Re: io_submit with slab free object overwritten
In-Reply-To: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
Message-ID: <0100016915da021c-63475bd3-9a4f-4a88-a42e-e47dab17fa00-000000@email.amazonses.com>
References: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.22-54.240.9.37
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.008507, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Feb 2019, Qian Cai wrote:

> [23424.121182] BUG aio_kiocb (Tainted: G    B   W    L   ): Poison overwritten

> [23424.121322] Object 00000000e207f30b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121326] Object 00000000a7a45634: 6b 6b 6b 6b 6b 6b 6b 6b ff ff ff ff 6b
> 6b 6b 6b  kkkkkkkk....kkkk

Looks like a decrement of a counter after free. You can find the field by
calculating the offset from the beginning of the object and then use the
struct definition to find that.

