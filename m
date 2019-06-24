Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 180A2C48BEA
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 20:21:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B64E720673
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 20:21:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2VPaEOiY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B64E720673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D35B6B0005; Mon, 24 Jun 2019 16:21:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 283E58E0003; Mon, 24 Jun 2019 16:21:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14C578E0002; Mon, 24 Jun 2019 16:21:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF96D6B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 16:21:53 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id i11so7205685pgt.7
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:21:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/rV1TlvYuXOK2sFci2/p6W21rW/APz4/kUsj3EobUV4=;
        b=k2lGQHNBhaUeFHoJ01qDMtPSrEwpCxE+ixOC3UlD3rxv6bSPfUC7D9EOV3l2iwCGcn
         7Q+pFG0Mdk9zJ/DN6tuCuyZdQCmr4d5mCYyL4t79fuQCM1uAoG/6oqb53FSj6q8DnwQZ
         Z6+E9t87A69VgWsqRgMXGLJdy3S3Oqozl8C2tbHGe7AFs4dHJNe6bS63+GAA9BqjIjnC
         jsqaF1nv0J0t3c1lFeo+gvLgPXNn3aoU7SAVLJLziMSOQxsNK5r4Cy1UmvcVVoaT7OPd
         4mHMvsuGfkcd78IbFUDGTX553VrEZdFCDLIdsoEp8bXJigw2gH7s4dCusL69AOuC+AwQ
         FFLg==
X-Gm-Message-State: APjAAAWAF78UxxX4hIddlT5xCGxmQQ8QtS3DuxwfBe7hPsYhhUf4uCzy
	nsGFZPAg1/uPAcLnjCx5oTCpZSRjeSeF6eqklHSIpyyXQpRFpSHK0krW7SfRDEXpovBVTddSK99
	BeSkL/C8iHvQC0Ho4koCLpfbD7EuPweNkF/zL+sXPUhBYvIRC4gdicHZiT5SdbwS/Dg==
X-Received: by 2002:a17:902:246:: with SMTP id 64mr77804980plc.311.1561407713291;
        Mon, 24 Jun 2019 13:21:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9HrI8EcEwgDAWIE+KfmjvAvWfmuSNtWh7GnKkmafellFbwGwAWj530xIj3BO0pPHkrNG7
X-Received: by 2002:a17:902:246:: with SMTP id 64mr77804916plc.311.1561407712466;
        Mon, 24 Jun 2019 13:21:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561407712; cv=none;
        d=google.com; s=arc-20160816;
        b=HAWO6r4fdY+d2PuaJGk3sitpZDHwueubHJDuJ1yh28qdXDN4t+K/IXmA0b/mfHiV0C
         OHiJjSiIkPzA+b0UMsvNZOofy0h1Zwc6g/rAeNsjh9aItqL6IUAwdsz9ZMOZVbXtGA2D
         xmod1nmBch3hDGgUm5esDbTiX0+ZBCTYF/nN/T7OIZRCH40We4avdfBd/eFPp1hAzYrx
         kLaxeyLGHMj9PrUJOG3UGLt4fOVtJnXeHctp4Zjp6dzrt6qMTafUcWzrU5OP+pDLiqOY
         GmRyQN4MITLTTCR5cqNw3zvxleX7LtubZQFwryzQll9vMYTRTZu3afpg8jQ5ZOdNVOMq
         C3wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/rV1TlvYuXOK2sFci2/p6W21rW/APz4/kUsj3EobUV4=;
        b=glwmdAG2Vp1DHqe+KxVgkOPfwEd1m/96M9+8s434Z5xHxXx5OlIXfH4g6/2nGEGE5u
         C54RxmpJjPoPUYRszfa63MMP5QH8fkAt+T76htnjf02M59pM/2/Syz/cigwqUF6NRWMA
         aS6YGOVX1HhLD2Gv+wxk3LMSlBpg7P/LozD1aPLYlwXX3gPMecIrHBHRtav1w51J9Pdb
         wa2P+TQqB+gLNBQHkYSmGHmyzma6wowCPumuHWrWO/Tqh89rODzD10q4dyF5ENd47iTN
         Uzip9F134oSP+Vwe/ddqd0uOVV1NLXEpn2HiyzEHGIbWGP6L6/Q8y7Miwy6wFD14RC4P
         O4VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2VPaEOiY;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b5si11218646pfi.205.2019.06.24.13.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 13:21:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2VPaEOiY;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [167.220.24.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6755E20645;
	Mon, 24 Jun 2019 20:21:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561407711;
	bh=/rV1TlvYuXOK2sFci2/p6W21rW/APz4/kUsj3EobUV4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=2VPaEOiYLx/B1U7xl+3URPJW/PCnea+Hoo4lmR8kq/6n244//CX5FcosNOr1Dj3oq
	 kZ/WOwKR+mt0aTbDmzXkGDY61uNn7Pw8n0E1ZmPY1FmKSwRlrgS69rOqWLgsC9nNQT
	 I7qwRnBg2lc/TFX9Q7IzCpvfO5IQUktLdI8ucdSE=
Date: Mon, 24 Jun 2019 16:21:50 -0400
From: Sasha Levin <sashal@kernel.org>
To: Ajay Kaher <akaher@vmware.com>
Cc: aarcange@redhat.com, jannh@google.com, oleg@redhat.com,
	peterx@redhat.com, rppt@linux.ibm.com, jgg@mellanox.com,
	mhocko@suse.com, jglisse@redhat.com, akpm@linux-foundation.org,
	mike.kravetz@oracle.com, viro@zeniv.linux.org.uk,
	riandrews@android.com, arve@android.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	matanb@mellanox.com, leonro@mellanox.com,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	devel@driverdev.osuosl.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	srivatsab@vmware.com, amakhalov@vmware.com
Subject: Re: [PATCH v4 0/3] [v4.9.y] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Message-ID: <20190624202150.GC3881@sasha-vm>
References: <1561410186-3919-1-git-send-email-akaher@vmware.com>
 <1561410186-3919-4-git-send-email-akaher@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1561410186-3919-4-git-send-email-akaher@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 02:33:06AM +0530, Ajay Kaher wrote:
>coredump: fix race condition between mmget_not_zero()/get_task_mm()
>and core dumping
>
>[PATCH v4 1/3]:
>Backporting of commit 04f5866e41fb70690e28397487d8bd8eea7d712a upstream.
>
>[PATCH v4 2/3]:
>Extension of commit 04f5866e41fb to fix the race condition between
>get_task_mm() and core dumping for IB->mlx4 and IB->mlx5 drivers.
>
>[PATCH v4 3/3]
>Backporting of commit 59ea6d06cfa9247b586a695c21f94afa7183af74 upstream.
>
>[diff from v3]:
>- added [PATCH v4 3/3]

Why do all the patches have the same subject line?

I guess it's correct for the first one, but can you explain what's up
with #2 and #3?

If the second one isn't upstream, please explain in detail why not and
how 4.9 differs from upstream so that it requires a custom backport.

The third one just looks like a different patch altogether with a wrong
subject line?

--
Thanks,
Sasha

