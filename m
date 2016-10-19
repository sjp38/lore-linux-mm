Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8EC26B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 03:56:40 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k16so29884451iok.5
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 00:56:40 -0700 (PDT)
Received: from mail-it0-x22a.google.com (mail-it0-x22a.google.com. [2607:f8b0:4001:c0b::22a])
        by mx.google.com with ESMTPS id 137si23132270iou.129.2016.10.19.00.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 00:56:40 -0700 (PDT)
Received: by mail-it0-x22a.google.com with SMTP id 66so20946618itl.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 00:56:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161017131228.GM23322@dhcp22.suse.cz>
References: <CADUS3okBoQNW_mzgZnfr6evK2Qrx2TDtPygqnodn0CwtSyrA8w@mail.gmail.com>
 <20161014152615.GB6105@dhcp22.suse.cz> <CADUS3o=64pZae+Nq302RSRukCd3beRCtm3Ch=iDVkrPSUOODZw@mail.gmail.com>
 <20161017131228.GM23322@dhcp22.suse.cz>
From: yoma sophian <sophian.yoma@gmail.com>
Date: Wed, 19 Oct 2016 15:56:39 +0800
Message-ID: <CADUS3onWsGqXxsd-=QUjShSS=7K2HMBoHewzx5We8S+tyTsuEg@mail.gmail.com>
Subject: Re: some question about order0 page allocation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

hi MIchal
> I am not deeply familiar with the mobility code, more so for an old
> kernel, but my general understanding is that that the migrate type
> information is not exact and there are races possible.
When we add more debug message for checking the issue.
so far it is only fail on watermark check.
and it seems there did race condition happen like you mentioned to
make the final memory info is incorrect.

Sincerely appreciate your kind help ^^

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
