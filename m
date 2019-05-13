Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74922C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:27:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3269821473
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:27:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bQVmclpG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3269821473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A74406B000A; Mon, 13 May 2019 17:27:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A24AC6B000C; Mon, 13 May 2019 17:27:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 962436B0269; Mon, 13 May 2019 17:27:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62EED6B000A
	for <linux-mm@kvack.org>; Mon, 13 May 2019 17:27:22 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c7so10416530pfp.14
        for <linux-mm@kvack.org>; Mon, 13 May 2019 14:27:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oi56SCBVbBfAntOj5gj6QyyXe0t96GS5uRMaReknFF4=;
        b=HSt2XKEflqlNLHcX0v4Rx7FBCBTHowzpoVxEUEMi6epdLukA/K8COPQemTk0A+GRT2
         P05UG0euNsBO/J0u7LtGGjd/wy42XLcQqY3eTmY+6idu8UlQ611zZW+4onaEMwurdf40
         aPFqy6DDCzLJW97Kg7VEk5O6/Esop3oF9FyzpzZynMTrpioaLdD2lRZbBW0WdSTgdrMa
         dkx0nGa2sVM0YKEuCgaGDfP6tZNCVkobC7BGcWXE3azF82YHGQ6vCvV8IzpJEBTBQ0Dx
         TKsejPgr8YL6pm5yuhjOWEoOtceRi/uwTqMpUmKYzZGXVGfbF6FmFPJnkXzxXyLzUCOC
         terw==
X-Gm-Message-State: APjAAAVNnTc7175mMU5WaKNGvx88/fr+SQ2rtZBT2bStsKEh8tAzLVyo
	jWKRF7HSmEnzey3A+4SNwTs0F9eeaUtXCM+EJcPBAI1IBjla5auvVD98tI/WxOg9ZZY9fBaF7Ub
	S4zyvkGsxg0x3kfrgT3MP71o/AJIXnZD88XylMh4CvY+DZPgeEsX6eW5xeqqH8/n1vQ==
X-Received: by 2002:a62:6c43:: with SMTP id h64mr36656564pfc.5.1557782842060;
        Mon, 13 May 2019 14:27:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/DxzmiKDTKPODR6CuEHYNlJNTVZxmys1gkpC/McqIxE0PFJnw0yVFNY4lNAzXQ8tzYK1j
X-Received: by 2002:a62:6c43:: with SMTP id h64mr36656511pfc.5.1557782841390;
        Mon, 13 May 2019 14:27:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557782841; cv=none;
        d=google.com; s=arc-20160816;
        b=lV9ox9f2US5plHfj5epSOkBXneddZy4asocguKzPZF8CpmP+a+yEnXaJ3o2eCAxV+U
         FtApsAvQvvmieh0JgJOlAMMjnHGIKMkwANg5qjNvZd7Oe8a6jq3Iy6zA7Wn/tdIKW5CV
         mtVijolXSj6vu8Bb6CNL9pOvQz5g9SeycG3bttYyOyvR8h9TAYZ8t/2KdomA1liQD8k0
         FXbfS6ddXdSlFy9WfN/fTsh7L9mL+dcWpEtvyufkRoWvTH4wxWzM1k6S30RrftM27Lor
         lrv3v+Gx2GiwffuPVWLhHSVZP2w7BXG1CDiWY4PzZbRQdEnc7wFXTlOi3Pu+ycp6RoZw
         O6+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oi56SCBVbBfAntOj5gj6QyyXe0t96GS5uRMaReknFF4=;
        b=pcHLhWK8ONUIZ25K1dqapW3xHaqyurNNnBm+y9yAt5/C5N3J7F7eXwgtlflY45ZrLu
         P+JbylVNgFRyDeOUhZd9/YFoPwH376QJbrVFacV0XjkEqjr8S2PygOrIsS2qCVY3U5NG
         ha7DUK/UxbVoSptNgzn0AWYTn4LTHG+/9pOdJfC/pxu4nUVylLjqkm1OFK9i3Lxiwg2l
         OWRPzJEf5XVQzu88QLKSFcM9p1Zj0zXYF1uy+qkOS2R6Bi7lgQNPZSRquh6wMS+PvLLT
         3H49xoq6KuMldJKrMfb78wrq1dBX5tHqbtUDlTcEQERauRl62o6Ull0AzEIN97qHydb3
         3jjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bQVmclpG;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p79si19456931pfa.110.2019.05.13.14.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 14:27:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bQVmclpG;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AF5DB20873;
	Mon, 13 May 2019 21:27:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557782841;
	bh=Yfjam7vD0AUB5DqGU8V8FZJW53SDZV7722EvBstsCIw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=bQVmclpGbN4utboxu4rTNRgq2ZFXwilUCLyO4LiN2zUReSfp4m+4xg4KOvWAHaR3n
	 A6oAsQrgqiSbfcoykdZWHCpDWhVQMSIKbPszs42Mb4N4fWMJJPVUdTz52IONEYdcYn
	 8rOVnAbrDrE/br2wxBc5SuCn/ZGhuCeecAtbKjAY=
Date: Mon, 13 May 2019 14:27:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: "jglisse@redhat.com" <jglisse@redhat.com>, "alex.deucher@amd.com"
 <alex.deucher@amd.com>, "airlied@gmail.com" <airlied@gmail.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
 "Yang, Philip" <Philip.Yang@amd.com>
Subject: Re: [PATCH 1/2] mm/hmm: support automatic NUMA balancing
Message-Id: <20190513142720.3334a98cbabaae67b4ffbb5a@linux-foundation.org>
In-Reply-To: <20190510195258.9930-2-Felix.Kuehling@amd.com>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
	<20190510195258.9930-2-Felix.Kuehling@amd.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 May 2019 19:53:23 +0000 "Kuehling, Felix" <Felix.Kuehling@amd.com> wrote:

> From: Philip Yang <Philip.Yang@amd.com>
> 
> While the page is migrating by NUMA balancing, HMM failed to detect this
> condition and still return the old page. Application will use the new
> page migrated, but driver pass the old page physical address to GPU,
> this crash the application later.
> 
> Use pte_protnone(pte) to return this condition and then hmm_vma_do_fault
> will allocate new page.
> 
> Signed-off-by: Philip Yang <Philip.Yang@amd.com>

This should have included your signed-off-by:, since you were on the
patch delivery path.  I'll make that change to my copy of the patch,
OK?

