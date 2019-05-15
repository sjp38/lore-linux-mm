Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 603E8C04AB4
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 00:54:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15CE62082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 00:54:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bL4UagPL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15CE62082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0D2D6B0005; Tue, 14 May 2019 20:54:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BD266B0006; Tue, 14 May 2019 20:54:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 885846B0007; Tue, 14 May 2019 20:54:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0A56B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 20:54:32 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id f143so391384oig.13
        for <linux-mm@kvack.org>; Tue, 14 May 2019 17:54:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=o3pBh+WZzfqafN5dlWW0Wq5LSopVGwQt/9grztsVP8Q=;
        b=IVlidJ7ig8gIwEF5i4NVoOAwnE5F5JtCP1t9WfnaQKj8zz/YnBx7c7Pd9EmIzbZdtJ
         B/CG5lbXAhJ9L/ju663XCsjQVE/PfHYWdce3xKzXdkiBQxzj4SDoYapjzy7gT2hMVyeY
         BYIPRrgnOIJ/DH885Xwaq7HIZ4E9ISiSUR8Hc6IGCJbAn+uPtu9pbm0zGzgm373guAGf
         19bCzaSCf1CQrlR7KnxsyzC17MKkYZ+wTRnB42D4UTKYOXkccyMzLG4r+reVuwN/JtPC
         BqfEsx9n41z5tvVpdteCFE2Eg4kI+OR4p1J13GAiYFLjsWAzewaxsCfa8X1oOJs3tgWM
         kRAw==
X-Gm-Message-State: APjAAAVYDBZzzC+0TgR1XUQ3oGaihQWz6GzFkrwlf9CuPPL8a20EcooY
	7yCODoARlJj154YRyzltLNo+9w6I3fTF1+JOnNFGpIOdW397Rh8qYRGisRM/m0C/5WPsQo1af4j
	jXDXvgNfPf4xYE6eOH+5o0UifcdcmBDUnhYpkNc0DfdXVzH0H2CvfSSnLKWCv+Qs3Ag==
X-Received: by 2002:a05:6830:1291:: with SMTP id z17mr3326508otp.325.1557881672109;
        Tue, 14 May 2019 17:54:32 -0700 (PDT)
