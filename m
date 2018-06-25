Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB0D6B026A
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 12:09:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u21-v6so7341537pfn.0
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 09:09:55 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f7-v6si14264510plb.253.2018.06.25.09.09.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 09:09:54 -0700 (PDT)
Received: from mail-wr0-f170.google.com (mail-wr0-f170.google.com [209.85.128.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C401025DDA
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 16:09:53 +0000 (UTC)
Received: by mail-wr0-f170.google.com with SMTP id p12-v6so12631206wrn.11
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 09:09:53 -0700 (PDT)
MIME-Version: 1.0
References: <20180625140754.GB29102@dhcp22.suse.cz>
In-Reply-To: <20180625140754.GB29102@dhcp22.suse.cz>
From: Rob Herring <robh@kernel.org>
Date: Mon, 25 Jun 2018 10:09:41 -0600
Message-ID: <CABGGisyVpfYCz7-5AGB-3Ld9hcuikPVk=19xPc1AwffjhsV+kg@mail.gmail.com>
Subject: Re: why do we still need bootmem allocator?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jun 25, 2018 at 8:08 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> Hi,
> I am wondering why do we still keep mm/bootmem.c when most architectures
> already moved to nobootmem. Is there any fundamental reason why others
> cannot or this is just a matter of work?

Just because no one has done the work. I did a couple of arches
recently (sh, microblaze, and h8300) mainly because I broke them with
some DT changes.

> Btw. what really needs to be
> done? Btw. is there any documentation telling us what needs to be done
> in that regards?

No. The commits converting the arches are the only documentation. It's
a bit more complicated for platforms that have NUMA support.

Rob
