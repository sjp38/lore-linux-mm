Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 575FEC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:17:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D3E62081C
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:17:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="jeL1TmN+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D3E62081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAA496B0006; Thu,  2 May 2019 10:17:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A80E26B0007; Thu,  2 May 2019 10:17:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 996F06B0008; Thu,  2 May 2019 10:17:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C41B6B0006
	for <linux-mm@kvack.org>; Thu,  2 May 2019 10:17:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s21so1132393edd.10
        for <linux-mm@kvack.org>; Thu, 02 May 2019 07:17:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3UwUTSGK3kFDqh59G348P1VSE287YQFCPyBJWkFGT2g=;
        b=I1PEyLduqef86zF5c1DkWCXZtjz8vJja+FjmTdu8ZhrkEJKPedZ06/0WtB8/RbhKKN
         SHbYZc2nnrTX7fh76XaG7BvnxXvM9II73mqLH4FIt9jnAP4WEhrrfH6THg8Rtulp3r/D
         PMjUdOIwJGwyc5JC8CoVJOemI0UsXdV9JEPXdh5QUtX0oMF6eaQBa+XHTrJd9y8Qw/II
         9McbE5+Vod7sMQjat5ihT+N9b+MXd31VXuwh/lNAY4kolcwsYsABOhos1N244iSJ3cxP
         QTaPYx/yB/HL/Rikf08ITIboO6cV8EVLGij4j9p5NGv/u1o0qmknIwF4RORO+VtshiI7
         2pDw==
X-Gm-Message-State: APjAAAXejxN4oZupk/26dFv+GQjHBKyTCCIwSAfP8L17gq7vs4P8Tmnq
	ziPy4JWq5V7w3g1JSk8P39KAaHoMdwndvQsT8KOdnmAXfyjjtGvYPpeiTm8SadL1788xvbocXGz
	adl9OtP+bPR4lxDloa8qhJq/CR+HWtxS/qlOQEDpvgRnNDYalierO8Pp3JCiyFQhfFw==
X-Received: by 2002:a05:6402:1696:: with SMTP id a22mr2818985edv.219.1556806627882;
        Thu, 02 May 2019 07:17:07 -0700 (PDT)
X-Received: by 2002:a05:6402:1696:: with SMTP id a22mr2818945edv.219.1556806627182;
        Thu, 02 May 2019 07:17:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556806627; cv=none;
        d=google.com; s=arc-20160816;
        b=RhLEjPPwoTGreGOyox8NFEZyPQ67sto1EKY85FRS8Gi0swvib0ZEfiKKIjYFTaF2CA
         3rn9uhNZSrYShyh7MM+0LrUyFAHuu/oF1YwEnWkIlvQiXyBOev3tz23QauRKkxXchvjQ
         VND0CHgiEr66Ebq+fpbaV/TTvH2d6qZTEGzCI8bu319dPICKveLHKZz3ywy7Jed9uHiX
         jQpDad6Dv59huA6tKSSyRFuQ/RQ3pGrdHzop1Nmp/YUwbSQWTodq2shpKsyYONVVf1YG
         h6yvA7YN93CO7opB7qqxb5opsJhM2pkZDV9/YnHaxXkf758a0cPbxSeSoPkTpYMQr3ip
         Kr+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3UwUTSGK3kFDqh59G348P1VSE287YQFCPyBJWkFGT2g=;
        b=PTdgmqEVip775VOkcDcwZ0daHKBY6ARWrLxSAlfGbDcghoZj/WxHQIn62kdfKMmXLK
         ug9LOTslEtlWn2/nxDv+4cmnpIvDDT35vqBvwemJAa+bRyEMiYdzoE3WYlkyMtJs+dLz
         gEqh7yU7e4kjXJsRDqD/J9s7c0Pharm+UQ5FuhnJNKe6r05sE8DwnMPccDVEmd0AvPaK
         6ZgftSgWTs7HgD0N/F8keqMRTLGckzrxYmyPgB28qRiGWr4OuQNZTY1WeG8rdzDqaxy2
         eskn2ruKmZl7LVt0BOvLDQM6hQv/SzWAyh34sg9KjinW5cCz0y/H8Wr7iZeEglq0v45O
         EgyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=jeL1TmN+;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e12sor15531113edi.6.2019.05.02.07.17.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 07:17:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=jeL1TmN+;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3UwUTSGK3kFDqh59G348P1VSE287YQFCPyBJWkFGT2g=;
        b=jeL1TmN+9S7rxFSCfW9V3bYCQ9XkkRpCSHGcvfnrOsvTSAjY73LFSt1bUiVgtgHJNq
         Tv0DbnVWNwa8ZjVzru05IQyRWy3S/5OEqtHtNfr/GR2TVOwOJqI+yAZuJXWBMCL2pG4f
         re8W5PiiN/831GI+qo4H8mGQodK+253IOfYP2SJv+auBn37OqlvdOokiv0/y9Xk/xMCg
         T+14TN7gujRPTIqhsFgKKnmV+jKUYGVd5KWX38nwgSzlaAx0CpwFF17YHopwjY1k7gtD
         MLtUmtFpfiEFPRQtO43++BKD+FVRV2u7zlgVjWl+zwgCdyeyyFCx6zLeHvXkzQcj824S
         TQtQ==
X-Google-Smtp-Source: APXvYqxfxStCJ1a5V9dI9KazHvlQKGkMxuucoOz7ty4S41uLly2rKv78x1mRLAhuezLjjjPUXOHuGcrzAp0ZhX1u2YU=
X-Received: by 2002:a05:6402:13cf:: with SMTP id a15mr2763367edx.70.1556806626879;
 Thu, 02 May 2019 07:17:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190501191846.12634-1-pasha.tatashin@soleen.com>
 <20190501191846.12634-3-pasha.tatashin@soleen.com> <9e15bf41-8e74-3a76-c7b9-9712b2d5290b@redhat.com>
In-Reply-To: <9e15bf41-8e74-3a76-c7b9-9712b2d5290b@redhat.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 10:16:56 -0400
Message-ID: <CA+CK2bCfCoU3JHz=81+=RNwo9M6n_zRbmPgx+DNmAnPYQRcjOA@mail.gmail.com>
Subject: Re: [v4 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: David Hildenbrand <david@redhat.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>
> Memory unplug bits
>
> Reviewed-by: David Hildenbrand <david@redhat.com>
>

Thank you David.

Pasha