X-Received: by 2002:a05:6830:1291:: with SMTP id z17mr3326462otp.325.1557881671513;
        Tue, 14 May 2019 17:54:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557881671; cv=none;
        d=google.com; s=arc-20160816;
        b=Xkm8KYZvdP3sWPpJvB4ETCfOA7rN91KuTFgQLVzFPWXB3JESuWcVJi9z8qr0M2dzUe
         bsfU8jMgCroSOU+oPF236HAgW8TOLZnelyV2/QpcycTYFUN9SiGxQZuu3LBig0sr4Dy2
         G4ntjlOO2SrOpnSO7gkNySpXJ5pkWeUr/4Zl8yd2djyuMbN2B0a8RXhMY3ZdWaOdOm35
         d398PAVxGwuLeBJETSQHSORskKZYzQXeEIE11eSvQLhqNv0k+5R11ypx8g3dg3LMnZWz
         B/Kv+/sh9kVjL2AIE+4VahFqICpAoq4jwtUGMD+EX08oyVfn0SRnxFQH9lRxthmL5WaE
         Sh0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=o3pBh+WZzfqafN5dlWW0Wq5LSopVGwQt/9grztsVP8Q=;
        b=P1ScrIKDxECkYnEaDWZkxBNHqu/zuI/yfa/nktYn+6FXXZnJQQTm49BLBuF7dexW86
         1zFogHwzYXciP2IEPuTavv7v7GLbr4PvJ66bDL6Tudxc1ur82s7YRR8+yxvyut5PbnAb
         EzFQHIxXwUBQZTGjY2rafK6fvAkQbqGnMqLGeb5SsCPSPqlh/E6Zu1O2k/BbgO+stAC5
         5weGMoiyOYYJuwt9tBhySZiO2cvn/RMMsNaGrZWSPUnDxXJpZtiZFt7vOh8g/MmSR+eD
         g2i+X3zgHUomwSVU7pPqcXlWzQM502MTCVi/Vi3Cca6qDLl1vSpZo/10/z3pBzbvrNr7
         jeMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bL4UagPL;
       spf=pass (google.com: domain of nefelim4ag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nefelim4ag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v6sor199775oic.136.2019.05.14.17.54.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 17:54:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of nefelim4ag@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bL4UagPL;
       spf=pass (google.com: domain of nefelim4ag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nefelim4ag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=o3pBh+WZzfqafN5dlWW0Wq5LSopVGwQt/9grztsVP8Q=;
        b=bL4UagPLt/A/WHre/vmyevp4cdF/uZaIIauthXb/RSLU9boFflblpd0Igw0mDxecZ7
         OKh0jTET33oGC4lJ4iDWw1ztFq7aNdwe/1f2N6NepkwT23N1kXq4x/yBp6LThhqxTnNd
         mxH+VqHVcEDljU0cFZ4HSirp7abOy0L0gfHCzOPtfoTw4PEYpJG4QugwQdXnCAvMQ/tM
         FjN/LZUhJzwirenb+ZJ9NvSBV/+ZmBa7XbRdyvPpqgArPUPBxygDZu4abMWUDvvl4hML
         YVNJbFJ8d/r/0AnWOdikBf3g1MQIdSqPrH1HGUFbN3AVEt+mN9e91ZFm4dmYw4Wjs0jh
         IZdQ==
X-Google-Smtp-Source: APXvYqzLzjVzAuF91k9Rvra27CP94F8xT9tqGHftDUVQde0+Qqr/bBS2NaHTqcycqFttq3MebFh7YnEg8yJb4h/sK8E=
X-Received: by 2002:aca:f007:: with SMTP id o7mr4859752oih.59.1557881671192;
 Tue, 14 May 2019 17:54:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190514131654.25463-1-oleksandr@redhat.com> <20190514131654.25463-5-oleksandr@redhat.com>
In-Reply-To: <20190514131654.25463-5-oleksandr@redhat.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Wed, 15 May 2019 03:53:55 +0300
Message-ID: <CAGqmi77gESF0h8ZduHm8TTPKRqQLGFdCP15TAW5skDwZnL85YA@mail.gmail.com>
Subject: Re: [PATCH RFC v2 4/4] mm/ksm: add force merging/unmerging documentation
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Aaron Tomlin <atomlin@redhat.com>, 
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

LGTM for whole series

Reviewed-by: Timofey Titovets <nefelim4ag@gmail.com>

=D0=B2=D1=82, 14 =D0=BC=D0=B0=D1=8F 2019 =D0=B3. =D0=B2 16:17, Oleksandr Na=
talenko <oleksandr@redhat.com>:
>
> Document respective sysfs knob.
>
> Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
> ---
>  Documentation/admin-guide/mm/ksm.rst | 11 +++++++++++
>  1 file changed, 11 insertions(+)
>
> diff --git a/Documentation/admin-guide/mm/ksm.rst b/Documentation/admin-g=
uide/mm/ksm.rst
> index 9303786632d1..4302b92910ec 100644
> --- a/Documentation/admin-guide/mm/ksm.rst
> +++ b/Documentation/admin-guide/mm/ksm.rst
> @@ -78,6 +78,17 @@ KSM daemon sysfs interface
>  The KSM daemon is controlled by sysfs files in ``/sys/kernel/mm/ksm/``,
>  readable by all but writable only by root:
>
> +force_madvise
> +        write-only control to force merging/unmerging for specific
> +        task.
> +
> +        To mark the VMAs as mergeable, use:
> +        ``echo PID > /sys/kernel/mm/ksm/force_madvise``
> +
> +        To unmerge all the VMAs, use:
> +        ``echo -PID > /sys/kernel/mm/ksm/force_madvise``
> +        (note the prepending "minus")
> +
In patch 3/4 you have special case with PID 0,
may be that also must be documented here?

>  pages_to_scan
>          how many pages to scan before ksmd goes to sleep
>          e.g. ``echo 100 > /sys/kernel/mm/ksm/pages_to_scan``.
> --
> 2.21.0
>


--
Have a nice day,
Timofey.

