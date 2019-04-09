Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD460C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 21:52:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A28EC2082A
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 21:52:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A28EC2082A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D7B86B000C; Tue,  9 Apr 2019 17:52:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35E296B000D; Tue,  9 Apr 2019 17:52:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 200E36B0010; Tue,  9 Apr 2019 17:52:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2C066B000C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 17:52:23 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j1so48305pff.1
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 14:52:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FZ5obpRP9GSIbCbApC6jcrhi7QhbpASjIx09wxULWlE=;
        b=l12kNroFLm+mckKtayxyW+cKCIweuAAXtA5DtQsoyErQWLYoLvDbvN7+MAi+A+x7wM
         m8qau1n/VZKK0Kk4f1t/PDmLvW2xiJnGFzSwdKojUHvhJInQSTD7PFfkw/6qblCUY2fp
         Of0MkKzFB8UozCWkDz9MTequT3QnKi4zxg3Rq6LcspKaObJ76VIegmGDMsikgI3rIDCk
         KQ2H0m3GVi4gkg4S76r5SfBuCh4zcECiSzm3Xb8iMI6Fi9SM5680DLoGQxra1crqBvRq
         sqCJrEYu7POtFC6UMQsFBRIGZZxyAajlQ8cHahlScU2ckj7qXPcQ1Dhc0Jc/r2B0KO3G
         8fqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVgCuy7g2fOyNZZZAJpSGviUCf8djcUamERA3N9y73jeJoADU5f
	g0lPPS5uuqzHk+8P8do/EAMH1FAjwwVOSeoLaPBk7H4488D6WAa6qZWCvwEWh2SI8nvr+TpSL/C
	2OiE8CWcgTs29mmoZSFoeXuaML9LZF0m4PDAH+Ms89k1YjEuZetNlSx1IfcdXc3TlIQ==
X-Received: by 2002:a17:902:b089:: with SMTP id p9mr14937894plr.185.1554846743430;
        Tue, 09 Apr 2019 14:52:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBKGeBtubYypA8LKM8OTFxAwbVRXPKP/+hw7LM6vJ8fDHEsdQssDAWaBnABR9dANYopxqs
X-Received: by 2002:a17:902:b089:: with SMTP id p9mr14937822plr.185.1554846742314;
        Tue, 09 Apr 2019 14:52:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554846742; cv=none;
        d=google.com; s=arc-20160816;
        b=secEYDznyqf/lp6/KCVil0NTSrzzot9VRYUirk1piBjue7H/RSeM5wqHjihuquJJOg
         NaFE/Ezc0BVxdEKXqzC2eDz7PVWD0fyl+GGzhdPv522owp9QnzAXE0tzWS2xJn0IXHZg
         /Q2C7qPzdBLU138VfqqX/jUwrFP/dQ5VlxlxpPly/6MCsikXp2iio5Z4NbEEidI1gwGk
         qYxYHSQduyQvcgR93YMX+lEsTDjyP2M4lwXSUmz2VB6CG5ruFW9D3yGsr/lmKVZ6MakS
         zIM/UvraPi3dK7A09NPcxQAqxEzLvAg06LZypnRzt09S+VVp3LQjhVqZQfeIhpuf0fm4
         djfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=FZ5obpRP9GSIbCbApC6jcrhi7QhbpASjIx09wxULWlE=;
        b=NPBmKgmEQFWAhs9G8ipPoyouiev7jZJhDZBkQCp+WWir6/vPQscpuqUJh7S7z9hG1o
         nmSRnppguC1H/WjEdGrxtMCEaI/Q4oe7G/r/PqI2QswchGG2GuAUvVXAsKn7xLuXYxqN
         76+yzvYNtwqPhSTCMZ9TgRaj+Oxe74LzuuS1O9zNqUOWZPQpyndG64dh8nNh7j+Fu3zd
         WYOffBBdTc4doo7WNPTCioTPaOx04qaKn0CILTSgkmBPO+txTpc9F94lRZdLVA31fLkQ
         o75cQJ7X97u42C4OtIRuugM4pa1K0467aOPSg1vXVdFLnqt0Bi9+4MnDj+MrnRm+/sWr
         EunA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r189si1350242pgr.175.2019.04.09.14.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 14:52:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id B4D161009;
	Tue,  9 Apr 2019 21:52:21 +0000 (UTC)
Date: Tue, 9 Apr 2019 14:52:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell
 <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH] mm/hmm: fix hmm_range_dma_map()/hmm_range_dma_unmap()
Message-Id: <20190409145220.d3a0a48872fcd9106846664c@linux-foundation.org>
In-Reply-To: <20190409175340.26614-1-jglisse@redhat.com>
References: <20190409175340.26614-1-jglisse@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  9 Apr 2019 13:53:40 -0400 jglisse@redhat.com wrote:

> Was using wrong field and wrong enum for read only versus read and
> write mapping.

For thos who were wondering, this fixes
mm-hmm-add-an-helper-function-that-fault-pages-and-map-them-to-a-device-v3.patch,
which is presently queued in -mm.

