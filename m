Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A889C4CECD
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 231AE217D9
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pugj6Iab"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 231AE217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C68DB6B0007; Sun, 15 Sep 2019 17:38:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3FF96B0008; Sun, 15 Sep 2019 17:38:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B06786B000A; Sun, 15 Sep 2019 17:38:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0227.hostedemail.com [216.40.44.227])
	by kanga.kvack.org (Postfix) with ESMTP id 920506B0007
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:38:34 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 23CAD181AC9AE
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:34 +0000 (UTC)
X-FDA: 75938469348.12.grape07_4ac20178c4e3d
X-HE-Tag: grape07_4ac20178c4e3d
X-Filterd-Recvd-Size: 3545
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:33 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id y22so21604543pfr.3
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 14:38:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=21oLpXaZj4J497/4OayRnybX2D972/PKmY9dbt/gmqc=;
        b=pugj6IabxpP/wd6MMnBsyU3TdktFk/BWNqILYV2Ku0+TFI9JYMkg6iptGwDMg30Pnr
         xMviD8MU4ZygdlW+uVZzm0rDxP1H8d01VEYYz5YEuqh2lidM6XOouo8ieHOSuY7ILJzn
         ueRebe0cUyaDavwpHajRItBoXoFTC0lDs+qiENH/lmiGei4kEnT73iUZm3SPks5oTUsS
         bE3BhIyg91gbX9l2w2l25xzZH7CX+F/HDSzagPlGY54txF3UZmp/fP5EWqesuXpmw6EK
         InYWZEXsWkcicM+EMC5e16Rfklu3pcNRFt2PbrL+v+GbjrYrY6luMB3EscobTBglWWPU
         uXHQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=21oLpXaZj4J497/4OayRnybX2D972/PKmY9dbt/gmqc=;
        b=KhuwHNNrSwl3qhEC4tRA8WoLvdreXLgcw0d66M7qNeXtXMeLadjxC4WPPkEpZTPKnT
         aQ/17c5mRRB3peLwp5ZZ6QhJJ2jbfuYCMCnWN7ahPmOAVtuv/tWKsfZ2s2gW05h4GGBL
         VsCfbVxTzcZkBdbBkNLjJv+6xMIusKfd2xqu5CLKlNY2nwavkffthe4I7U98pXQIU0ad
         PgAPU760iHsDSFeWCcRnyKCrrKchgag2CrPATPZzPSZooImkqsk8fSSkhGcKOzHjohIW
         hGetiGfEOHTFsAvwr4f79E1ikbOuWGiJba5tV3OIPpbpWXU+VzU2yIVuInNXS9IT+UHY
         iNzQ==
X-Gm-Message-State: APjAAAUlxcOwV+Ur1V5a/zyYfsVewHTCgi+Gzq+K6RrSRcIrH79CHJxE
	lih8tjm91NFdnsCXQKJpoxGi+g==
X-Google-Smtp-Source: APXvYqwtSGea6ppywW4+Bn4Lihxar6q1j9svt/dw/9+wCG2I1VwRpQ9e9HxLMiwUsV1n9sfrxnzRWg==
X-Received: by 2002:a63:3182:: with SMTP id x124mr17080393pgx.41.1568583512166;
        Sun, 15 Sep 2019 14:38:32 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id n10sm31240211pgv.67.2019.09.15.14.38.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 14:38:31 -0700 (PDT)
Date: Sun, 15 Sep 2019 14:38:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Pengfei Li <lpf.vector@gmail.com>
cc: akpm@linux-foundation.org, vbabka@suse.cz, cl@linux.com, 
    penberg@kernel.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, guro@fb.com
Subject: Re: [RESEND v4 3/7] mm, slab_common: Use enum kmalloc_cache_type to
 iterate over kmalloc caches
In-Reply-To: <20190915170809.10702-4-lpf.vector@gmail.com>
Message-ID: <alpine.DEB.2.21.1909151414380.211705@chino.kir.corp.google.com>
References: <20190915170809.10702-1-lpf.vector@gmail.com> <20190915170809.10702-4-lpf.vector@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Sep 2019, Pengfei Li wrote:

> The type of local variable *type* of new_kmalloc_cache() should
> be enum kmalloc_cache_type instead of int, so correct it.
> 
> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Roman Gushchin <guro@fb.com>

Acked-by: David Rientjes <rientjes@google.com>

