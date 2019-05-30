Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 221C9C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:54:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDD7925ECE
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:54:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="LYlHNdAV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDD7925ECE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 396E06B000E; Thu, 30 May 2019 13:54:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 347176B026D; Thu, 30 May 2019 13:54:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2102F6B026E; Thu, 30 May 2019 13:54:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C73356B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 13:54:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r5so9622164edd.21
        for <linux-mm@kvack.org>; Thu, 30 May 2019 10:54:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QlYOqgGgItn5hucl8pZOYZeRpF+/j+lyZEX0rN4v98g=;
        b=R0fU/+cvN5Pbr3vluKSwuNKUOBWa2ikNY+z5/V7cdFUMxa2fzfD19Vnqw5ct6Rol+E
         b2EdWnXOTlo8g7x64xzAUoB8HiZwj4sLRK0L4m7sL8mwMcNOPoLsuE6n9/0PKJCYvJVl
         le0Er9XLGh1CoJ76+B7cYvc5MXBLX56/+38sbG0+jJS/sF8Nrcbvjst8XKPs0FstC0aa
         SKT5uahE/o0fMOJ1bb1oJzQ1EPLmcj0iBMPTv+XhNJccmTAKMOxlFGe+FtYL8r6xXp9o
         3NQtYqVhd6ctz1lkfeJztCF1uS3uCmt45yw+bfQ1V2fFlbXOVE5zsJuZEVYuEhfTIpPZ
         7U1A==
X-Gm-Message-State: APjAAAVW4Dz+D9cgpRAB6+6DVp/Xws2v1bEjGU6vrtHUclKZevgJpf4q
	cvhP0Q1Nzv35BPaWyJHCrJzCc9/kvfacCMedgHRXQcBvFJ7/yd6bw7V+FXsMBmKRXkqNP29cYDX
	0nyTsFoMLsWO7Q9fQYc5SoY9+z/7XtrylnUJzKvNf4Kp/ijVIaM2wEnRUAcTvHaQkSw==
X-Received: by 2002:a17:906:55d5:: with SMTP id z21mr4834768ejp.82.1559238842164;
        Thu, 30 May 2019 10:54:02 -0700 (PDT)
X-Received: by 2002:a17:906:55d5:: with SMTP id z21mr4834715ejp.82.1559238841306;
        Thu, 30 May 2019 10:54:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559238841; cv=none;
        d=google.com; s=arc-20160816;
        b=QljuDNG9z/O30pRSE3NxwWjeH4aeA4P3sLiwGDo6Mo41jlutkvkkDL+tA9C+IJvvmt
         9+f3yWYvddG+biAP29a47yPgxOld5oNFk+C90usJXkrI56undf5d+1BfnBMIfCIScsTR
         BcoFAnA7hfeOJDDRJnSYj62QVWfthQyJBmpUQ2/W0eEYQ1t9Z/DicML4TNkWZab0MGoT
         hvXx4kCsyiXBp2jB6GSLxLo1q64XT5dxqJqh4a4WsdNz3fi4P/eXx9qVU6zMRurTErPY
         9uyJZSx9igyFa2Kt8PEDFCnIUbqLGnxVBLjQCt40fXwbzE/DNJiM0osFY625lZm97L2y
         XFBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QlYOqgGgItn5hucl8pZOYZeRpF+/j+lyZEX0rN4v98g=;
        b=I3hlHcD54NbH6v1j2UnM6rn2n2OWiW4Sd3DXXF55qnL1wHgxKoA2m6r2HKlcTVLqVv
         oIKIXgh630O+ESJB36zhrXo5LYFQHmEbjf+0fJwSBFzohvlY5Tdq0/8y42WcsZzfBh/8
         8QZipSrPUwoEC4PcK/iigPaRMSv/QeO4QEYMf01ELhPDJTxLafXgzS9Llcov53roQRlS
         65ASyyDk4BF21rO/hftaP+svqwHL7KGJNO4rBEczVU8BQIZYX26buOFUwwQilwFlJsOi
         0H30fdlK38QR2SxjygmR8FD7sQ+65DOao4CDrowFBbRYXkPLg8BAvO1t2/uPFqoRldq/
         dJZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=LYlHNdAV;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gx1sor1149417ejb.7.2019.05.30.10.54.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 10:54:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=LYlHNdAV;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QlYOqgGgItn5hucl8pZOYZeRpF+/j+lyZEX0rN4v98g=;
        b=LYlHNdAV/SNBSa2OU1jdHVGlps7i+f4ToRjbTl9D2wFgpxOnqYU6L0tHRyBKqXN8PS
         bA20mdUlqFwilW74sDweWwxCRjLlo9fuLRBJptvvxIq+vYgZ96pbtG7pADnxLsZ5u6Ed
         xa3CEpbgxATF5V1HpcSCSGovWdI7wIoti8PlUbQ7uPq+eFKDXrzPzbDKxcOs/rbfxHdW
         3wcYT/Y0vSetxxTI7PMr+4dEKBZMAaPHqAJ4cafp6No1HT2gZdPpzYTqxY9BWFqu5i8v
         c8SEsw9ZPMpf8Cmj587OTzTy+La1UCwO9pu1FiOK6SpUJ9aeYM0ra8QLMjn3GNWlh/JN
         PXWg==
X-Google-Smtp-Source: APXvYqxJpnEky/HQoCMiqMXy5GPOyKza2hJ+52II0wfo1HpL9rVDxjuGoL3UWKguhdIYjncFwf0xnjjAWLfB3JRkG5w=
X-Received: by 2002:a17:906:a354:: with SMTP id bz20mr4932536ejb.209.1559238840892;
 Thu, 30 May 2019 10:54:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190527111152.16324-1-david@redhat.com> <20190527111152.16324-2-david@redhat.com>
In-Reply-To: <20190527111152.16324-2-david@redhat.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 30 May 2019 13:53:50 -0400
Message-ID: <CA+CK2bBW4vH+J6bam1dOxjSwFwvoOEok0VNO0n_JjyHxpkGj+A@mail.gmail.com>
Subject: Re: [PATCH v3 01/11] mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, 
	Wei Yang <richard.weiyang@gmail.com>, Igor Mammedov <imammedo@redhat.com>, 
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, Qian Cai <cai@lca.pw>, 
	Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>, 
	Wei Yang <richardw.yang@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 7:12 AM David Hildenbrand <david@redhat.com> wrote:
>
> By converting start and size to page granularity, we actually ignore
> unaligned parts within a page instead of properly bailing out with an
> error.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

