Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E0B8C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:58:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59A1D20869
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:58:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59A1D20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09D478E0002; Tue, 12 Feb 2019 12:58:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 025148E0001; Tue, 12 Feb 2019 12:58:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E30198E0002; Tue, 12 Feb 2019 12:58:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B652D8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:58:30 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 42so3491749qtr.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:58:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=twYdK6RBK9D37dYQYUuIfYrcYIV38FRAgLfbAT1BBuQ=;
        b=BIDYF0cDGjYd29EJc1z/igkkgyPlVhVpDkrWTDqfk09zoLDniThIkqDIZUXeEBBpM2
         OoLn3Dtl1AdDcuSUXkRITDbswiHPxhibbhveFqUkaJFVYjEp8OzTEP1CxlkEOjk8TwbW
         jMN9paWdKl4m+VFKBxGKB7qjAvX2TFhFXE7GGub1sC8r6H8eIKhuilY0s8pVVwJdzHZ8
         Z+7mB6XVGmFjM/muHAzmGVkPxg00KmVU336NGk4I/CwKGuCyAbvr+W9TkHbE7YvL7ejW
         /stJwU3SBIygwq9mRs6kwHC+BO+snfinKG9hMAGOyvzfEVkAOHxI/Ytdx4WCmipSzEBN
         9vbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuauvC6HCjKIv3/BkihRoXlzoMwIOjxAAOGI9jSw8hUW/GuhdInb
	qPMrE1h3+ntaeDdonh1w9d9RloFyJx2+Pezb1v4X/zBnlYAw+/vrBQzmjaMg8xtdVRmK35L1/CO
	f5cXuC6rcnH4YFc9Yudb5ZMdsE+gPJ5+zuAATWhb8lSlc7224SH5FYwxAcRK3M0ROtg==
X-Received: by 2002:a37:66c8:: with SMTP id a191mr3531188qkc.281.1549994310505;
        Tue, 12 Feb 2019 09:58:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZpQgTZnOt3LYBOxnx6FlV485kDakZqFK1zdxWSrfd4GZfHncs91QM46nEyTfnyQqc7+Al8
X-Received: by 2002:a37:66c8:: with SMTP id a191mr3531160qkc.281.1549994309950;
        Tue, 12 Feb 2019 09:58:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549994309; cv=none;
        d=google.com; s=arc-20160816;
        b=UQ1WjZ7TWd5C6TodHaAPLh3jcmSmO+m+LBtQObxjLDDSfzZH3zrV8tTsYkivPC+93e
         w38V6hZDyYbK3FW9m130aGIwHNur5K62DjR39Sn6jOgA3aWZK55p3NPvLUXEuN5SKPOx
         tZ7mUMpM63JyKwxtMopccvyzLScAOZP0XxEVcSBN5Eilhf88YDuup+CsxUZuNnwomipI
         AzMAbYJFVaTYZy8+171wJq+ZLV2MNyQyucHIRDcKmSRUgP4ftEdKNh2WYNeC27n6xi3x
         iS4Bdw78q+LpL57DtKV43Y8Jaw5+qeYUA841eHI4PTRQJ/AePLvXZWDzHsAWGyci1OXm
         WObQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=twYdK6RBK9D37dYQYUuIfYrcYIV38FRAgLfbAT1BBuQ=;
        b=irmgkpB44bZVqsnI/eweHnZTVB1j1nYbsgH25O9q6Z+cn5uYaWFaQjTQ4G1G/iWDSj
         AHKupJcOdJmjb3sQH+cQHWs6I4AtEaCFDyvrCG8xO4zbUo4VMpMGvnWw2XlL4YJTroBd
         Ink8WLUSG71+TwqnNRq5odhZ4JmJgiMxKq/Xwur7nSgThRtZgMucKCzlqCAecmHLLckq
         0nVK91o5RXXrGtmvDprsZ6etolcTOKdosbkEreMu10f4MBsZD8X/8V4EOL6/Q0JVC5k0
         YmjO4jRs5kNy/EmDf1OGTNLq06ab+F23/AJqbSJMXbMqomKlZBC5yoqpsvUKECHPAfk/
         AuFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r22si2316990qtp.273.2019.02.12.09.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 09:58:29 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D8D2B82A8;
	Tue, 12 Feb 2019 17:58:28 +0000 (UTC)
Received: from carbon (ovpn-200-42.brq.redhat.com [10.40.200.42])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6A8CC17AD3;
	Tue, 12 Feb 2019 17:58:21 +0000 (UTC)
Date: Tue, 12 Feb 2019 18:58:19 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, netdev@vger.kernel.org, linux-mm@kvack.org, Toke
 =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>, Ilias Apalodimas
 <ilias.apalodimas@linaro.org>, willy@infradead.org, Saeed Mahameed
 <saeedm@mellanox.com>, Alexander Duyck <alexander.duyck@gmail.com>, Andrew
 Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, "David S.
 Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>,
 brouer@redhat.com
Subject: Re: [net-next PATCH V2 3/3] page_pool: use DMA_ATTR_SKIP_CPU_SYNC
 for DMA mappings
Message-ID: <20190212185819.2285a501@carbon>
In-Reply-To: <201902130132.DXE6rH81%fengguang.wu@intel.com>
References: <154998295338.8783.14384429687417240826.stgit@firesoul>
	<201902130132.DXE6rH81%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 12 Feb 2019 17:58:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2019 01:12:59 +0800
kbuild test robot <lkp@intel.com> wrote:

>    net/core/page_pool.c: In function '__page_pool_clean_page':
> >> net/core/page_pool.c:187:2: error: implicit declaration of function 'dma_unmap_page_attr'; did you mean 'dma_unmap_page_attrs'? [-Werror=implicit-function-declaration]  
>      dma_unmap_page_attr(pool->p.dev, dma,
>      ^~~~~~~~~~~~~~~~~~~
>      dma_unmap_page_attrs
>    cc1: some warnings being treated as errors

Ups, in my compile test I didn't have CONFIG_PAGE_POOL defined.
Will respin a V3.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

