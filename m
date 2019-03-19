Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 530DFC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:35:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E998420854
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:35:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="hMR0zHOk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E998420854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B62E6B0005; Tue, 19 Mar 2019 15:35:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 563366B0006; Tue, 19 Mar 2019 15:35:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4539D6B0007; Tue, 19 Mar 2019 15:35:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE6A6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:35:04 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 35so20662735qty.12
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:35:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=m/nS8vo33UtZ9d+8Ja45xPr9BDqJkei7QCQgN/JNs80=;
        b=kjnth+34pogXFemREn4S10klIqjcJn0wZ6+0n37O010RxLvh7gkQ+We8HG0q9f13xH
         Mff2XO6l9MTnWD127ct9tw8j3X8z2qZR0y/O7eJcVDFokHecJOflSxk0kSXQWtsDmXDu
         0UksFtr5B3ItGMDnkR4xbrGM5lciraeP824oVQDBy1DmtrrSbmIUM/Rm82V17ZmFfA6h
         TUPdtpU77txF5mR1n/T4AUTdSrqlUyTfnhSRaua5t71poLnDJuSklEUMlkoSLSJT+YDY
         2dH0Rk3GaFm3Vo7IT41Hmd7PbOIUfxbEnLNnMYgWina5NPjxV4xujXn9YlYUCTK5VzQm
         Zh/w==
X-Gm-Message-State: APjAAAXrhn4I1jNPc0pJcHIKKLrm8Vc6jY7w/mxrySglhJnZ2iZeikUr
	RgHULOgeuckiUJu9JrOtP02sLZ82ClC1npy5rzfgKLehA/ofbDurmsykimAwcy2kWax4HcNlWbT
	fbj71t5KpQiyxTrXGXurT2lJ6tXbVDYO1WOgSfojqJ2Ft8P6k80/mrpMd/Yak+OV/kw==
X-Received: by 2002:a37:801:: with SMTP id 1mr17470218qki.19.1553024103836;
        Tue, 19 Mar 2019 12:35:03 -0700 (PDT)
X-Received: by 2002:a37:801:: with SMTP id 1mr17470190qki.19.1553024103279;
        Tue, 19 Mar 2019 12:35:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553024103; cv=none;
        d=google.com; s=arc-20160816;
        b=ewPn8tuFPkWRD1sNL6pEkzHvoQwPJLDDzB8k7pcJJbj82/QkpPsUPpqhVTt8iHpuN0
         JuCKGK4FW0n3ZgHNO+EL4TzMTY+3ZgZNsY5K8MMN36Bx5SuMqKSSbpLcQnDQlAVS8Rm2
         OiRdTQ4k0qcjipuadYicBJlK57tfRXKkVVZQ8oT6RhUjEQeUi+hw+lbutRzek/ZHcJ6C
         B0epWfCst2+diNgqabnn8EP9CcCC/8DOc7TyutWlNuBErZwsfOlHKFopyB/g7TnlI+7o
         Q+9RPBY9ApGfqx2NbN5oB/RwQFFwD8D/Q88FzaImZfJQ7Cx+I5GdfQLsveqpg4+TxDEr
         jCRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=m/nS8vo33UtZ9d+8Ja45xPr9BDqJkei7QCQgN/JNs80=;
        b=DRrpVJV0PPOVqdckqKx/C/AwxHD+w7+BU59Fh9J6vjoaUcjk3ojhmmFPDvKUzi3h/F
         7rwyASf6CW0MkinIKjxfd8ZYMBoZWd5BDk6uiIVbtCdSMp1moK3ST4bMNuhItuTzEzEp
         efhlpVu6SNb2A1oQZcf9jPXeBUkpmHusTBv9eTvt1swENx8vyEz4MwOjMcDssmOxazZe
         iey1986UaH++nUZl++Xx5zU1uMlXak9mo8ZPBg9y39Z0gsqShIXEyn0cVtMNp3jTBz7u
         /zbZFxx9UCF64fsoCVp7Lf8Vhlju0fXuYUbYS58xjAziaRJpbvGBIG2IY3oZPkW6uUPH
         PgTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=hMR0zHOk;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t17sor14703059qvh.21.2019.03.19.12.35.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 12:35:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=hMR0zHOk;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=m/nS8vo33UtZ9d+8Ja45xPr9BDqJkei7QCQgN/JNs80=;
        b=hMR0zHOkZrXLZwJ97N8diKlyUgvebj2aWvuz85sZGbKxFbUToPaDSVV439URZgv2D7
         LDeI0An4912DKbzKcCNep8cTfzTqQmYJkhT6SdnxrE6iQFCO6u2R2ox0POqMGg1Msc8i
         iCoYcioB3Twu5NgtCZoYTXjGTSdgHW8pdkYkJPVidcTa4F9AIwGQaqqsoVIUAckesQZB
         BW9MP3dVn9wMfdclKudWW6ATgio51TNGkqyA2jlbBPi04AWIBm+/Pv1a6vfH1i4ypbPz
         Ba74qSTVRlWxwvfnH0s1e3NndfrwEra+805hCB9aeZYcHloZveAKEwP2sp1FVwHCPxQg
         TVTg==
X-Google-Smtp-Source: APXvYqyqVlOmG00J+tKSsurGFAIuvuak1+NK3ijKQ7GFmrIZyixT2wPFTQHKlVCtCX15NSlJ29TiEQ==
X-Received: by 2002:a0c:8693:: with SMTP id 19mr3392175qvf.73.1553024102987;
        Tue, 19 Mar 2019 12:35:02 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id s78sm5850494qks.0.2019.03.19.12.35.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 12:35:02 -0700 (PDT)
Message-ID: <1553024101.26196.8.camel@lca.pw>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
From: Qian Cai <cai@lca.pw>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Daniel Jordan
 <daniel.m.jordan@oracle.com>, Mikhail Gavrilov
 <mikhail.v.gavrilov@gmail.com>,  linux-mm <linux-mm@kvack.org>, Vlastimil
 Babka <vbabka@suse.cz>
Date: Tue, 19 Mar 2019 15:35:01 -0400
In-Reply-To: <CA+CK2bDhB8ts0rEc46vVT-mR8Avx=DZAdyMTzxqOD99MP7dOEQ@mail.gmail.com>
References: 
	<CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
	 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
	 <20190317152204.GD3189@techsingularity.net>
	 <1553022891.26196.7.camel@lca.pw>
	 <CA+CK2bDhB8ts0rEc46vVT-mR8Avx=DZAdyMTzxqOD99MP7dOEQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-03-19 at 15:27 -0400, Pavel Tatashin wrote:
> > So reverting this patch on the top of the mainline fixed the memory
> > corruption
> > for me or at least make it way much harder to reproduce.
> > 
> > dbe2d4e4f12e ("mm, compaction: round-robin the order while searching the
> > free
> > lists for a target")
> > 
> > This is easy to reproduce on both KVM and bare-metal using the reproducer.
> > 
> > # swapoff -a
> > # i=0; while :; do i=$((i+1)); echo $i | tee /tmp/log ;
> > /opt/ltp/testcases/bin/oom01; sleep 5; done
> > 
> > The memory corruption always happen within 300 tries. With the above patch
> > reverted, both the mainline and linux-next survives with 1k+ attempts so
> > far.
> 
> Could you please share copy of your config.

https://git.sr.ht/~cai/linux-debug/tree/master/config

