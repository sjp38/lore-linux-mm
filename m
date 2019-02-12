Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F908C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:54:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C792B222BB
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:54:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="YXi/S/5k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C792B222BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1D3C8E0002; Tue, 12 Feb 2019 12:54:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECD6A8E0001; Tue, 12 Feb 2019 12:54:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D96768E0002; Tue, 12 Feb 2019 12:54:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id B07368E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:54:55 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id t192so1404301vkt.9
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:54:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bsXKwkLM/R+hXtwloqz5pZs2yFDYV/aAOBs3Mg0VcqE=;
        b=Yf7oJKiqlXhYBCNmZ/1Jl1fjqeySZdtE+n1NsoriJYuBhwWao2j3eIuY2YLeGxwS6d
         QqMSSCMXTcEL+Yi9WnYnp2XcxZc4BCvxBdyu77Vc/frSlBT5S3HFXr7r/17hCzG5/i11
         UKf5AyJnhi2A+y/HcTM+YIT9HPZsW3gDgzZgi0HI3iyWxmptEg3xInMRzZ0/93M3FZNc
         Ttx+DVVQTe/cDvr4733YNXvdf6DqSx84h9bftIUeTK9w7BQ6JyFKLZ183C64nVzvV25v
         cF/JKuRkPC+s/fUgPUI5YsByvZeU7BmGzcBpB8dQXQbEXkjG6I3LX2cYR9kvWagL/ZdW
         8NsA==
X-Gm-Message-State: AHQUAuZgDOup2UNjTVemDnHU48WzAjyHjVCdNkOnXOpSBCPt9m6BY3o7
	6Q7ci0v4shUBQknMhZLmUuQd6+txXBlCj0sE/VJnKj+4AzPeLSNzfixs2b7FmuI1z8hUQ337Kp4
	sJLG3OU2q1d2AkaFao118cz8uNbj/xSfUgd2Xr+Vn8P+LUwg6FFSVXHumhZMmaFgodv0DWFWMk3
	Ga+Sm2VdM00Lq8ToEx4iSLt24XzkVFll6PfxzSILGZxMV7Uo7PeILMLroPO/1VFRhHMHcr6oK8g
	JzvNdX20ywNikRHTyr/X4O7mT4iVgW0D04tp2QOnk4CG/pX4bQxVpdhjMQW6o551B7MOgmB/oJ6
	1somFHAmmVqt4JbWvb6/YijjFpwkHDik022uLkvaT60OJ1Hh5ze44O9BGLiq2Y5wfv4R9X1a0+y
	/
X-Received: by 2002:ab0:7db:: with SMTP id d27mr1855304uaf.4.1549994095389;
        Tue, 12 Feb 2019 09:54:55 -0800 (PST)
X-Received: by 2002:ab0:7db:: with SMTP id d27mr1855284uaf.4.1549994094681;
        Tue, 12 Feb 2019 09:54:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549994094; cv=none;
        d=google.com; s=arc-20160816;
        b=kRUfIym3eMGV2PNDKS+cA72WFiHBRymhLT8UXpgkzIJwNVjuJCf0hNFGQrlhId+g/M
         F1bbgAtLRofMfoVDUMXok0UqDnIV6AHDR7Zzec3iLG7n7DaSB4AKLF70R54ssX2M91cX
         AIPI+RwZZj2wGlAUQsG0mkcaNwP9IR82QHQ6e5xLxzimPyj1q5aL+ZTvSfEZxNsbDxME
         sPf674Vs8avtIqZTHjSKg88lX4N9/wAbNmcncMS6ZbXQa9tcjU4N0kHFjmjrVGTR3Yx7
         K2yjmEmxLzuWEQi1Hbk6Txv4HsKivjEDcpvoqNXtk/xSkHXGxSqOFsMjngE1cGvlaQFK
         a7HA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bsXKwkLM/R+hXtwloqz5pZs2yFDYV/aAOBs3Mg0VcqE=;
        b=eE8lDrQRgzFlcx7W0Av+5lSEBHmr/q4vUecj/p6kCyQULdAwF+ioRo30wHC68LJwVR
         9PFv/bQxflEp1imwlPo3xW4QaWQv0Mr0SyVGaj6BOnOkQTgx4QABnyRCM0FqZaYc5La3
         U0b9LXlkJfkh5MDH05/Sd4/aZaRFkeAZe99sBB1J5MTtWUxRvS6+1oveOto41TaCGe3d
         4XdiIKJ/uxT3Qvg2tpUIRyCPJGUVFG8oMUNBoe6FTQ+aHv5blJcSskERwocXWyt3R7z7
         12OvI4qTm0qrdhtvWh0vM+8dyiQKlQMBfSALARRURrOGqG4MQcvdycBE4FQQxo6zI9h3
         fdrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="YXi/S/5k";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r26sor1097082vso.17.2019.02.12.09.54.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 09:54:54 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="YXi/S/5k";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bsXKwkLM/R+hXtwloqz5pZs2yFDYV/aAOBs3Mg0VcqE=;
        b=YXi/S/5kfTLdxSWAC3y0wCGTa7uM67tEQsikFhpMThsF3Fc43hRI+myllvvpMyORc4
         zalCEhLUpcmJDU69dqHBEnudfmhTKEPJI19BZwd1rnqTqZNi4sBT62dYW1rWTaQXVUiK
         AiWOmDGpgYilpu0vMEamKc5zcK457gNd9aeMs=
