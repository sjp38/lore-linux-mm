Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D4A2C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:46:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFEDE20652
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:46:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFEDE20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26A2F6B0003; Mon, 29 Apr 2019 13:46:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21AD16B0005; Mon, 29 Apr 2019 13:46:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10BF86B0007; Mon, 29 Apr 2019 13:46:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3A5C6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 13:46:43 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id x128so1346028oix.17
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:46:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=4XNiWMXZiJc7H/jaqikR0q3+B4O1qwVQdNrN1Gohc70=;
        b=tNGZipv99biA2R8pP1pGsX/GULGL1VMEU5o3GZYYfwz549Xm62nw+JYi8wKBwsYHpb
         yg0nA8m6p3fSaZOcYv80xWsUe6o2MmwfQMvjeUrQ9shVvVoOTxV64gPibnlRvi0todKQ
         zJ34rifpUX5yrGHiJ3Q0/JexcAznzx+HOXPio64BM/kwia9nZcC0Sq6Pl/5K+VkmfUGD
         iGnwNShgv0sBHCnH2IScRl9ST2uqi4Myqm+SWbHGAukmZF2Db6GtNSj6e1BGdiVoU2q+
         zczVTYQpxYvLNzq3YlWfwUij/G+XWyhLjYDeThvo1YfFQ9O4ln/GvW/NrWpJpqhncknN
         EXlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVW/tahKlTaeYuGDqEjKpemJqw/8/2lxCNygE+eB9C2Fd1M5ead
	0owfTQPuXeShaAy6Mos8QTFLL6NEUT78DR9PoZheaEa0jdq6U17SrAP2yV/QcvuhBTYsb1+ytdY
	StE+Asu4nZusGl2rsHgOGFA4yK3YDIyFhlqyPvRNP+v7nto8WUHFi22BdcSnpwGYFdg==
X-Received: by 2002:a05:6830:204a:: with SMTP id f10mr7816264otp.83.1556560003601;
        Mon, 29 Apr 2019 10:46:43 -0700 (PDT)
X-Received: by 2002:a05:6830:204a:: with SMTP id f10mr7816171otp.83.1556560001516;
        Mon, 29 Apr 2019 10:46:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556560001; cv=none;
        d=google.com; s=arc-20160816;
        b=L6QxXv093KY+JHJ16lkSXDshrbUiiRxQu23MndUTqE3HVvbNOpe0s4dmwHk4m1LtuF
         +BGhn9xrfcwfYxygm7jJmXBCnn9mnu6A9mThFAxuuOSlNUUJ1m2EaEztv9i2yLfg0wN4
         OzmyVT0TUr+pEP3vHDfn9VB7LuAYScZo6tQUVJQoJkCZcJq+dn5rODJCMuqU0YDAgrHf
         RD97g5gCLkT2X9JGYbl2+rpgB6GZleblg4ct0JE6ef6Vi5wNz2RaWtTmZxY1yU7FR1rD
         56/eApuxuw867fYk3o+FibgGzHAZdXRG87Fxdz+YP2Yn4SotuFxfImfiQFnHj+e92obd
         HHJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=4XNiWMXZiJc7H/jaqikR0q3+B4O1qwVQdNrN1Gohc70=;
        b=GxXDzk+BJ3wHOfzgTV+gdaN9/tG4s6AT8zFp5N58EAZWrlKEdAYkMqqzoNGzO5YM4k
         hpyJH53pxaj/OvkserkfhA9x/XUXKIvlP1QUi4iTdN+UZ6zzJUCHRq1HSiMJbHARSsdV
         yzE4JpiP4JGiy81uSzSx9qyag9T69hBg3LgwC9cAJssvLCCS3ionNHxrOkzhcRmfE9oz
         KFo7efUnt+3UYtnQFgTUVVHE2nnkIDeEL3VyUMTvhm+nBhji9zq2apd4VBa4J5DrbOVq
         M1Y/e0Nnv+9orRTmsyG7S0Sd5EbisQRDS2XFP8T/MkuX/jPpIRUz0pyjtLv9kl8FeFWB
         yazQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor10145160otq.36.2019.04.29.10.46.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 10:46:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwEFPov5Fcmp1Z82klYLfGXcL8lJ+7fAYAgcVryDP/nX4tHzH4FfMhdUV9XfjfQTl9aLG0Z2jy1neqZ8hWMU+s=
X-Received: by 2002:a9d:6397:: with SMTP id w23mr15429856otk.332.1556560000444;
 Mon, 29 Apr 2019 10:46:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190429163239.4874-1-agruenba@redhat.com>
In-Reply-To: <20190429163239.4874-1-agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Mon, 29 Apr 2019 19:46:29 +0200
Message-ID: <CAHc6FU5jgGGsHS9xRDMmssOH3rzDWoRYvrnDM5mHK1ASKc60yA@mail.gmail.com>
Subject: Re: [PATCH v6 1/4] iomap: Clean up __generic_write_end calling
To: cluster-devel <cluster-devel@redhat.com>, Christoph Hellwig <hch@lst.de>
Cc: Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>, 
	Dave Chinner <david@fromorbit.com>, Ross Lagerwall <ross.lagerwall@citrix.com>, 
	Mark Syms <Mark.Syms@citrix.com>, =?UTF-8?B?RWR3aW4gVMO2csO2aw==?= <edvin.torok@citrix.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Apr 2019 at 18:32, Andreas Gruenbacher <agruenba@redhat.com> wrote:
> From: Christoph Hellwig <hch@lst.de>
>
> Move the call to __generic_write_end into iomap_write_end instead of
> duplicating it in each of the three branches.  This requires open coding
> the generic_write_end for the buffer_head case.

Wouldn't it make sense to turn __generic_write_end into a void
function? Right now, it just oddly return its copied argument.

Andreas

