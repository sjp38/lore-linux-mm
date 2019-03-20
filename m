Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D548C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 12:58:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F13652146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 12:58:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="H8+ML9EJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F13652146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 829226B0003; Wed, 20 Mar 2019 08:58:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D8F66B0006; Wed, 20 Mar 2019 08:58:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C8266B0007; Wed, 20 Mar 2019 08:58:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADA46B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:58:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n10so2604323pgp.21
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 05:58:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=r0m7ZFaaZshpwxhnJfAtldhrLDgyfjIgHyxgRiqGO4E=;
        b=HtNBYo5wMZqGI/0WQpumPmQcUbT8toA/51zcEVtB43C9MsFk+z+mH6Xg3CcG6368sP
         iSMZ6rcuB2fCgyQJh6lEpw+3mI2d7jZHualUogI3gv20bbeEfOH2MAbgmfcxsmfAkAP1
         w3HABIMbsqRQMLvH0AZLtx9jRomb1zSNhipeu0OixTwNJda7Wi3LAyAJnFPZ87fmM77z
         kap/0G8Jwfrxg+koAtLwlrkqY44KBsVyTd20C02lyPDp24qVOFCsSm1eECO6Z5N+uXrQ
         2dgW5zXG8/iKcBoMhPYP85x7Nk2WH3FmquwQ4twmDjN8qya1DzIoR/D0/F+AI+MtEySe
         zetg==
X-Gm-Message-State: APjAAAVygGax4oO3TRykOr0qA7/+yJFKRCR7Ch/WrIEPsD1vUJFyQmaz
	26Kd+M7/ZWZ4xps49troHx2cW+L+LA0UCKJN7LDBobuyDnz91Cr6ROLJi7hYHy4fZLoB9wZHsQv
	Q+4zpbQhHEZXxxnWInfr6Uu/qKfMEr1IpIFw1GIEhFeAE4qXPJTjZ5ey53i0+AJPyOg==
X-Received: by 2002:a17:902:8693:: with SMTP id g19mr8315690plo.157.1553086729747;
        Wed, 20 Mar 2019 05:58:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcQguK6PGwka5Z3zUxwajmnVSo2qCFQu7S8/EQrDqImuZa/VIlb5GNvBAX2wjthnr1yz/h
X-Received: by 2002:a17:902:8693:: with SMTP id g19mr8315648plo.157.1553086729000;
        Wed, 20 Mar 2019 05:58:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553086728; cv=none;
        d=google.com; s=arc-20160816;
        b=HrcxJPmv+BGEqdk/A19FNm9SmxAWSCJgbiIB5v2waS41OtW4uui6TB1Lt0nJI+vrfj
         6c3Ha44i8atMhMZDiEeJ/V4+TTK37PRRGSX99YMSs9hi4+8q4W9y5M+p2CH6nfHuPMta
         yBp8Dh8ukc/Lyjxsnt9/M3yMCQC3jgdCmqI4DGKW7EcKAot/tfZlTdTUUMaV9K35MY2w
         h8joQOTanjtI1rQ0Skf0Ok5K08Pb/oii52S3QCy6nsUs2ckPkk7orsgE5RFUH3nxUNLg
         ynxwYLtX8217NBqvH4QSQTULOJoZz+G/BRtfx06SEP1P1F6ui8CrkRd/X7jQQvBIi2cs
         efMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=r0m7ZFaaZshpwxhnJfAtldhrLDgyfjIgHyxgRiqGO4E=;
        b=DZ8B2lh9SNxdZOCQdvn/LIwCZXJUuR3W/yNTOoobCZAZHbeLzQxCxYhsob2RteMli3
         u+UHXSJoSeQ47IpgvI8BK6SlaJ/dR7YdgglnPtPCFswib+ymFcshPhL1s5uSZVuCn74G
         U3B2mTuAHsJP7vCTJDAL4njIKFnEe6inD0Q0s6i5DxGaBgX+1iLsEjJxFOpGAZAxod+m
         pkBqp/xCZqg+JyhtU1/KcGH2rMKUb72a3nFZ6z+p5rHjCSF/or+p88NNybZmV6v6gioP
         FRh3RQ5x/ttwOXQyVxxo4ODOWrwzMVmxKfQklxJzXVAPPNPtuaIz0sCcS4uETtKDDdv9
         zeIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=H8+ML9EJ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z62si1636812pfz.244.2019.03.20.05.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 05:58:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=H8+ML9EJ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=r0m7ZFaaZshpwxhnJfAtldhrLDgyfjIgHyxgRiqGO4E=; b=H8+ML9EJWYA54H+kzgDLC35nx
	maaNfbzTgw/J8s0+R75PytWEqIW8X/fTnwqXRjYrve+j8e+H0Cuvg4jdwZFH8HHlKTmojQJdXAkip
	RzrzO6P5MLk3lcjjn3yCpG0cjPQt8QBOTTe1OSqatGJ0B/LUutaCE5mJJBUIiFvHKUPr+W6e1OgYx
	52X88zONqJhIU2FwQOtT3P6YmUm4IqP2ZfnN6oMdcs7LDCPE5hWTvIaNfrWniumKwIvxMn/CmWC17
	m7qIC3oBb0u39qTIatYmt1vOneE04tLMw9Yv6CTROMFp5rtIN4vbmBUgtZX7CHnj0YagMJfWiwcrN
	apiVFO/IA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h6anr-0005wS-BG; Wed, 20 Mar 2019 12:58:43 +0000
Date: Wed, 20 Mar 2019 05:58:43 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Oscar Salvador <osalvador@suse.de>, Baoquan He <bhe@redhat.com>,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190320125843.GY19508@bombadil.infradead.org>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
 <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
 <20190320122243.GX19508@bombadil.infradead.org>
 <20190320123658.GF13626@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320123658.GF13626@rapoport-lnx>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 02:36:58PM +0200, Mike Rapoport wrote:
> There are more than a thousand -EEXIST in the kernel, I really doubt all of
> them mean "File exists" ;-)

And yet that's what the user will see if it's ever printed with perror()
or similar.  We're pretty bad at choosing errnos; look how abused
ENOSPC is:

$ errno ENOSPC
ENOSPC 28 No space left on device

net/sunrpc/auth_gss/gss_rpc_xdr.c:              return -ENOSPC;

... that's an authentication failure, not "I've run out of disc space".

