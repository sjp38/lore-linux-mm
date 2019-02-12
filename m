Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1FF1C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:50:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B199217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:50:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="dPwog4Db"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B199217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B558D8E0002; Tue, 12 Feb 2019 11:50:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADD438E0001; Tue, 12 Feb 2019 11:50:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A73D8E0002; Tue, 12 Feb 2019 11:50:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2E78E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:50:12 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id y8so3284796qto.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:50:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=d9wM12jhuDTWdWt+Pkovf6I5uVUhrDCPMcwRg2iB6/c=;
        b=K9C1b16r9zy2Ovz5GIkpi2LqlrwIpYJ+jIde+nRSfCeI8GWRP1bCXdkjekmPqIDI92
         DihYG4+VkA753WPHD69uhHgfMqBqO9tmyBvirmWinrMld/IFwQvX/cOK0/jpNfNKimtq
         6w5YmbZdW6z3zbOOxWnLQetKRTiLo6r5tW46XwxTzmgQiDwkokyNFNjEYkEq8tOC24qW
         v6tbIFlyykA8hC6w0/regs7hSDUO3NWFvpfoFMwxBmpIIiM/589Gx8Wh8cPyLnW/uMcQ
         SQmTEKg/X1ZWDSD+3hDipJ1CI/M0AETjzxF6YEyygMtrYgQqqy8udEkhFW2oYZLQOVxC
         F/dg==
X-Gm-Message-State: AHQUAuYzBVj6qm3i5GTrLXb0igr3GPITs6CVonq/z+nqUmZlue2oZ+Vu
	cd9SZiBG6lYMZC3ibPO3p/GPbWvPdb/j7u2no0JpA3vapVjvufpFre+cYlAMGcH292u73/DPcyn
	b1ma+K5TI10aU62ay9iLY1nx4a8QZdalzxUZIB3JW7dzYQIDo+4q1sEvWa9rzAPA=
X-Received: by 2002:a0c:b24f:: with SMTP id k15mr3494449qve.72.1549990212220;
        Tue, 12 Feb 2019 08:50:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZriIPWeOOrBL7MaD+cVi19ACxC+vGEbGG94jr7beYFFf9xMJa+Gieyrj4mMWjQv7cqjy4N
X-Received: by 2002:a0c:b24f:: with SMTP id k15mr3494414qve.72.1549990211812;
        Tue, 12 Feb 2019 08:50:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549990211; cv=none;
        d=google.com; s=arc-20160816;
        b=VSOJJkadzbf8x98r8eOOpNujoIdq86rLd9EbidOG5cmxxD0jxJ+IHNJV+jKgkotsNV
         FsC4H0rQL6yiP6erWC99p3nwtZXCmhk+KcLbbGIY1ZTQ0ojckO7yRF45e3bDZahHmnsX
         1tx7tWczqZxrKc/t2J7CVkP/kc4dA4tJVfHEyMBm6GUhlbdFfIhM64/x0hqU8EC+aBT6
         n6S7X9Hj/C6S6ckzBTARbpaifRsGhZI35nM5lQuTV/Q0s/uwXChrayGsqQ73Ga+cY9f7
         WUKRMVBzKB3s5jez6rkKPxSMQUsVhe0LAyOFSwYwHWeEA9WdCSoPRTrhjQ4GDe3RuqFO
         xFEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=d9wM12jhuDTWdWt+Pkovf6I5uVUhrDCPMcwRg2iB6/c=;
        b=BNbgrY9JkeqNX2BEyFp9pRgdhPhJDcofaqtgpb55y4HDCjnSBiMy5xnpTMkjwlgxIt
         G0A/ysYTZ68JeWxrsaTQu/D6HwfIw45BcuwFNhqiIESrsawUtVk/jcRWg5WzTrheWHnI
         gO7bNDEmbbOangJetqrzAC5OrmCKqoRCyNyF1Vwlmulee8VfMhECcZaXyhyeN8ZMBAxr
         71lDdG44JlTjt28Q2I23ngBo1a7w24Bosa3L4KyJ9DiG/f2F0qgPoeCzmjY7vX2FTE5l
         8HS9qg17i9MhXChrezR2hZNq2Qyo9ThYXypaWnReiipG6xMQYO63OrhonpA8pkjKEW3/
         8TJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=dPwog4Db;
       spf=pass (google.com: domain of 01000168e29daf0a-cb3a9394-e3dd-4d88-ad3c-31df1f9ec052-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=01000168e29daf0a-cb3a9394-e3dd-4d88-ad3c-31df1f9ec052-000000@amazonses.com
Received: from a9-37.smtp-out.amazonses.com (a9-37.smtp-out.amazonses.com. [54.240.9.37])
        by mx.google.com with ESMTPS id a55si5320056qva.119.2019.02.12.08.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Feb 2019 08:50:11 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168e29daf0a-cb3a9394-e3dd-4d88-ad3c-31df1f9ec052-000000@amazonses.com designates 54.240.9.37 as permitted sender) client-ip=54.240.9.37;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=dPwog4Db;
       spf=pass (google.com: domain of 01000168e29daf0a-cb3a9394-e3dd-4d88-ad3c-31df1f9ec052-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=01000168e29daf0a-cb3a9394-e3dd-4d88-ad3c-31df1f9ec052-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549990211;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=d9wM12jhuDTWdWt+Pkovf6I5uVUhrDCPMcwRg2iB6/c=;
	b=dPwog4Db8cxWFTs8RaPbWPHsdjVXXzK6xqpC2es8j1a9vMwSTJTBbxIqClS4bTWi
	jn3E5648vwwyFuDLlzLP3ebtNmQ8QHcaanGSqOxZWOF9WwuscWPvVRcezYZjIzwFHH3
	zSJ0zA/tay7p90Jbs8Pdv9fCw9l9ZFY8VqBAPqsw=
Date: Tue, 12 Feb 2019 16:50:11 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Alexey Kardashevskiy <aik@ozlabs.ru>
cc: Daniel Jordan <daniel.m.jordan@oracle.com>, jgg@ziepe.ca, 
    akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz, 
    linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, 
    linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org, 
    linux-kernel@vger.kernel.org, alex.williamson@redhat.com, 
    paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au, 
    hao.wu@intel.com, atull@kernel.org, mdf@kernel.org
Subject: Re: [PATCH 2/5] vfio/spapr_tce: use pinned_vm instead of locked_vm
 to account pinned pages
In-Reply-To: <ee4d14db-05c3-6208-503c-16e287fa78eb@ozlabs.ru>
Message-ID: <01000168e29daf0a-cb3a9394-e3dd-4d88-ad3c-31df1f9ec052-000000@email.amazonses.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com> <20190211224437.25267-3-daniel.m.jordan@oracle.com> <ee4d14db-05c3-6208-503c-16e287fa78eb@ozlabs.ru>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.12-54.240.9.37
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019, Alexey Kardashevskiy wrote:

> Now it is 3 independent accesses (actually 4 but the last one is
> diagnostic) with no locking around them. Why do not we need a lock
> anymore precisely? Thanks,

Updating a regular counter is racy and requires a lock. It was converted
to be an atomic which can be incremented without a race.

