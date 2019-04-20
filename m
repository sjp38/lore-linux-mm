Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6CAEC282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 21:02:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36C73208C0
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 21:02:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Oc6rl2uF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36C73208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5D796B0003; Sat, 20 Apr 2019 17:02:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0C676B0006; Sat, 20 Apr 2019 17:02:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 923D96B0007; Sat, 20 Apr 2019 17:02:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 66B7B6B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 17:02:17 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id s22so4774774otk.16
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 14:02:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vKqLga59d4C5WqOdUK7t52EEoHtdJECj+oe5cCG0PQ8=;
        b=n2wqF/xhTJcC2oHw59f0fiPwzCPSUddDMAXl2wDaB+ROlbxS47WBkk/AzaMimLUjAw
         FqsOYiCNVuWRTvNmIwSjvqdfxw3Vr659u4PSTmeiFRykISh32wi9jC5QZYXHrk19qVKw
         xaSIsBIpDK3zE5fhb0/rpZ7sYIdr9WhWX7WTa6emV8XCavyaUdNUfgR5HhyYn+65Ioxb
         sEepO48H6r/eh/2LNb3utiolxGV2GqxlVRpFoxQ3/xySGpt1gWuZvVdWhayZcXj+8AXT
         fBPuHoKLdEP9IDhO9+G4smNbi3Galp0tjgAbMkrtVZaUI+xughoMIjJHz6WZGQyNm1hz
         SiOw==
X-Gm-Message-State: APjAAAWGejxkaLTNUhbPb7I1JeiGcC8oY/fmefnP3OaaMwmj6U6nQr9g
	d5OP+9udS5f9y5v5hoTBiMDY6BRqKP0vRydV8N/4xxYJNUUqzFjkEem76iAc8PVRj/q9yedIG0O
	qbS5wgN5I36dAOZrYrGWR6UoDTuhIBIcSTnGRBCHmkI6CSEWPF1r95TNs2BGcfDZeUw==
X-Received: by 2002:a9d:624a:: with SMTP id i10mr6371496otk.292.1555794136953;
        Sat, 20 Apr 2019 14:02:16 -0700 (PDT)
X-Received: by 2002:a9d:624a:: with SMTP id i10mr6371474otk.292.1555794136310;
        Sat, 20 Apr 2019 14:02:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555794136; cv=none;
        d=google.com; s=arc-20160816;
        b=NmIiR0V8/16IdTVHK0YYKZreVtkdZnYR59HGUQi0vpHe22hY/El7gDr7XV6x3ZodX5
         HsV8/uUMkLLAVMoJCPvh6r/b6dxJ+uFuBImstFZQ6LZg81AWakkaSVMuTxq6GAjvt3rl
         PzNFdSxnQBJnpluxIpBYcNeDi0bbo07Cl0WpEGFm8n1NCr9TUkECjM/pJw/8U1yRWe45
         c+p6I32m9hKX1MxDV2bAq5xAo2MpAyNTFiC16lYoxgodwbsRG88NBqDvVmpsj1wUY4j7
         elRz/s7p9IXJTvnxevWoaSTWQrioBEMjYC8aNq7WlnYq7Y3kJs7YVTD0lsbIUkAeJrO4
         ChhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vKqLga59d4C5WqOdUK7t52EEoHtdJECj+oe5cCG0PQ8=;
        b=LQHDZUUbbWsllgAOIBPlAHyk7IBJjxecqIDBo4zKicKMhCXXjv/QUlvznUnbsKzyn3
         2sHKLgkiPd4QwUAWONjfJn7fsPshX/MuAE7QSqW4CnqQWUEPNyaqacAJe9xt+RE/f+hi
         iI4VkneOHsr60Hp2ufbBHBLERdpWlYB4ABqaOkQJDWTxJe0aT+/dKG8yRmhlCu9wV6m8
         jRMgOhsAb2Nw1XFkIUC2+gqVSFJvBYHM8jXy51xwBe8S/T5CRcQ69YGzHrZryKCCmOyJ
         CaDiW4IyhL81wCcGPNgdnHsEFp4fAJg5oE+GcqLnUaavyt1nvqsd9JjpylNVkIC0RXd/
         zAHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Oc6rl2uF;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n1sor3944170otn.51.2019.04.20.14.02.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 14:02:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Oc6rl2uF;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vKqLga59d4C5WqOdUK7t52EEoHtdJECj+oe5cCG0PQ8=;
        b=Oc6rl2uFMlm9BBCHIv8btu4Y26T3t+YFcb4O6IdwoABM+3bo2TLj43f1U3RfSjZtM2
         RAHEUZPp0UoeOhHx+WIToPW9MM2OPanmlt/bVMDwck+kih+3ADBw+x6ms38gl8hSv7ml
         Vzwl62Io7+VDVOaV4SQhfpQdfdT0ZcaT2KJTn4GHlvxhpfEQPkLTNniPLs5hYEEVyi4B
         KYeYo5ELVNawQw3sDYE1K5TDyW77y144xSTV3eCkXJnaemo+7+6uawiSTFixJVhfH3Q+
         w0teD2VVLBw2Ci9Tmtwbmwrw/DG+vaU/qqsKWXSxW/V6keZ3vyOI/2T60r0qojlYBokd
         rmuw==
