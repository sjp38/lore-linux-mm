Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01FCBC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:59:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBB4721848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:59:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBB4721848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A5878E0003; Tue, 26 Feb 2019 18:59:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 553738E0001; Tue, 26 Feb 2019 18:59:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 443178E0003; Tue, 26 Feb 2019 18:59:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 038608E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 18:59:52 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id n24so10749287pgm.17
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:59:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kVbHm7uA+lRoCt8YLLpOSyOKrca8STYcPt/f0WClJ1Y=;
        b=mwziwr9GzHrTpf/+4XjO0eJVys9HRiDAHRg/tVxQHF88xTwwMnGAg1rW8o1VgMZo7j
         bNWKeJmse+9Lyv9C5Npz4056XzlDXtdJkST4oI1UalZTV8IkmGTA2vdHWy0rQ+D4fS0m
         Prckvq37P3FLzaJVWb1UO9wK2SodtLSTXddjPvNrByr02r14fozG+VIlABuPqBtMIihl
         7Icts0Nc4LabXNZxpiYtoZiof/AwtyFKVnhadi9MGqYoz0dZjVDcUj7c+E7rV6C9Sao2
         zDN+mF+JzDrtb+MSvhLbES2+C9zvQwFDS4AF/pisGHyxzKLDqm9v+el5Cm/Z5vHXxUOM
         d3eQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuacz7GRyoQ5UECoMoKaZoZ6Z3TlwXqfJWCY6tUi7oPz69Zbey4T
	nEifHVfa0HlgLPMpN+SB4ZJX4x8Zhl2CQ1TUMVCIv4GTn9sTepycpKpbuzpP1pvqk0eMVTA46cn
	yTzp7lsm7WtfD+eCmAUzTAaUcxJLlgXuvZnWiHk+1qL3+84EGo0XcNqw1Q6g+z3zHrA==
X-Received: by 2002:a63:43:: with SMTP id 64mr74788pga.64.1551225591665;
        Tue, 26 Feb 2019 15:59:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZr6b1FboiXeBKwLXStK2EoG8IDqUwYynPMk8/RAd7Lht6C8o0u6jdQHT6fnshMjW4LJxKl
X-Received: by 2002:a63:43:: with SMTP id 64mr74745pga.64.1551225590739;
        Tue, 26 Feb 2019 15:59:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551225590; cv=none;
        d=google.com; s=arc-20160816;
        b=tGrId0c72fd3O4JyqKb2byQLUn94eb5ePHgfQyL1RfwNp16ns1YobmOY40gy29qVKB
         q9S+Y6z62oN3ksp0wW+EocM6BmoSTEQNgGbthTuEKrh+m0JPT4DmjqqdcYv20iO9OOVZ
         /kuCLgMTIFyHIIUsQfTTZGQuktKY0gYfZDi0KbqjxHMejWGvQ0bWb8lNgSrq0p51IRy8
         KQ4KTGuueiPolmhteJ8FeQTgFMGYB/gqjetnOvcUGJ7RUI9tKNtH0A701kzhU54hC9rl
         tnopdWCFehxwoTlMYmih7WXr+VQF38XrGRh45KOfDsTCxkVyceQzhr8KkoYk0bvQE8Hk
         qldQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=kVbHm7uA+lRoCt8YLLpOSyOKrca8STYcPt/f0WClJ1Y=;
        b=lrHtyfe1NeIeHPSSJ91hrEnDCVadC2uKWsN253SOVrhoPj0gISOFAKvNwnekn6Q0us
         M30e4TN9rcsfjwoTGt9887eA2wopDdYdnL1gI3R9+elglOMqR37Y8AWnnL8f3XSEdKxy
         uzD3RG8EzHepjqP7wwrpKTa8w25YUu+uSYVUW8pqFXHoE9nJQLQepCw9SgJ350ImOL5A
         ER6VosUqDDVTRc8hQWRPYRe4efgU9d5iizLdco+nTlWUlcVkXUtNc9ukPlMsO9H0UbBm
         yfxpw6pVRFfuh7o5YdnN2uU0QefED1ElNUrtuYjrDdaGVNZ+f0bmea8iO54wad91Q2vn
         Ma6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 40si3684737pld.318.2019.02.26.15.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 15:59:50 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id CD112833B;
	Tue, 26 Feb 2019 23:59:49 +0000 (UTC)
Date: Tue, 26 Feb 2019 15:59:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Mark Brown <broonie@kernel.org>
Cc: "kernelci.org bot" <bot@kernelci.org>, tomeu.vizoso@collabora.com,
 guillaume.tucker@collabora.com, Dan Williams <dan.j.williams@intel.com>,
 matthew.hart@linaro.org, Stephen Rothwell <sfr@canb.auug.org.au>,
 khilman@baylibre.com, enric.balletbo@collabora.com, Nicholas Piggin
 <npiggin@gmail.com>, Dominik Brodowski <linux@dominikbrodowski.net>,
 Masahiro Yamada <yamada.masahiro@socionext.com>, Kees Cook
 <keescook@chromium.org>, Adrian Reber <adrian@lisas.de>,
 linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
 linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Michal Hocko <mhocko@suse.com>, Richard Guy Briggs <rgb@redhat.com>,
 "Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
Message-Id: <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
In-Reply-To: <20190215185151.GG7897@sirena.org.uk>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
	<20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
	<20190215185151.GG7897@sirena.org.uk>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2019 18:51:51 +0000 Mark Brown <broonie@kernel.org> wrote:

> On Fri, Feb 15, 2019 at 10:43:25AM -0800, Andrew Morton wrote:
> > On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kernelci.org> wrote:
> 
> > >   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
> > >   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
> > >   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html
> 
> > Thanks.
> 
> > But what actually went wrong?  Kernel doesn't boot?
> 
> The linked logs show the kernel dying early in boot before the console
> comes up so yeah.  There should be kernel output at the bottom of the
> logs.

I assume Dan is distracted - I'll keep this patchset on hold until we
can get to the bottom of this.