X-Google-Smtp-Source: AHgI3IaEwF8bk1jD/oKatrnN5UxB8Ce3XSPyGuJKlM3WcNnlOULH/7+n4d/vwXu5gL245dUAignUKQ==
X-Received: by 2002:a67:7b85:: with SMTP id w127mr2093742vsc.199.1549994093848;
        Tue, 12 Feb 2019 09:54:53 -0800 (PST)
Received: from mail-vs1-f49.google.com (mail-vs1-f49.google.com. [209.85.217.49])
        by smtp.gmail.com with ESMTPSA id l10sm14399636vkl.54.2019.02.12.09.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 09:54:51 -0800 (PST)
Received: by mail-vs1-f49.google.com with SMTP id s16so2140780vsk.4
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:54:50 -0800 (PST)
X-Received: by 2002:a67:ec81:: with SMTP id h1mr2023032vsp.188.1549994090430;
 Tue, 12 Feb 2019 09:54:50 -0800 (PST)
MIME-Version: 1.0
References: <20190123110349.35882-1-keescook@chromium.org> <874b8c23-068b-f8e7-2168-12947c06e145@linux.com>
In-Reply-To: <874b8c23-068b-f8e7-2168-12947c06e145@linux.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 12 Feb 2019 09:54:38 -0800
X-Gmail-Original-Message-ID: <CAGXu5j+xz8_wkY2rVRML_iq1o7ZoF1jVp2mi73LjxaKuMNw1cw@mail.gmail.com>
Message-ID: <CAGXu5j+xz8_wkY2rVRML_iq1o7ZoF1jVp2mi73LjxaKuMNw1cw@mail.gmail.com>
Subject: Re: [PATCH 0/3] gcc-plugins: Introduce stackinit plugin
To: Alexander Popov <alex.popov@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, Laura Abbott <labbott@redhat.com>, 
	xen-devel <xen-devel@lists.xenproject.org>, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, intel-gfx@lists.freedesktop.org, 
	intel-wired-lan@lists.osuosl.org, 
	Network Development <netdev@vger.kernel.org>, linux-usb@vger.kernel.org, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, dev@openvswitch.org, 
	linux-kbuild <linux-kbuild@vger.kernel.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Greg KH <gregkh@linuxfoundation.org>, 
	Jann Horn <jannh@google.com>, William Kucharski <william.kucharski@oracle.com>, 
	Jani Nikula <jani.nikula@linux.intel.com>, Edwin Zimmerman <edwin@211mainstreet.net>, 
	Matthew Wilcox <willy@infradead.org>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 4:12 PM Alexander Popov <alex.popov@linux.com> wrote:
>
> On 23.01.2019 14:03, Kees Cook wrote:
> > This adds a new plugin "stackinit" that attempts to perform unconditional
> > initialization of all stack variables
>
> Hello Kees! Hello everyone!
>
> I was curious about the performance impact of the initialization of all stack
> variables. So I did a very brief test with this plugin on top of 4.20.5.
>
> hackbench on Intel Core i7-4770 showed ~0.7% slowdown.
> hackbench on Kirin 620 (ARM Cortex-A53 Octa-core 1.2GHz) showed ~1.3% slowdown.

Thanks for looking at this! I'll be including my hackbench
measurements for the v2 here in a moment.

> This test involves the kernel scheduler and allocator. I can't say whether they
> use stack aggressively. Maybe performance tests of other subsystems (e.g.
> network subsystem) can show different numbers. Did you try?

I haven't found a stable network test yet. If someone can find a
reasonable workload, I'd love to hear about it.

> I've heard a hypothesis that the initialization of all stack variables would
> pollute CPU caches, which is critical for some types of computations. Maybe some
> micro-benchmarks can disprove/confirm that?

I kind of think micro-benchmarks aren't so useful because they don't
represent a real-world workload. I've heard people talk about SAP-HANA
as a good test, but I can't get my hands on it. I wonder if anyone has
tried "mysqlslap"?

-- 
Kees Cook

