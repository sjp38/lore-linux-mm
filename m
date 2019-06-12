Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D97BFC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:56:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACAE620866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:56:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACAE620866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 371F56B000E; Wed, 12 Jun 2019 10:56:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 322056B0266; Wed, 12 Jun 2019 10:56:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 210F86B0269; Wed, 12 Jun 2019 10:56:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C86DB6B000E
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:56:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21so16619683edp.11
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:56:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iF2iHP0sh3i9aMJ0ZWP1skoopTO1AW+kS7L+Aj2wDV8=;
        b=TBIuRo6ws9t8Ua7l/ujHVlQT5UIj7pk/Ss3gtIJqvWBisaZC1RpPkK/I2KVnFwqwBr
         0KkVxpWX5hNaTujzSCLEjxUTxgNqyO6bNQVi6fwJllJCbarAtV7gYnu9aoCREPM/1xpg
         1AngYu7H5jw6YilElan2mVSvMwGxYJuyo7YyxttQtFGc1aAlYCzAB+pIuN3YDMS7OoM/
         in/CPoZATQcIzCCC36NDHJ+wUretByM4IEz1ok+otoQ4Ki4ZE0aLi0W5UpHQVjvNaENL
         +IDKFLlL9DHW6Jujp3EUZWmnTdDff557TqHvFxxE5ObttaSMh3sPMT95UYZx5sv9VqiA
         Zr7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVGZ80Y/rygdAYm51n25///nUN2XN/MjeIL5T9n8dI8H++Dn/RR
	AIwpeN07+FvZcgyUNt5Xv5TnHD/lyf3VVhWhuz/3od8NwDacmc/ODDfjeJkyE6BbZ44ysoJEWNl
	6/qQP5W+h4jH5D/iWzwES0M9jq2jka+hYgxwURpzIuEcsMEHrfinhh+ts6rngsEx4Vg==
X-Received: by 2002:a50:91e5:: with SMTP id h34mr40769833eda.72.1560351363388;
        Wed, 12 Jun 2019 07:56:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwP6TN2bgK5ls4Fj/KczIRkvFKZ7kSQAylWSDEtK59pSad2104EgE/bmjXuHriua/tlN8kw
X-Received: by 2002:a50:91e5:: with SMTP id h34mr40769763eda.72.1560351362680;
        Wed, 12 Jun 2019 07:56:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560351362; cv=none;
        d=google.com; s=arc-20160816;
        b=zDPVKHMPa8QRPSrIRe+90ITZCEKSuPKCrrW2nCd++Z4WDrycaYceNV1aPXNJkwoGrE
         tAexHXkUsC7ZJJtoinGUQAwXeByMAT3VKlP2IMt8VMviRsotrAdj+H75TX7fh+XzmX4s
         zmS/6ZeufVIXYlHA1Uv25MTgWTxF4DUmIg5PtEih0pnZ2W44xu6YsDKQWOuZCUsFCGiK
         p0MTZbNcRJqyiv+cF/gWiEyNNFTpE7jBkB5HRMxsekleRVxtW0DiMPMtKYvzLuz/o889
         gnrhselx78idVRRrgkuOQYT5TxScl9vkNCEayMZrJBUazDh2AWrrIzJ8XKXMxqUE1D5g
         8KYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iF2iHP0sh3i9aMJ0ZWP1skoopTO1AW+kS7L+Aj2wDV8=;
        b=AbxC8lHdYEzPVV9UHoMMZ0uTyx2qxY2YbnYvUER7AhZl0sJW5hBHz61cTAgy2sd5Np
         50zlsFJjLSLIZu/AlyZXukpBn1fy7oGBOJQwpFF69V1jiO1CaCjIQ2SHKyFkWz4M4f3s
         UDNnNB6LiO8OLTx11j7Qu0cDJMWf1yVuvz7loNqLiRa4vRI//D4bv3kxMjPr+1JE6oLx
         06Fgx9o9o8Y13xpqUywgTu6M8Qg1QDh9Ek/cg4zkwtKoluJugehdlVrAwKo3r5BuhLVL
         MG2J/6VKyvsefJmZcElZ2Sew2Gm5gSCWc89ALtUuJU6VXUAPTVqoJYWDkMut95NNKKum
         IwfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id n23si106883ejb.184.2019.06.12.07.56.02
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:56:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AE3052B;
	Wed, 12 Jun 2019 07:56:01 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5860F3F557;
	Wed, 12 Jun 2019 07:55:42 -0700 (PDT)
Date: Wed, 12 Jun 2019 15:55:38 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <20190612145537.GG28951@C02TF0J2HF1T.local>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> From: Catalin Marinas <catalin.marinas@arm.com>
> 
> It is not desirable to relax the ABI to allow tagged user addresses into
> the kernel indiscriminately. This patch introduces a prctl() interface
> for enabling or disabling the tagged ABI with a global sysctl control
> for preventing applications from enabling the relaxed ABI (meant for
> testing user-space prctl() return error checking without reconfiguring
> the kernel). The ABI properties are inherited by threads of the same
> application and fork()'ed children but cleared on execve().
> 
> The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> MTE-specific settings like imprecise vs precise exceptions.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

You need your signed-off-by here since you are contributing it. And
thanks for adding the comment to the TIF definition.

-- 
Catalin

