Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CAB1C74A4B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 10:33:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A5AB20838
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 10:33:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DQ3GDRDo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A5AB20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1D508E00B2; Thu, 11 Jul 2019 06:33:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACCB78E0032; Thu, 11 Jul 2019 06:33:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BBCE8E00B2; Thu, 11 Jul 2019 06:33:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 639898E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 06:33:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o6so3000208plk.23
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 03:33:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=QgO0JaQSHY4vnem11Q6Fyo0jOFA4EUMpQN6nqlQarLg=;
        b=XqI7A6qVuH1o/Qu0QwIR5hkok3ccx6zBuGvvJ5aq8aqVI6uu9uTrzSGPg7469SU9a8
         ZBQcLsYyO8hJrpJ4BaJGWe2/UFj2JZJCMGpvHK8rPLXQPv3yTWOWQxIOCebt5vA+7juf
         OjStOmY83QxSVOS1612Tn7sSWu98M4RasleD1Abj5kdJECyTegOIl0zqc7SUCYsBmSZl
         tZyRBMVS7Kn+hyxlxTK/nMka/1AHKZ8i/bIbYRRd9k2E/KhShLveZh00guKoDJoO4LIK
         vwU9zJrWKJlkFz0E4ZHPlFMlqHWDaZN6e97qnmzYWwgn44qCyIgsgAaHQeHz6Xz2C1Ka
         5YqA==
X-Gm-Message-State: APjAAAW3NCc9+5zwJr6Yr+rsCF9vGlxlyw3CFte5Uw2pqSgMPInoMyL/
	zgzopbmL9L6lmIuglyrFhONW8aUSmywYEPcSLmdM424CpaQDl3xBcK9+pSQAODhmiom7vOvli8O
	MgyHv6v/pMZYRkQ2fIrJL6Vh9fSGkwWIC2htUrUOklBfLBxlTnsJF4OgHOCZ+QlySnQ==
X-Received: by 2002:a65:5cca:: with SMTP id b10mr3705251pgt.365.1562841183720;
        Thu, 11 Jul 2019 03:33:03 -0700 (PDT)
X-Received: by 2002:a65:5cca:: with SMTP id b10mr3705182pgt.365.1562841182864;
        Thu, 11 Jul 2019 03:33:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562841182; cv=none;
        d=google.com; s=arc-20160816;
        b=uxjOlgqmlri5bKbPXeGfeHqaGRDtKIuKqxqZ11kT8jcIfSAurQhj++Kwexum4edyS0
         xYky1QalhyNen2hkHXFsTSl5ot+wXWpmFI8ZGMGl4Nsis9KwqOnfSIYQFQhG9DegaxAR
         6xjZ0eFqJ3g3TuFafT8zknZWTPyNENlyWFfnOe5Zhp58yMOBVE3JgmtxppNsHPpPOY2B
         1+4hUJuDcig9lSF1QsN46pTbZ67Zamfq8hkTpm2SOeMT9phSSZhXze1hx2h588uVYDYE
         Y5ZOItz+PHlnDnflsC03lpEggD7ioXia2hPlGjMpPkkeVhAsrTD7AInpCQEyaaVRT3VE
         Nvsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=QgO0JaQSHY4vnem11Q6Fyo0jOFA4EUMpQN6nqlQarLg=;
        b=Rgy6nQbSyXMEAv8vQvdJfoV2pDFcaevCy3lLqtGRlGiAfZ18/1E9lsyOk+whyLj7uE
         roaNTjKTZbT0wnTUkTQ/LZW6cYwB+5goCKMuk0wisF3C7+izyhHER0EWSPsapJtsWWog
         s20H+WRoVA4iyRwM2MYJh3wZCcRtGyuM/L5mU702h4W2g+BbjjrbBeOjwOJW0/cOlg1v
         vBgSii3T+flFxqEkOeJnh2C6dUxXKmcleJvcJiWplO98bvZS7bBBmKL20dHXU8bHYlFy
         l+siudthW4V5hkZvFk1dSAH9ZSLBxH3+PQZr6pv8U7MDwf32wXJXW3fjFLTYfpdlLi67
         IHNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DQ3GDRDo;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u13sor6454411pjx.25.2019.07.11.03.33.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 03:33:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DQ3GDRDo;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=QgO0JaQSHY4vnem11Q6Fyo0jOFA4EUMpQN6nqlQarLg=;
        b=DQ3GDRDo6ZuNjOSR3UHG+s0d1LxNGZvPzSaJsIYp8+OlmUuBgFj2VuEbOTBNaoZ0eh
         KYzMXtEBMS67xXmsEThDtXCMiOFl/wHg/CXkj5erKCm9McDmtXT47vJYVN5WS/CjEd23
         QHdQpKkAnHuI4SKeKAKPjdekPIyChEv/k676up6oVrY9q1wQLkDsteR1EDalAYrX5eY2
         ibHvDy4SxcNPGMBafYmo8C9MtWx6buDs95iahvNPf7v8Ha2+luXs2UVS3kE72gFoto8b
         bVeGwP2O5573U5C3Ylu/Iu4mXvP3yLfZH5jsWU+YUZAPiTTiAN8NlvfcQTm82GR/APzM
         ld0A==
X-Google-Smtp-Source: APXvYqzK0dRwEomozlBD3wvw4N40TKmDcZvFjPBT8AONodHNnHkIbT1P1WOUA7C7HYFWruPQhFDFWg==
X-Received: by 2002:a17:90a:26e4:: with SMTP id m91mr4017907pje.93.1562841182209;
        Thu, 11 Jul 2019 03:33:02 -0700 (PDT)
Received: from localhost ([220.240.228.224])
        by smtp.gmail.com with ESMTPSA id m10sm4677307pgq.67.2019.07.11.03.32.59
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 03:33:01 -0700 (PDT)
Date: Thu, 11 Jul 2019 20:30:00 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH] mm: remove quicklist page table caches
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-arch@vger.kernel.org,
	linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org
References: <20190711030339.20892-1-npiggin@gmail.com>
	<20190711082539.GC29483@dhcp22.suse.cz>
In-Reply-To: <20190711082539.GC29483@dhcp22.suse.cz>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1562840680.snxfuzmtxv.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko's on July 11, 2019 6:25 pm:
> On Thu 11-07-19 13:03:39, Nicholas Piggin wrote:
>> Remove page table allocator "quicklists". These have been around for a
>> long time, but have not got much traction in the last decade and are
>> only used on ia64 and sh architectures.
>>=20
>> The numbers in the initial commit look interesting but probably don't
>> apply anymore. If anybody wants to resurrect this it's in the git
>> history, but it's unhelpful to have this code and divergent allocator
>> behaviour for minor archs.
>>=20
>> Also it might be better to instead make more general improvements to
>> page allocator if this is still so slow.
>=20
> Agreed. And if that is not possible for whatever reason then we have a
> proper justification for the revert at least.
>=20
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks. If it's agreed with ia64 and sh maintainers, I can send
individual patches through their trees, then the removal patch
will be functionally a nop that can be easily pushed through.

Thanks,
Nick
=