X-Google-Smtp-Source: APXvYqx5EXLH90eAk9pNJDt0nfkqlWI3JEav607Ybl6aSejlE/nKG5/6NUbeBq0DGylbF9d345OSd5Rpb1gqeaXAWpc=
X-Received: by 2002:a9d:27e3:: with SMTP id c90mr6869693otb.214.1555794135898;
 Sat, 20 Apr 2019 14:02:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190420153148.21548-1-pasha.tatashin@soleen.com>
 <20190420153148.21548-3-pasha.tatashin@soleen.com> <CAPcyv4j9sG6Wy3EfTuPb0uZ2qp=gr9UgUhpnXQA_g6Ko9KFmLA@mail.gmail.com>
 <CA+CK2bA2QTzZtFvGRMaG10_TretDr6CGgZc4Hyi_1pku4ECqXw@mail.gmail.com>
 <CAPcyv4jrxMNEEeUZZG3=CdkYSyX7OtJLv_ZQ1gbML7bscePiQA@mail.gmail.com> <CA+CK2bA-wDwRT5Gv2p9Nm1Vr8LNg84rQdE6=s2m2hQLYqj5Rog@mail.gmail.com>
In-Reply-To: <CA+CK2bA-wDwRT5Gv2p9Nm1Vr8LNg84rQdE6=s2m2hQLYqj5Rog@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 20 Apr 2019 14:02:04 -0700
Message-ID: <CAPcyv4gBu5QhgRQ+maJs108JwBrcCa9U1e9wgO8FP6Q3qwy69g@mail.gmail.com>
Subject: Re: [v1 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Pavel Tatashin <pasha.tatashin@soleen.com>
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

On Sat, Apr 20, 2019 at 10:02 AM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
>
> > > Thank you for looking at this.  Are you saying, that if drv.remove()
> > > returns a failure it is simply ignored, and unbind proceeds?
> >
> > Yeah, that's the problem. I've looked at making unbind able to fail,
> > but that can lead to general bad behavior in device-drivers. I.e. why
> > spend time unwinding allocated resources when the driver can simply
> > fail unbind? About the best a driver can do is make unbind wait on
> > some event, but any return results in device-unbind.
>
> Hm, just tested, and it is indeed so.
>
> I see the following options:
>
> 1. Move hot remove code to some other interface, that can fail. Not
> sure what that would be, but outside of unbind/remove_id. Any
> suggestion?
> 2. Option two is don't attept to offline memory in unbind. Do
> hot-remove memory in unbind if every section is already offlined.
> Basically, do a walk through memblocks, and if every section is
> offlined, also do the cleanup.

I think something like option-2 could work just as long as the user is
ok with failure and prepared to handle it. It's already the case that
the request_region() in kmem permanently prevents the memory range
from being reused by any other driver. So if the hot-unplug fails it
could skip the corresponding release_region() and effectively it's the
same as what we have now in terms of reuse protection. In your flow if
the memory remove failed then the conversion attempt from devdax to
raw mode would also fail and presumably you could fall back to doing a
full reboot / rebuild of the application state?

