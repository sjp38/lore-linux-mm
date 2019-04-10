Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1ED6C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 15:49:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77C6420830
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 15:49:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="NfXujEP7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77C6420830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1218F6B02A0; Wed, 10 Apr 2019 11:49:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CF4C6B02A2; Wed, 10 Apr 2019 11:49:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F25F66B02A3; Wed, 10 Apr 2019 11:49:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D54FE6B02A0
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 11:49:58 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id t22so2625195qtc.13
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 08:49:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=0XwwQPRGaw7KgTDhnUmgjcd43E3sjloMv0Xkja5uBiE=;
        b=ZIAhG3wXNQD+ph2n7BJFSY8Zi55SUJsatSRvdf93gKS8raIBEKAVL1JRNpRcaLXaOx
         UYPWTOpAIlybaoPqIX34Vr5i0jxCErV8T3uttItqpGKJa5rAlWB6pGOz49LkRuyGHExY
         /3gxM/XKx8xKnSlhIMZ/qVtB8NshDbOIGjeXLKezGVr+YRUUIFphln5c40k3Y3tSrjAf
         M6x0NytNovdzx1J5WzCUXy5DLk+2yhnQhIXWsTy1TgsyRc7hZbDDD4oQwUiAmGa1oLNC
         DGjKCj9hIr90VxptkLyEDWvRNZ7jEDuntGnemCahTVyHw/0dSDjMklud8fsRwT7Bal1w
         5IOg==
X-Gm-Message-State: APjAAAX0LcS4UN9Qsp/CNTrktHeP+gD9+YttgzCwo1fJAP6R8ZaKK66e
	tik+/gU+zuLzbV/lhVJ04SxmaXYbUJTK3bXcQMLEqG7gM8Y2Ls9VNF7PJOtpq/BtGms45ihGPHG
	1ALU8c8nE11bCKP9/2zmFrp5V2OvSfrm+p2RxYHNXeDDfA0bJvwYPfrOCcDT+FEw=
X-Received: by 2002:a37:c20c:: with SMTP id i12mr32213163qkm.94.1554911398521;
        Wed, 10 Apr 2019 08:49:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpQo/uVj2Vvv/wHay/4GfxGPWOdSKPWIPFl3Ya7OYwYJp+8L1TblAzcs3Z7ML/AxMVhaU5
X-Received: by 2002:a37:c20c:: with SMTP id i12mr32213122qkm.94.1554911397943;
        Wed, 10 Apr 2019 08:49:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554911397; cv=none;
        d=google.com; s=arc-20160816;
        b=YwSoJcmWe2+fbS7ix/UvQa/A/ThJLlkfeqpFjJYy+JWlLof4L/Smb0ZMD9CP7EJS3H
         JtdUhW3ZX6PwLbOVLuTU5zM+IS9J1fOpmFX3b1+e4sTWIB4Jmf+3SvSczMe/LLFodjm6
         guShRdjZ9eeqEmJoaC/RcG2CM0MBWvbaHQoRdMjmGE7dSEj5otKbb5qRWJC5ClQtXA1w
         Md5EZgT9I4BUVA2jWPjIBIt0vxTaJLtf1AYRWU7VXMTVHznYdwXbycMz4zVwZUGKs2vx
         0qNxcgCJo/WutAX8m+fZbwPkrwwaSQlUkBm5KaNYiTwk0RGuNfpuS4UCS5HmeptCCL+N
         g3mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=0XwwQPRGaw7KgTDhnUmgjcd43E3sjloMv0Xkja5uBiE=;
        b=Bvx/nIF2PKPYRODhSt3b3RuuUNOzaCQBiezaqjdXO2oS2TWPu9EvPAPwUBxekCZ3Cp
         0VQuXHd469znuFEgL4RBbJgIbECF1HB/iDMMtxqTCpVhbHTipwqXW7QT/iBXESwPXSnw
         m5oJSrLKIIawg7oXEkLiPOo9nvYnruEIxDLzbvLobqm60Dc8Dee2me/jehyv2IhYYkJZ
         VWSDOniF+gjtStoVWQ0JaIhWMM81skC5oTirF1/2qyn97mK8mRCcQbePuU9uigKMcYW2
         WtX9L6u8kzTmBLy0jvRjBXSGgal8sJ250sjSzpoBOA+CYaIMmhJCgp2mPCuEcyGjAona
         02Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=NfXujEP7;
       spf=pass (google.com: domain of 0100016a07f105bf-7e1f2eda-fffe-4418-9b7e-9f6572e08633-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=0100016a07f105bf-7e1f2eda-fffe-4418-9b7e-9f6572e08633-000000@amazonses.com
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id q45si2298492qtq.348.2019.04.10.08.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 10 Apr 2019 08:49:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a07f105bf-7e1f2eda-fffe-4418-9b7e-9f6572e08633-000000@amazonses.com designates 54.240.9.99 as permitted sender) client-ip=54.240.9.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=NfXujEP7;
       spf=pass (google.com: domain of 0100016a07f105bf-7e1f2eda-fffe-4418-9b7e-9f6572e08633-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=0100016a07f105bf-7e1f2eda-fffe-4418-9b7e-9f6572e08633-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554911397;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=0XwwQPRGaw7KgTDhnUmgjcd43E3sjloMv0Xkja5uBiE=;
	b=NfXujEP7h7+awlKKkWFlPto3lUIHLNPSEeH2fpwtFZJcm19WAbmiVRddnWr/diGu
	yC1Gt9xkJAb1CccRjBG/XUMEfA3vxkczeUiODt/eDSJdm3J+TP7iNelFVdGYmF9IGei
	M1M7ccKjDXShc0ywiZsxsnfUx0pfoTPzdYkNiO8U=
Date: Wed, 10 Apr 2019 15:49:57 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
    "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [External] Re: Basics : Memory Configuration
In-Reply-To: <SG2PR02MB30989B644196598CEDDD5337E82E0@SG2PR02MB3098.apcprd02.prod.outlook.com>
Message-ID: <0100016a07f105bf-7e1f2eda-fffe-4418-9b7e-9f6572e08633-000000@email.amazonses.com>
References: <SG2PR02MB3098925678D8D40B683E10E2E82D0@SG2PR02MB3098.apcprd02.prod.outlook.com>,<0100016a02d5038e-2e436033-7726-4d2a-b29d-d3dbc4c66637-000000@email.amazonses.com> <SG2PR02MB30989B644196598CEDDD5337E82E0@SG2PR02MB3098.apcprd02.prod.outlook.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.10-54.240.9.99
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002054, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Please respond to my comments in the way that everyone else communicates
here. I cannot distinguish what you said from what I said before.

