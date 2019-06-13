Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 534D7C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:23:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F74521721
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:23:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F74521721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACE946B0266; Thu, 13 Jun 2019 08:23:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7EA26B026A; Thu, 13 Jun 2019 08:23:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96EE06B026B; Thu, 13 Jun 2019 08:23:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 60A5A6B0266
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:23:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so30613271edc.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:23:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=NR5wkzX5Oq8qls2imTq8KZ3PqwNaGuXV0gxxI18Itk8=;
        b=gQpjxfc8XqXlMGpxGg2uQymFviNnnvxM33fODoesGrEFEsIkX7pvy3hmYQDXyfhNuM
         8VZkNmO696K0b1mQph2a3qs/nXA7r3/lE/cg0rrfrDfbl26ZKRyv6bZdUA7LdaZjRXt3
         gwpE5rTWf8pUFOEB8cCTTYlkC6RUzKH/sWPT+iHUHlZKcfDQYgdScF46t4B1P/e3+hHJ
         evgLSUW66cnRG4mD+myZ8GQKIWKiBFEFI/QNE1Bbw4cARnnUISF8wRTbRSpwsYA/9n60
         +UPwkE3VPHrkdt6vJey776n6oXCt48+4hIw2q1JExcbkfISGTKWKsXuCrfe1PNf3Wu6k
         fegw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAX9QHPxmIGdxem4ExnscnWUQ+VPf9NxYA8KNfKSjBg8UXWcCOoL
	qY0lMcj6XpkVrexrqCKgsin18wky0wDbjZefbE3l2SA73twjqw9JL3t5uazt2MsW1MAHJ+tF+aI
	/CyQSo+ZNII96fGaY/YBPwIzFd3dw/oJFep4RID3pAj5obHf4Vx6aNrQtn1T5hbE9ew==
X-Received: by 2002:a50:8bfd:: with SMTP id n58mr60413087edn.272.1560428620870;
        Thu, 13 Jun 2019 05:23:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTnn5agQDTlpZaq3MTH09r8LRf6YEuaWsM8HF8KEnuxMySph7xHroqADEpP3m0sr4ACKYz
X-Received: by 2002:a50:8bfd:: with SMTP id n58mr60413029edn.272.1560428620203;
        Thu, 13 Jun 2019 05:23:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560428620; cv=none;
        d=google.com; s=arc-20160816;
        b=qXMOi2EsQgY0lo5st9bxk6vJYmXNtohyRlAQB26b1m7XFCWEP3YcEnzU28kZ09axSv
         ER7YHczBA7MueHo8BWZdxu8VfsNFt4QeqcpHK9b7fhdaSz1k5JneUB62PxfvT70+78zf
         IcFMBwYL7Q3YR2ZEmVQK7gsJDeQcyQr0zMHCFoTpF7HClq/L7RORI5zYRD6l41UMRW04
         V4xkjoPi/AaB454c45nssiiaLhfot2Dpn/tvlzQf2VXDyB7D/SFI8e1mpLQrML2G6AAZ
         HcWEZwkiN34lNIxbBzxExraMerjzW8J5TtPtLwxeZWA+BIKUWykl9/VGHjMzF4L4LLTG
         391w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=NR5wkzX5Oq8qls2imTq8KZ3PqwNaGuXV0gxxI18Itk8=;
        b=qbUrz/nwa4tklS+Pg/isX/3Dn2p7/6+Hwu54kiCCuyrB724EjNemuvtK71OAlaNT/5
         UgNubpygxni94Gs+RPVRmFKDah1iDj3ZjRQ6hMZmdVIIRILjZeRdxgqMwZdelOHZmbWE
         GbkJBycrnQiyUREjgJgeWen+9YHbPDSWAAzVlFxX8tiO2mK8+RJuzxX+4lnVeqWwHX2Y
         VZ8HMSLggop1Ilb+s4NQnIZwTKQTCKvTKK/YBKnE7JmOgAWSeYYG9GbGFAMkWbXNVZLx
         YsyLS5EtOq5KQExHnXKEc0A/f//HpSib+39M7rCyqP5vHdC5oDKz0SMX+z8pIVeSVBdn
         M4zA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k2si2056482eds.64.2019.06.13.05.23.39
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 05:23:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6585C2B;
	Thu, 13 Jun 2019 05:23:39 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3A71D3F694;
	Thu, 13 Jun 2019 05:23:37 -0700 (PDT)
Date: Thu, 13 Jun 2019 13:23:34 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: =?iso-8859-1?Q?Andr=E9?= Almeida <andrealmeid@collabora.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel@collabora.com,
	akpm@linux-foundation.org
Subject: Re: [PATCH v2 2/2] docs: kmemleak: add more documentation details
Message-ID: <20190613122333.GR28951@C02TF0J2HF1T.local>
References: <20190612155231.19448-1-andrealmeid@collabora.com>
 <20190612155231.19448-2-andrealmeid@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190612155231.19448-2-andrealmeid@collabora.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 12:52:31PM -0300, André Almeida wrote:
> Wikipedia now has a main article to "tracing garbage collector" topic.
> Change the URL and use the reStructuredText syntax for hyperlinks and add
> more details about the use of the tool. Add a section about how to use
> the kmemleak-test module to test the memory leak scanning.
> 
> Signed-off-by: André Almeida <andrealmeid@collabora.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

