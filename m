Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD1BFC10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 15:15:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C3FA2148E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 15:15:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="GvgiXh2j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C3FA2148E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F8CA6B0005; Mon,  8 Apr 2019 11:15:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A7766B0006; Mon,  8 Apr 2019 11:15:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 897046B0007; Mon,  8 Apr 2019 11:15:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A44C6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 11:15:13 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id i124so11913177qkf.14
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 08:15:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=CtKcuxRi7xBhOKcFdvYKUwz6gnLJDyf5JeeaCI9u4lU=;
        b=PoTpTOp+K8ailA+2izP6YQPNaqjZ4MS8ie6CE96B3E6LC6FEnGaFrcJWIZp9FZ3Y8z
         OzB+VWihcv+llM+T1EBb3lWNRfOrkv6GicMxyj0sQqNT+DsNBf6GVPuHeKkJHeNi4mD2
         qNvQ1+yYW355NFOQRt0+uQ4gOvI/taSousRhV/NYCEyDMR5v2ZDVedc5zQ+UKgfAwRK+
         jT/TAH1o1FZ1I2V4CrxnAs/6VMmxonoC8uFah4dLZ3HcrVYw/ft6AD/45NhDDGLm0UKT
         07WH+Q5EtCQGJEA4kdhddNlBbXp3+jxZymuE2vM4Ao80XMMV15W6MA1CTJs2602snb1J
         N0eQ==
X-Gm-Message-State: APjAAAVMhVvtWoT5lwTJaw1EYe/puq0rdQovKe0borJwzxbIrLEbZf/A
	K0xEJOKyDLIkZ59i/Bi7lhPQBO8d6/BgeT8VK/OBpjls18PzJQREIGmMjn+8KC9hHFvZC6decuK
	Yq7yGo6a/0A0KS+/XLZU4btRkhwzFfd+6IEeJSZr1VjWNY+TTXM6TtgOKO0G8IdE=
X-Received: by 2002:aed:3c5b:: with SMTP id u27mr25301947qte.6.1554736513081;
        Mon, 08 Apr 2019 08:15:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyS1wh9YT+zQ+c1/Xx66WnkOTDx6eybARA2URfwP+UGNs73Knh5veWj0AeZHu9HqG2ao/ug
X-Received: by 2002:aed:3c5b:: with SMTP id u27mr25301857qte.6.1554736512199;
        Mon, 08 Apr 2019 08:15:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554736512; cv=none;
        d=google.com; s=arc-20160816;
        b=x022tulSQL+oASdiO9k82sH3eHMfGRDUVq5hrYJszyQMF14n/EW1wZRwxI4zQMtvd3
         0TIFvl490bltYxxCpnHJcoFO+N1UV+WE1dMx3QfBDUNW6LtBdfvlKMAgPNfa0zfYdohw
         ktS16aXfavHnUOUjzD+a0XBVQ2RqBwfHJt6WUd920i+kcxEY24gckqyoFqmv5r7ui4Se
         AJGOGEzPQD32XK2I729Ki0S7l+FDiNINkEZ/TG1QPq2QPSrbdlJ4crdGtF6SAMTX6fVM
         MLuJJ5GiuT2Y1ussitGsAkm+8eZma6+3ZHcUqOd+VIA/4HKXlMmPXl+1D1MPSTZznMA5
         9zdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=CtKcuxRi7xBhOKcFdvYKUwz6gnLJDyf5JeeaCI9u4lU=;
        b=fPuDE8PHaDb5fVnPqmYYfyLb1NG6rkJOIiIpNnGO8tC6ZlCiMB2U3Ukx9qhxRMHETg
         //y5TnECd0CBdTMMPA4sDbPFWH0rgd90QLJl21rQUoBlcdyno5Q9mq8i8uZNY7eqf8CU
         EN4T0W6fDDwlzhUfgPenZISHEAgTrNKJgRDR4Me37Kxwihu1AnSkN1vBBkQE5UvI/vUZ
         hdOJTRK05UDE1HlZDago02gb6I6FqOgRD4aCP6L9ARWtDjCZfeeSlCinPZg4RQ80iDjP
         gZwgpKuF3tTO0Ekp1aHy3RcNeN4WNtIbOvl4D5hJjwQls3iUkfMSZjvU+8ppd8p25BIk
         It2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=GvgiXh2j;
       spf=pass (google.com: domain of 01000169fd847a25-5933cc1e-a520-416a-b634-84b3e7ce9960-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000169fd847a25-5933cc1e-a520-416a-b634-84b3e7ce9960-000000@amazonses.com
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id q27si2560254qkn.246.2019.04.08.08.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Apr 2019 08:15:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169fd847a25-5933cc1e-a520-416a-b634-84b3e7ce9960-000000@amazonses.com designates 54.240.9.99 as permitted sender) client-ip=54.240.9.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=GvgiXh2j;
       spf=pass (google.com: domain of 01000169fd847a25-5933cc1e-a520-416a-b634-84b3e7ce9960-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000169fd847a25-5933cc1e-a520-416a-b634-84b3e7ce9960-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554736511;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=lNudCzZ4w2s8/H8+lpBX7L/o8a8N/r9Gfx4wno1thXs=;
	b=GvgiXh2jwzAKEcSIvSEHZ7wXwO53kEXUrIQ32sBEP9JQ5xZuwvt2G2bVkMYkRab/
	s8KivUTDhpY3S/pzO5O2k7tEkQI0ZyRGpdsqWx71a9wJfL775CkbpHGn71j6vP8XsjD
	q7weJEid6EUbqwZjDvHiR2VVskTLBYw+21QKoko0=
Date: Mon, 8 Apr 2019 15:15:11 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, 
    penberg@kernel.org, David Rientjes <rientjes@google.com>, 
    iamjoonsoo.kim@lge.com, Tejun Heo <tj@kernel.org>, 
    Linux-MM <linux-mm@kvack.org>, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] slab: fix a crash by reading /proc/slab_allocators
In-Reply-To: <CAHk-=wgr5ZYM3b4Sn9AwnJkiDNeHcW6qLY1Aha3VGT3pPih+WQ@mail.gmail.com>
Message-ID: <01000169fd847a25-5933cc1e-a520-416a-b634-84b3e7ce9960-000000@email.amazonses.com>
References: <20190406225901.35465-1-cai@lca.pw> <CAHk-=wgr5ZYM3b4Sn9AwnJkiDNeHcW6qLY1Aha3VGT3pPih+WQ@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.08-54.240.9.99
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 7 Apr 2019, Linus Torvalds wrote:

> On Sat, Apr 6, 2019 at 12:59 PM Qian Cai <cai@lca.pw> wrote:
> >
> > The commit 510ded33e075 ("slab: implement slab_root_caches list")
> > changes the name of the list node within "struct kmem_cache" from
> > "list" to "root_caches_node", but leaks_show() still use the "list"
> > which causes a crash when reading /proc/slab_allocators.
>
> The patch does seem to be correct, and I have applied it.
>
> However, it does strike me that apparently this wasn't caught for two
> years. Which makes me wonder whether we should (once again) discuss
> just removing SLAB entirely, or at least removing the
> /proc/slab_allocators file. Apparently it has never been used in the
> last two years. At some point a "this can't have worked if  anybody
> ever tried to use it" situation means that the code should likely be
> excised.

This is only occurring with specially build kernels so that memory leaks
can be investigated. The same is done with other tools (kasan and friends)
today I guess and also the SLUB debugging tools are much more user
friendly. So this means that some esoteric debugging feature of SLAB was
broken.

