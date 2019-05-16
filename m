Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 614C1C04E84
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 17:24:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0FE520848
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 17:24:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tsFelydZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0FE520848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6249A6B0005; Thu, 16 May 2019 13:24:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D4336B0006; Thu, 16 May 2019 13:24:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 474976B0007; Thu, 16 May 2019 13:24:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE7D46B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 13:24:57 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id a20so1233733wme.9
        for <linux-mm@kvack.org>; Thu, 16 May 2019 10:24:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GwdAfYvM41KiSLkhlq7rAt3w1iZyUAjGI7qrOqoVW5o=;
        b=lxTrSgGHxlTyBAl50VFyvFaEDKzBdf3KGd0ISdjRvhc1jfvU0pgVmweL4GTnkNNTMT
         9Qft+LYatea9JLzS4WKTZalBBZ7ow/kEz4OjH8fVQbF/5q2JTDXh3LGFZmEc7n4osRwS
         KZ9qWdps/uQD7xpdHRKrwfvMCZqcVASEp09H3A1+4fH+PmWsYzAnme5lSdhUyO3Uz/kr
         7HP43KhLj+X+WhBT/BNZCJ9N2yK1AJuQCxkfD3OUc1UU5coP9DRQT443OpkbWD/ToDP/
         96A9R10bKHd/oSVNOu3Zp9AFu60o0IkxZVpz7jex8Ebu7LdElSyIIdoKIfGoXEZH8iOl
         ml9g==
X-Gm-Message-State: APjAAAVMUulbGlKBgIlmhj+QROOnPfR/m5FHBQqm2v1IbbymTm1IkzOM
	IHjDbvpW/VtfnOSjXdHkT3VQ43ZICKpFROne8tDjjGCyYaWOrTxRYrlVzMKVrJy1cFqbE55RMru
	cZFDa9l1JIM+Bm9vlrC8ZhBr+uj8Aaam603c3e2Ltcw2wk6KTiMwg+ksd6w+dHr9syw==
X-Received: by 2002:adf:f408:: with SMTP id g8mr3666567wro.264.1558027497404;
        Thu, 16 May 2019 10:24:57 -0700 (PDT)
X-Received: by 2002:adf:f408:: with SMTP id g8mr3666520wro.264.1558027496513;
        Thu, 16 May 2019 10:24:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558027496; cv=none;
        d=google.com; s=arc-20160816;
        b=EMzmjeaq6ITMSdfyEU1uRPPkiggIezGBLCrX8y56DoANrLCQ/f+d81sOQVRRMtoC65
         xj4oeSjY/ajQROAJ6eWTJw2N8fazH/JPlNV8hTakMfo7zMJpzLKfyd2FhCFjeUfE7GeQ
         09tWeZWDSdkMB0DO07hrowSAKp/1VCWAnmHxOaACBPLuvCS6tudPEyx4jO/yPuUJeYiE
         jVOT47b830h4ysDzSl/5pWHcxYEMSwniHEc0N9D/YWfPCgx5OgMmLrXBJc4YPuZlntGz
         mYAaqy9729hC6NsCD8fyCM2bFeN2mxv4V66cd3Mw5COlBWUueDL/gywNtEIKtEmY9PHg
         RT2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GwdAfYvM41KiSLkhlq7rAt3w1iZyUAjGI7qrOqoVW5o=;
        b=soEgCMiMB4DzkRA2En7FEtW1lU5nkSpYSfjV5vWvKj0gq2XLHZlvSYeZz6Q3AZYiL5
         5Z/kWB8E/2ZZREXrNmOH7g3ZdRA5dz9r2RqE0YOeOvcTd/AWOWeG85VgaC876mpeFep2
         ot/5xHAtzZkzATEJQtDjjCg890qGiaWYb4V5MI0LLyscDHhvS+uA7CqhrP4djgA5zS70
         kFM1XisjNVL6YDHae4j165jLlDw2qSMxyEjrHjZzScM2kmzBJpPmiZkv9RiwInh7tpdD
         Vno9Ifi3UE+bq6pp8tbbGdA39pOdl45HuCpwDO9hr/Ea4rN1P/p8rnEUiumdZ1zO9w24
         BSGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tsFelydZ;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor4995271wrc.51.2019.05.16.10.24.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 10:24:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tsFelydZ;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=GwdAfYvM41KiSLkhlq7rAt3w1iZyUAjGI7qrOqoVW5o=;
        b=tsFelydZLhNvYDfeLAWpd9ZwFCHCG8AiKyuzgsSzXz4v0flYaDVLn//dqRSH9pssXd
         5dbeqhtnk38ShQidfbi+qNj3cWXAa0IZrsjoInLiJzcOJ8WKNS1AI7PHiiE048Ii6xZh
         IMalHDtjMxy8w+V1gZkq9SzxF36wgJAPkEx8cIMCuk7lF6NlCT1TBDxLsZ1r2ieLwTC6
         Qey5JgIKurXACewo03AC9iyGB8S9j88Oia/0rfC6MiZSwmiv6Hg8CXc/g6fNuZGzMcYy
         ITUVxvgb2V8EAfKxI9902rM1Ku1TFSOQ/XQbNIKM/NRcryk4SperNpY36Z45a+xCt4UR
         E8SQ==
X-Google-Smtp-Source: APXvYqxXhyZaIbtY/Sjz0UTDsBri4w8N4SWVTBL/lOnSyeL4B2It+7qNhzKrwBJjN1ueL0PAiOqHdw==
X-Received: by 2002:adf:8bc5:: with SMTP id w5mr16879957wra.226.1558027496104;
        Thu, 16 May 2019 10:24:56 -0700 (PDT)
Received: from avx2 ([46.53.251.158])
        by smtp.gmail.com with ESMTPSA id a22sm4350148wma.41.2019.05.16.10.24.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 10:24:55 -0700 (PDT)
Date: Thu, 16 May 2019 20:24:52 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>, Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] mm/ksm, proc: introduce remote madvise
Message-ID: <20190516172452.GA2106@avx2>
References: <20190516094234.9116-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190516094234.9116-1-oleksandr@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 11:42:29AM +0200, Oleksandr Natalenko wrote:

> * to mark all the eligible VMAs as mergeable, use:
> 
>    # echo merge > /proc/<pid>/madvise
> 
> * to unmerge all the VMAs, use:
> 
>    # echo unmerge > /proc/<pid>/madvise

Please make a real system call (or abuse prctl(2) passing target's pid).

Your example automerge daemon could just call it and not bother with /proc.

