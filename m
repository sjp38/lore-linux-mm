Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7206FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:16:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DE2B217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:16:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="XFaZe+eB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DE2B217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C78188E0004; Tue, 26 Feb 2019 10:16:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C278F8E0001; Tue, 26 Feb 2019 10:16:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B65BF8E0004; Tue, 26 Feb 2019 10:16:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEF88E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:16:45 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k1so12578156qta.2
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:16:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=X2seorhdvcHK99S5+CZ0PfSjlsaYtBE8rlm40X4z7cc=;
        b=OlQxx+RKdrDVtguWFb8N+qKCfDengGdR1pc1VEiUSmqcwo+zsjy5GTQYN0w8GcaVl+
         OXMsgp99B1jme+Zfpfr3ekYh4t2gOfqyXQcmodnI05fksoUTw9sWuMaTIa3I1HLhxJ6B
         YwShaVUsCb1/Zl8ElMrXsOcj7iYkr7xcBy+R+RpypNptXTR1E1PUPqTeTqGufLiSRU8o
         GXzo9ixD8YGTWfVLeAEypGyxrdBGbrpM1F1GFRZ4eoCKNNgdnEVSVWAgPCgtRS6T1Op6
         WgfhYHezSsAWmvAg6yLgWtp5/CcBiy6pXIZPWy9srgGFZJklvyEzCWs5wgxdTP6VpH13
         SFjA==
X-Gm-Message-State: AHQUAuZRnmwFmPFSPK4ip+wCF0dgFRD+GVbNwnAsBvXZMUABuVMIjkSA
	VUkVJ//wwnqW8kYn7sn5HTDtEPR1s48pN+EVSrY2KHQFAzYJnbbwi4pvXMC2vRaGuUFGwFLJggm
	20OLokmgxuddtwOcfSgcjs3TLvQrM/AADo7O6udNUrWk0g5nZVAUDHXc0NxtctT0=
X-Received: by 2002:a0c:bb98:: with SMTP id i24mr18735853qvg.129.1551194205384;
        Tue, 26 Feb 2019 07:16:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaJoZnVxt6P1lw1fur7CANnN1i2+XHXRHPK50sbEvtSgH5mOpoYSD1lwYZVQFoFzldZMsWs
X-Received: by 2002:a0c:bb98:: with SMTP id i24mr18735805qvg.129.1551194204755;
        Tue, 26 Feb 2019 07:16:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551194204; cv=none;
        d=google.com; s=arc-20160816;
        b=XTYkAh8AQ3Ntpip0K/yIMd6Fn25NsngknZxIK/D+Q1BpREyvifE5rTsKgOmRoYK5R7
         VLb+HY13qLN9dOHXSwQ3+z5tfqktBjDmVsHUS+LqYxDUqXRWmAL6Qm9/G2g7zZgYwF1K
         bbKCom6UJ+Ei97Ylu7M1WVvh2PkrZSUIZmlaEqUWhBISzdd9a0rkJKVPyJR0kjJnlKQW
         8VSzUVhmqrFlrutl4nw4EkZU40rt37Q46ci8flxDMDb+pkMWCfTAWqR8HzrNOXVkhJzX
         b61qiqX4T3EHqiUUSiysTZEyFfUbJdWuM5xMxsuGSqaDo4FSsL8LwHm5AGR2Xu0/Y3XE
         UUXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=X2seorhdvcHK99S5+CZ0PfSjlsaYtBE8rlm40X4z7cc=;
        b=Uapn59l8J7mRppO2eb+t5gajmqffZ2VoRuiX8bCzoZfjkoNkn7GkxkokNn/6oGNvBI
         IA3kHGyYFJE33RvbB4WIn694ii9qFN7CSB3WrGELqU6sIs/BAT+MzNsvJPAeTMDH2z63
         Pa7uvvSuB/2eCZfA5s0tqQa1GqS1h4Mk+Ybs7nI7sJ6+CgG5YC7i9Hl2mq1X2ZLdvZF6
         624lvvmC+GDRXpHIyRqMK4QfeiGelWsJ/Jk0Lx5ZV6OReSMsTC3JDaKuye2e0R4peMs4
         N0NKsJrCT0bYIbxV+a/A19C3BzP/RvPCinGsU7Ak5w6fJltjftOOryK5SHlgjTJmDTci
         k6pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=XFaZe+eB;
       spf=pass (google.com: domain of 010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@amazonses.com
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id s7si1058198qtk.82.2019.02.26.07.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Feb 2019 07:16:44 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@amazonses.com designates 54.240.9.54 as permitted sender) client-ip=54.240.9.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=XFaZe+eB;
       spf=pass (google.com: domain of 010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1551194204;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=zk6autZDYWCridaZ1j6pE4L9X3qVCRB7mf1shVksySU=;
	b=XFaZe+eBN7TnCrRANRHetCBj0w20GfUpVaApTi/OaerR928UaWZN3r9O3ctFhYPq
	NV+cNIy/ZieVZEQLCWoBHg6XvuwWSK586i8D/J7UM8R34qAPbH6xsbSg8FfpzwqNL7U
	E1HPo6AoBciq9dlUFK92xUBa8H8E/E9qwTAio4Jo=
Date: Tue, 26 Feb 2019 15:16:44 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Dennis Zhou <dennis@kernel.org>
cc: Peng Fan <peng.fan@nxp.com>, "tj@kernel.org" <tj@kernel.org>, 
    "linux-mm@kvack.org" <linux-mm@kvack.org>, 
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
    "van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH 1/2] percpu: km: remove SMP check
In-Reply-To: <20190225151330.GA49611@dennisz-mbp.dhcp.thefacebook.com>
Message-ID: <010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@email.amazonses.com>
References: <20190224132518.20586-1-peng.fan@nxp.com> <20190225151330.GA49611@dennisz-mbp.dhcp.thefacebook.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.26-54.240.9.54
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2019, Dennis Zhou wrote:

> > @@ -27,7 +27,7 @@
> >   *   chunk size is not aligned.  percpu-km code will whine about it.
> >   */
> >
> > -#if defined(CONFIG_SMP) && defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
> > +#if defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
> >  #error "contiguous percpu allocation is incompatible with paged first chunk"
> >  #endif
> >
> > --
> > 2.16.4
> >
>
> Hi,
>
> I think keeping CONFIG_SMP makes this easier to remember dependencies
> rather than having to dig into the config. So this is a NACK from me.

But it simplifies the code and makes it easier to read.


