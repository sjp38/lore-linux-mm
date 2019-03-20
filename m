Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83CE9C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:37:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43D232175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:37:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="B46dmS0S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43D232175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEAC76B0003; Tue, 19 Mar 2019 20:37:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9B2F6B0006; Tue, 19 Mar 2019 20:37:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB0246B0007; Tue, 19 Mar 2019 20:37:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7296B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:37:34 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 54so353444qtn.15
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:37:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=0h/2uwRBvIlbPAuP0Ld0/vo0HAMK4qAewrIyttglDvs=;
        b=R/ieyZ7bR/ySVV9nbM7l706UhkLxEqJWk8d5fAabpRAysrH2ACWap5Iinpvp+kC51x
         qOq9PuZuctPM2YIDIzOvm3DOBKJXaOh0L8Yc6Xxha9iuzc9w+B1o5mBTGH3UU4J2ZM2c
         W79gYRf9G9hIQ2OA96hIu7eBQKu6r8I9U+7HxTpgH7RioMouIVft2QC9wEf4Cue6X2ND
         9Rv9zR+6gsron6MkT1FXGMkQL47mzsft9w0+1ie/yaw27+cvh6QDDyVLu2jerER2+dqu
         6LieVsyH23yEx8x4UcPdQJ3vTMH4nKdlC3TY2r9jS6T1o34d7a8LA+oBnduepAjZN56H
         NBQg==
X-Gm-Message-State: APjAAAXNH2DkhELxiH6M194rkvdI1sLg0EqRumg0T0ONsDjMr/oJrvyA
	B7pxeCBfr4L9P/n/zqqm986HgEvov7MgHmLFo0GFJxCkVliN8EZvbCklaK0OZmcopOi4TjHAmni
	Dr/0MYXhBC+bPTL+Bu3wQL32zT42E+hQIOmxuM7V3vJbgBakwHPSeWUoJgs6HasQ=
X-Received: by 2002:ac8:3042:: with SMTP id g2mr4827778qte.1.1553042254431;
        Tue, 19 Mar 2019 17:37:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh7LZ+eK9MnpORSEZRo1xFCcyjRqJMjqf61aMHHi/PQ9ymkrPhVyV47BMR+R66e1qN8+P2
X-Received: by 2002:ac8:3042:: with SMTP id g2mr4827740qte.1.1553042253788;
        Tue, 19 Mar 2019 17:37:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553042253; cv=none;
        d=google.com; s=arc-20160816;
        b=hk+RFz1RJTAKjdrnw2ktSlbWcI8UEwYrLN1aR4YWVhb59LOktWFaKUZfAmZ7CAMx/8
         Ybe23wLh2KGTFwLnYEWXqh+6N+nla9wjxJQ3GCqRntTRiBnUDVCmiJ7clE3mXQK4wjRY
         zpiDhKbhi+ErqMQ72wSiR8vL/FXT/sRUfTNVzVJMQhdqZwFWU2RRXSYLTLrjm1qpKakq
         9YppycdSViqpCSgBF6cDter8Mj0gT44KK/VS+u4XzCnOGoMYudDM73y4cPN0jPbqXAUR
         a+OWJCzPkSrkvGCTqRjoYL0VcKqnEk3/Z/5hsM7YauGEeSqzf31wj+Xze783brH8e/09
         pNsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=0h/2uwRBvIlbPAuP0Ld0/vo0HAMK4qAewrIyttglDvs=;
        b=Gbu7qnVblIEXjR9bV/wYWrnIOuxYnsGEy75rgwIRIJ3fALe87Mz97eQemxkjkxqxah
         436Ufg8Yz5npdi27Zktda9Y0S3g5ZtQ5JGCVHs142Nsin90RqC28TYm/8AIlojmmnizK
         2D/xUBuonozHpQKtODVXKMUevPOKik5IZsPNxmQ8sWRhi95yGSsFY76p+W2Pyz+K8wWA
         2uYEU9SeyQLE+X4BuY1T4ZXhoY4cq0LsrWqBCiMRK7fkWkS5+/xyD9D4oxl14Gq3BwTT
         SGekL0emB1s3ntec/VxiDQ/sWRnERe1NCPan1xKa2EUkTTfOaTxq0lk2usLhdFdnegHy
         Lpvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=B46dmS0S;
       spf=pass (google.com: domain of 01000169988825c0-df946577-83d4-4fc5-a329-52b65bec9735-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=01000169988825c0-df946577-83d4-4fc5-a329-52b65bec9735-000000@amazonses.com
Received: from a9-31.smtp-out.amazonses.com (a9-31.smtp-out.amazonses.com. [54.240.9.31])
        by mx.google.com with ESMTPS id y129si251626qkc.79.2019.03.19.17.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 17:37:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169988825c0-df946577-83d4-4fc5-a329-52b65bec9735-000000@amazonses.com designates 54.240.9.31 as permitted sender) client-ip=54.240.9.31;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=B46dmS0S;
       spf=pass (google.com: domain of 01000169988825c0-df946577-83d4-4fc5-a329-52b65bec9735-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=01000169988825c0-df946577-83d4-4fc5-a329-52b65bec9735-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553042253;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=0h/2uwRBvIlbPAuP0Ld0/vo0HAMK4qAewrIyttglDvs=;
	b=B46dmS0SWtVlOlFZQdQyHlxbvenSrq/7gSMe3/2XFjcjJbe4nT122txeVJaVkbNn
	TLzfpSZPclv/krs3yGUiCaaqqsOlDxRoqAf8VSHAYvnyH41+eX0k5Own0BmAzc0KpDH
	0yuYak/RCKWrQlwGoGoINmRub18iVToaEGTJY5WU=
Date: Wed, 20 Mar 2019 00:37:33 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Michal Hocko <mhocko@kernel.org>
cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, 
    yong.wu@mediatek.com, yingjoe.chen@mediatek.com, yehs1@lenovo.com, 
    willy@infradead.org, will.deacon@arm.com, vbabka@suse.cz, tfiga@google.com, 
    stable@vger.kernel.org, rppt@linux.vnet.ibm.com, robin.murphy@arm.com, 
    rientjes@google.com, penberg@kernel.org, mgorman@techsingularity.net, 
    matthias.bgg@gmail.com, joro@8bytes.org, iamjoonsoo.kim@lge.com, 
    hsinyi@chromium.org, hch@infradead.org, Alexander.Levin@microsoft.com, 
    drinkcat@chromium.org, linux-mm@kvack.org
Subject: Re: + mm-add-sys-kernel-slab-cache-cache_dma32.patch added to -mm
 tree
In-Reply-To: <20190319191721.GC30433@dhcp22.suse.cz>
Message-ID: <01000169988825c0-df946577-83d4-4fc5-a329-52b65bec9735-000000@email.amazonses.com>
References: <20190319183751.rWqkf%akpm@linux-foundation.org> <20190319191721.GC30433@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.20-54.240.9.31
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Mar 2019, Michal Hocko wrote:

>
> I believe I have asked and didn't get a satisfactory answer before IIRC. Who
> is going to consume this information?

The slabinfo tool consumes this information.

