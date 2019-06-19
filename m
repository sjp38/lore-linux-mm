Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FA49C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:39:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E08D2182B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:39:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E08D2182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FD4E6B0003; Wed, 19 Jun 2019 09:39:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 987248E0002; Wed, 19 Jun 2019 09:39:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84ED58E0001; Wed, 19 Jun 2019 09:39:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F60A6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:39:18 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k31so15910966qte.13
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:39:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:organization
         :from:in-reply-to:references:to:cc:subject:mime-version:content-id
         :date:message-id;
        bh=rWhkzRDYV8nWWO/NxJvkJYF6b51Z2xk5BRN8V6TUq9U=;
        b=JCZu+DZSm6OM7vkEcKN4qZ4HkGb7ihZg+T+5h95jcfX1iY04NMofts5YHXNli5KZtT
         PGfJ0OKg/Q1zuNNGUP5ueYatSp4yOe5VVGLVljoSIMGZxQhWSl0COCeBo4HWaduaZJSP
         24ASpY8M1dYan6w80lA6LrP4rdg7nKln35Qg217En0QVuhoNcfgJYx6e621qxeDDGyqX
         A2bDW9Iqtgh7kLs8vw8SO//AQ9Z6wMOFny1cjxLWrkpZvOfuyE7GT/n/56h+GjWqt5IY
         /LmGHtmdQrrq2SoLmv2gq+IjPb8wNwD/wFtcPyN1W8JKRCx4yJhivRu1WGazqRf9iLR0
         2xUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVe+ciqJQ1+1nfFgyLZwjgbuJCo3EVnzF02oyyy5b2RDSeacEkN
	ULdhcS9XnALv0NLJKkqgTuQVK6w0+vYFWyix/h51GBsf/C42kBLRFtDAYqEvsz5u2HIfxvyGZb6
	EFOJJri/5MDKywFZIpCxO0PZsUlCUA87esxMSobE7J7tKF0kamZgpNQ/IRv9w+iIcXQ==
X-Received: by 2002:ac8:42d4:: with SMTP id g20mr106045838qtm.78.1560951558191;
        Wed, 19 Jun 2019 06:39:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGiRDoKZ4jXkxeCdbOnAlnelYt5eQSy/XHuVVWXv1f7FIPqRTybUdCfpb2Hm6NGy2DX2t2
X-Received: by 2002:ac8:42d4:: with SMTP id g20mr106045786qtm.78.1560951557529;
        Wed, 19 Jun 2019 06:39:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560951557; cv=none;
        d=google.com; s=arc-20160816;
        b=Xao9sVRcsjbWNzLX3imawFr4NyOkfBmawp+jDOdykRvi6w89Ol6oXqCagy3RFIXPd9
         LbIr/Py/7ix4cbPOtgFLngKTFhJW0t7bWiY3ixGYH2BvVGhZimJkF3sshpeQ/Ml+2tzm
         6oVfO03JAff6cISbArM7mBr/GShNVAOYFHJw3ikvta8//J86Aw5N6KZQb3zmjFsTv9Er
         3XbKVv17JrTCiXl8UqjNyr7e7im2CMfjACm/OoyGsCkEy37LDOsa0GQoEfsmvfOglxVB
         OGyxCLpHsJNcplUaBnI6pguAGfZM4ymaM0BMSMzSGStlwEnUGV79zFXPKUWfUKeV1P5y
         4kfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-id:mime-version:subject:cc:to:references
         :in-reply-to:from:organization;
        bh=rWhkzRDYV8nWWO/NxJvkJYF6b51Z2xk5BRN8V6TUq9U=;
        b=k9cBiifuNwB4A9R0jZl7D97BDGYvoRIxZAyFpUODub8mm+oWOsB2NNsXQA9F5epYh9
         DC+vP7gvIqOogd6wX29HukCyVm32ntiLuBCJ5BO4tcw3LAMZuPS5EDfhpIBrZ18tX/km
         W4IJtKEw5iMRML0VAhVQs46FP7tI6HUxdJYUfdtSkTIWDqHgC4KZh2ZkF9H58Pri7Rvr
         yAym6qhhJkYU/pcliLP125Q0W4KLANvo7loiMIzQ4vWTJZjtWAsYUDjCA21PeNOzwEHw
         Nr92t+VKISax90FGbDz23BgntZ4QpnpgDYwmaLdeZHWshmRQRycSm+j1A7WiAxMzVLz2
         iONQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x26si2315707qtq.233.2019.06.19.06.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 06:39:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CD90A30860AC;
	Wed, 19 Jun 2019 13:39:16 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-120-57.rdu2.redhat.com [10.10.120.57])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3330618B42;
	Wed, 19 Jun 2019 13:39:12 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20190619072218.4437f891@coco.lan>
References: <20190619072218.4437f891@coco.lan> <cover.1560890771.git.mchehab+samsung@kernel.org> <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org> <CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: dhowells@redhat.com,
    Linux Doc Mailing List <linux-doc@vger.kernel.org>,
    Linux MM <linux-mm@kvack.org>,
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main dir
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <11421.1560951550.1@warthog.procyon.org.uk>
Date: Wed, 19 Jun 2019 14:39:10 +0100
Message-ID: <11422.1560951550@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 19 Jun 2019 13:39:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mauro Carvalho Chehab <mchehab+samsung@kernel.org> wrote:

> > > -Documentation/nommu-mmap.rst
> > > +Documentation/driver-api/nommu-mmap.rst  

Why is this moving to Documentation/driver-api?  It's less to do with drivers
than with the userspace mapping interface.  Documentation/vm/ would seem a
better home.

Or should we institute a Documentation/uapi/?  Though that might be seen to
overlap with man2.  Actually, should this be in man7?

David

