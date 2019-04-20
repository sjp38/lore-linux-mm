Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C9E7C282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 17:02:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 380FC20883
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 17:02:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="B+PiqK/j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 380FC20883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBE5C6B0003; Sat, 20 Apr 2019 13:02:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C46B96B0006; Sat, 20 Apr 2019 13:02:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B379B6B0007; Sat, 20 Apr 2019 13:02:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE7B6B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 13:02:04 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m57so605444edc.7
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 10:02:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AXyjmtFFgMWlKGIYoB9dsKU2FQzwdG7rLU5CnRpLzf8=;
        b=SJEARDgj7NXr3NY7O3WVu3pkQk/Wlc3Cczy4AgtcUdBPA6iQaibUVM5yH/Q8brOv7w
         4YNV/JzCi6ME8FDs/dOLDjM2X6cJzBoVH4b853I3igtO5pcmXOsKLWiPLJWxe0BdnbUh
         F5D3OY9jukTp43VVZjmNtcpqejp//oOcltDFhajDG+B3p/IQwpQ56Q0+QjX6jYpCYX6T
         +2qtJcJmbZyGWwx3b23bbJLmWK7j+wdPRlFLOvlITnqjlx6tOQ384GTUDdTeeLd9A7xS
         YOpwYcW49mxr99sTJHRz5jSoOq+T9wiTlZ6XsFZBegx66cMq9m3AwK/zLY0WSHf1G9Gi
         /TIA==
X-Gm-Message-State: APjAAAVWdLQJ9PM+USAPaMXgwYZvVNubog4sjojMHU1l9OAlEyDdkPss
	yOY9sUMK2Vx8a9gwhNn7kaDt1D49sGFuCz6zvvwG/GsnjHY0C5NGAlR1JXGqdr7RJpdYhBrxj6N
	kBV0CcJvxN0soY0rr7yfAjZIA0Dj2PmH/rQrJxdum0ao8W+23yF4o7TQc4/tcBnk1ng==
X-Received: by 2002:a50:a90d:: with SMTP id l13mr6616333edc.45.1555779723765;
        Sat, 20 Apr 2019 10:02:03 -0700 (PDT)
X-Received: by 2002:a50:a90d:: with SMTP id l13mr6616300edc.45.1555779723059;
        Sat, 20 Apr 2019 10:02:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555779723; cv=none;
        d=google.com; s=arc-20160816;
        b=dv8yNXYiET0KaDUcgGJtC2I6YDnywrDUF02rNyUS/lbJZRBfgQ2Mjfvzk+gO9e7A25
         pdt1mBFTnqrE/li3MvtXkGRWKafJ9hqdQmjxso9+CmYTVej3I9uChkss7S/tFSo6ZKQ4
         6CMEXQYwKM7XRL6iROBHC13v6mXz1qfrhMB5nA7+3JOPML2Rn2YI+MxPOJrBqjzHYIMQ
         qDS/2Kjpoxcc8Uc/L4AGA826nFKwAfToUXGEfxYKR/M3YJuV4nMscpKWUdLfVBEb1cqd
         S4P7PZgS4yh5jd6T/cvYk4ms1/iSEWC3oNYNVlZzUY0HP45Ehf/5CsqARC4NmqKn+inM
         /Gkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AXyjmtFFgMWlKGIYoB9dsKU2FQzwdG7rLU5CnRpLzf8=;
        b=ByHESpka8TnMed3+Tt9IZg+/umuCaj89pI0+uqCx6zAyOcofvg3Gdj572x6fggOaLO
         vTff9FP/5PNd6vH5PSL8Y+1q8ec6jbqXy6eJ9CooVgXWOL2ODif795UXfAfsoZmKxSP+
         KD0nS798G2xOZAJyy+Ldru+7ymN9HmrIms3lK7C8tqn281rDUqWjl07SDXvXHHIYThnv
         DW81s3fWm0PaH4UcwkhgGMNenN4MP6iLrNqRnZ+luFg3UExJ6H76tzkuQSHvk9Au2x8T
         jvM985biWgrUOOV0HdluQzXctJVJ3LgVX1BrojeJO3uYmQvhNdYrKmYkDCw+ELsDptdp
         uRgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="B+PiqK/j";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j5sor376305ejr.11.2019.04.20.10.02.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 10:02:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="B+PiqK/j";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AXyjmtFFgMWlKGIYoB9dsKU2FQzwdG7rLU5CnRpLzf8=;
        b=B+PiqK/jGA6BSXz4p+5CvV5EJ3gW70B3SIP91bnAfau3Z51YpTAD0mq0/Ml+TJsAo3
         fTBGPm3Uhi6w4qrG48q6HDmiOD9jz1Ih7OOPqQbLaH1nDRoffHPvm9XUPqlNGk7Xpp5b
         PeBDhlrSkWhA7Vv7+eMdCc8tjV0Uj6lotfKsEnWHL6cyXjLpAxuHWN/0plV2RO+WCKtk
         mPQkLmNunc2uwzGPpHzswjKCdqns/uHAHQPps57Z+eHeR4Hw5F4fhorrTlYapLdMuEUb
         eTKDinvPuCb3rOZr91RxUKbrocTtivf/rZJGffYkLG5qk7MnLNqyDOwkUe68G4knPlSW
         Toag==
X-Google-Smtp-Source: APXvYqyNourCxDLn0Hoaodp+huVi4LFkIi0+KxD0d7RjeWIUebCBAWlQB16lKvuQTrD2rBAamnZCaw7+I7Zl5DAEd4U=
X-Received: by 2002:a17:906:b291:: with SMTP id q17mr5118998ejz.56.1555779722718;
 Sat, 20 Apr 2019 10:02:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190420153148.21548-1-pasha.tatashin@soleen.com>
 <20190420153148.21548-3-pasha.tatashin@soleen.com> <CAPcyv4j9sG6Wy3EfTuPb0uZ2qp=gr9UgUhpnXQA_g6Ko9KFmLA@mail.gmail.com>
 <CA+CK2bA2QTzZtFvGRMaG10_TretDr6CGgZc4Hyi_1pku4ECqXw@mail.gmail.com> <CAPcyv4jrxMNEEeUZZG3=CdkYSyX7OtJLv_ZQ1gbML7bscePiQA@mail.gmail.com>
In-Reply-To: <CAPcyv4jrxMNEEeUZZG3=CdkYSyX7OtJLv_ZQ1gbML7bscePiQA@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Sat, 20 Apr 2019 13:01:51 -0400
Message-ID: <CA+CK2bA-wDwRT5Gv2p9Nm1Vr8LNg84rQdE6=s2m2hQLYqj5Rog@mail.gmail.com>
Subject: Re: [v1 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Dan Williams <dan.j.williams@intel.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > Thank you for looking at this.  Are you saying, that if drv.remove()
> > returns a failure it is simply ignored, and unbind proceeds?
>
> Yeah, that's the problem. I've looked at making unbind able to fail,
> but that can lead to general bad behavior in device-drivers. I.e. why
> spend time unwinding allocated resources when the driver can simply
> fail unbind? About the best a driver can do is make unbind wait on
> some event, but any return results in device-unbind.

Hm, just tested, and it is indeed so.

I see the following options:

1. Move hot remove code to some other interface, that can fail. Not
sure what that would be, but outside of unbind/remove_id. Any
suggestion?
2. Option two is don't attept to offline memory in unbind. Do
hot-remove memory in unbind if every section is already offlined.
Basically, do a walk through memblocks, and if every section is
offlined, also do the cleanup.

Pasha

