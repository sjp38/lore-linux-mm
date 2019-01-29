Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 029C2C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 05:46:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9471420989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 05:46:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="KWDKmtCf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9471420989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E35CF8E0002; Tue, 29 Jan 2019 00:46:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE5278E0001; Tue, 29 Jan 2019 00:46:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFB2E8E0002; Tue, 29 Jan 2019 00:46:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6C428E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 00:46:35 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u20so23393344qtk.6
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 21:46:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=bB1FCkNUdswjLFqFVeg1iGIzwpsiuISE6MtB5gKVSTY=;
        b=c21YReJB0ONXSrC9ic/yCRDNTGdQWzBWlSMfAdA9JlIGWZs96hG08BQiax8z+S/jBR
         PYkPXpvVbr99HlagTIEYwA8PElugblTgSSnelYHaJVRvEHJOudUJrXpoiSO0z6FiGFbR
         D+/iFBh5giyUbAwGLYud8ZO7f+IYMUaUXhozqPOThenBDqZGoU4OXApZJMPtM1pcKLE3
         howPFFfiYVYep9TOfjCbwYzfh0tL6ucArFVidCwl+Zb9QK5Ob9mVzq14e4fO0BYPHU7/
         lgPXQM4yPCazAwr3dViQetBb3H+2K5BVkPG9EkrjtNtWcMvz39jO20qVP90i4L8V7koD
         szug==
X-Gm-Message-State: AJcUukch4j7hBoQRilFh3dW4WCwXMjncaCxvaMSfHaAVDc1a3Li6weQH
	nMTr2t/NqY1mkn4J0pkcOAoYlojgln/sPhQVritOMNrDay19RjijI+jtTILfE6qsNaiyxqTZI2I
	37R+OsMptSReztQ2noatbsTVpktWd7ITUxBp6mOMYCvnrRHPPcZSbQ4FumHI3Lcs=
X-Received: by 2002:ac8:2281:: with SMTP id f1mr24120228qta.197.1548740795339;
        Mon, 28 Jan 2019 21:46:35 -0800 (PST)
X-Google-Smtp-Source: ALg8bN60wPaR/ksOBSv/P/bKOqEmPFWokHmtnU7Sg7h1mejm2fOdmnhpDstNt7EWsRZlMp0SWa/X
X-Received: by 2002:ac8:2281:: with SMTP id f1mr24120214qta.197.1548740794880;
        Mon, 28 Jan 2019 21:46:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548740794; cv=none;
        d=google.com; s=arc-20160816;
        b=uv359N6BtDiflksMKX+ahtheY40x0hMA0K8AMlzpUGMttLRcY0KI4onP1biao5BaAX
         yGYbUU2I96jugtm+R+QdKLH3cPxoJ0DtY3O1IZ9f19tB7AgsjggzWFyK+ln9G0OQEvBM
         8H5RXgX0sVHjaIlzoC52onJxd6NZDYwXy8w0cLtQjFPq8nQZNKZ6/8c2Yb50AMbcqSqu
         7mkTEJSFMxqkHa7uq4JoF6dfi1rfdVxS9dY6Pfk/7HAn0+C/y6yq2CB8kNhnePtKRcIi
         KnWre2pohHydqm/JVph0kCmLE6ifd5GYuY9TlhXBg11/aOfkDcXA8TxtOqcrsq+kUayV
         11xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=bB1FCkNUdswjLFqFVeg1iGIzwpsiuISE6MtB5gKVSTY=;
        b=Fz7kytdpubIivk3poARM+h+IyT0Bv191g/Kbk5v7e0xujU7ymcrxQY9cbby4jmLqg5
         5LZf6Qid/cyCJKaz+luyLjrMWtKpwu/uBt/fHAknekfZ+dWcOON7sTHf6ugcgYcE95CC
         w8pbCYeJUwF9ETQTGDJzV4lIJmaoYaRKasAbMZsh10KZ7Ngcb7sXtHizTdoCdXhIY2Tf
         6OFsIf35j+M9FKkcPoGZYHodlPooTNGuimJEIHvB8aeG/jQ4Qblel9P++6PSkC8qKGZ6
         yrumHBrT8DCS6gXsdRkDgV4g6jIl3A62S7jLI/8C5pA2NsGbDBkGawG1s7hR0AhHiaJk
         vQFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=KWDKmtCf;
       spf=pass (google.com: domain of 0100016898251824-359bbfae-e32b-43a6-8c58-8811a7b24520-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=0100016898251824-359bbfae-e32b-43a6-8c58-8811a7b24520-000000@amazonses.com
Received: from a9-30.smtp-out.amazonses.com (a9-30.smtp-out.amazonses.com. [54.240.9.30])
        by mx.google.com with ESMTPS id 34si172765qvq.116.2019.01.28.21.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 28 Jan 2019 21:46:34 -0800 (PST)
Received-SPF: pass (google.com: domain of 0100016898251824-359bbfae-e32b-43a6-8c58-8811a7b24520-000000@amazonses.com designates 54.240.9.30 as permitted sender) client-ip=54.240.9.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=KWDKmtCf;
       spf=pass (google.com: domain of 0100016898251824-359bbfae-e32b-43a6-8c58-8811a7b24520-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=0100016898251824-359bbfae-e32b-43a6-8c58-8811a7b24520-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1548740794;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=bB1FCkNUdswjLFqFVeg1iGIzwpsiuISE6MtB5gKVSTY=;
	b=KWDKmtCftgtgM2ZJcqVw4AL9rYmnXIGiC3KihZlVuwymWamuVEOrIzQAWGDPCMyK
	v01J/DJUit96069vJpL7d1G4EeFObs09La7bxos9AZ1B9iRWw9JK3IJFv9xYB6pC//f
	8F7sWarq8ACrydMAfd5INljkzut40byhQoc4/ZPM=
Date: Tue, 29 Jan 2019 05:46:34 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Andrew Morton <akpm@linux-foundation.org>
cc: miles.chen@mediatek.com, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org
Subject: Re: [PATCH v2] mm/slub: introduce SLAB_WARN_ON_ERROR
In-Reply-To: <20190128122954.949c2e6699d6e5ef060a325c@linux-foundation.org>
Message-ID: <0100016898251824-359bbfae-e32b-43a6-8c58-8811a7b24520-000000@email.amazonses.com>
References: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com> <20190128122954.949c2e6699d6e5ef060a325c@linux-foundation.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.01.29-54.240.9.30
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2019, Andrew Morton wrote:

> > When debugging slab errors in slub.c, sometimes we have to trigger
> > a panic in order to get the coredump file. Add a debug option
> > SLAB_WARN_ON_ERROR to toggle WARN_ON() when the option is set.
> >
> > Change since v1:
> > 1. Add a special debug option SLAB_WARN_ON_ERROR and toggle WARN_ON()
> > if it is set.
> > 2. SLAB_WARN_ON_ERROR can be set by kernel parameter slub_debug.
> >
>
> Hopefully the slab developers will have an opinion on this.

Debugging slab itself is usually done in kvm or some other virtualized
environment. Then gdb can be used to set breakpoints. Otherwise one may
add printks and stuff to the allocators to figure out more or use perf.

What you are changing here is the debugging for data corruption within
objects managed by slub or the metadata. Slub currently outputs extensive
data about the metadata corruption (typically caused by a user of
slab allocation) which should allow you to set a proper
breakpoint not in the allocator but in the subsystem where the corruption
occurs.


