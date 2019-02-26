Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDC4FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 09:46:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7212B213A2
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 09:46:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=bofh-nu.20150623.gappssmtp.com header.i=@bofh-nu.20150623.gappssmtp.com header.b="Qd/810rI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7212B213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bofh.nu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6AE88E0003; Tue, 26 Feb 2019 04:46:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1BFD8E0001; Tue, 26 Feb 2019 04:46:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B58FB8E0003; Tue, 26 Feb 2019 04:46:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4BA8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:46:30 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id s12so6276359oth.14
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:46:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=thpd36PDMXlf2G7WnhbmXGo66cBy7Bf++yJWkTn0nmw=;
        b=P5FbPD7t6DjA1QlBvi74elr19ZYrx01kU71e01moNn6sk2D4J1Mn2+hKkeQ/RVYZkn
         GDTKqE5mMg4qYXE4R443R8VNPm5oanI6a2CDycHX+uOMiwpdvQeudO75sqzAmA3lPakH
         w5RCQ1vRa8CybDP6NUQdDQFBmRQ2boQTi9kdHsECewzq2TR4hItFthID8AbLSUUQDWu4
         Bm3qVg1Te4s/MTUKbWRsSquWMUcnGNqqiP76A5fh5p4HOGK1cb1ySiFROnNrIwXwAMnN
         TgtfuCqJD7cSjFw8LnLOfvQ0zL3KyHkezx1SRyN14rHKWn57KB3k7SEmEByHUetmdnoa
         Oayg==
X-Gm-Message-State: AHQUAuYG76BrOEP4CanPku+SZebIfjf0eaz9gAYxeOxGlHglQJqX8qYA
	S2rphjDA8f1rpKf97ORXYvtHr/1g5v5Wk9Kb6q9c8oPIyya4hqTgvJtzvYkkhh4msNAxsm/Qae5
	941BGDAtfdvOSklyPk39cErLhqQ1tMS4IuJk0vT5LP3c7zikuar1Qww7qnPUmPUIBWk3q/O37eN
	gQZ25eipIlZAX9m8qwKPN1F5b9P+ZCZE22mm3x8ntXaYZBBkkbv/tMt+IaVrCqNX4btEZou/vUf
	5BNjUhvlcV4xHZlf1Q1fqXVyTs14sKMEj3rd5J+UFtVn2ZtnzzbiR5DnCrG2oSgbtMf9UEykw16
	rAbm42IYOWmJMxCuRwgYfUC9w5+NTpPicTlrrQ7OYdfEx3aLRJdqsXiG/JmZs0+K2nV821HRPpL
	o
X-Received: by 2002:a05:6830:1650:: with SMTP id h16mr3927840otr.66.1551174390320;
        Tue, 26 Feb 2019 01:46:30 -0800 (PST)
X-Received: by 2002:a05:6830:1650:: with SMTP id h16mr3927820otr.66.1551174389591;
        Tue, 26 Feb 2019 01:46:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551174389; cv=none;
        d=google.com; s=arc-20160816;
        b=L08UYqi3gsMJWQvn+lErHAVoG9m0gfT8rcxlLcf3NwoRp0QNuRuDE/hdLAej9l4L4T
         Ry1aSQb6mApM5kStjHlGI9WCiqH+wBxnu6gS+HmUvd2oA6+iSkn/Xy8vuZ+TEZm0k3cr
         rF+cyAquKlP8jPN+1KTxR14vNC0VfHd6llf/YYkT1AQnHXsSXGhnW3bH3zcgBvT5ELW7
         zOMo3/ZK5H7vRpCeRfbtWv2wnKTUF6N5jGqSVJn9L1XqJgBOQyaBZUcU4kp8O7TRIbNR
         s0SRPIZP1NQkAPOZCcr+uBA8Chuvl5qaBhuAwoIDXS0vz1iS9zFqV90oBJGnl+GAfXxX
         rDdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=thpd36PDMXlf2G7WnhbmXGo66cBy7Bf++yJWkTn0nmw=;
        b=eNJNn9PziwGVy+ZI4zeMAPoQl5cJXTkUGqAyVH0ZKEFPQlMhmMh0Th0V4AbfsDe7Pr
         jSHgejaC4KxrIGir2KtL9G8PxFYtExSKaI+1BMjUQnfXiaxnwzeKtPpOiYvvpU6fmEbh
         DELveyuzbtcBRx2QaDwQ8fDjX9mqa6EOp9RHJs+9Qv/Usf/uw4HcVJVJTlsUvVBp39ff
         9jQ/iv9BbDzz+vPHsv1msB9lEinuT9Ux3998V2rBCrac+W4GUADXhFh5x74USWDQDMpT
         zMdsv4i6WtywR+gXukq5eGq/JQTm1owfvPsrW7GeQX1yskfycGJmqyLzfH8bOQZjw9xC
         zf3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@bofh-nu.20150623.gappssmtp.com header.s=20150623 header.b="Qd/810rI";
       spf=pass (google.com: domain of lists@bofh.nu designates 209.85.220.65 as permitted sender) smtp.mailfrom=lists@bofh.nu
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r203sor6944804oig.90.2019.02.26.01.46.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 01:46:29 -0800 (PST)
Received-SPF: pass (google.com: domain of lists@bofh.nu designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@bofh-nu.20150623.gappssmtp.com header.s=20150623 header.b="Qd/810rI";
       spf=pass (google.com: domain of lists@bofh.nu designates 209.85.220.65 as permitted sender) smtp.mailfrom=lists@bofh.nu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bofh-nu.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=thpd36PDMXlf2G7WnhbmXGo66cBy7Bf++yJWkTn0nmw=;
        b=Qd/810rIbHZVnn/POX0r7Em7HLJy3zwba5Ohwnh53Y4rfT8lNrK39nxsEiPbwQ5z/I
         OAySi7W+31UstzKmlYrpgN9aQGi2Ff1sym79XC9ntc2Zn2reUe6pCOJGoJElcwAL68nU
         bvPwQta3TOcib/542rhHpxwloTVke418JGfEP6Vmyr472U7ir03NT0YlZnp3pCl6dW/R
         mYzIYcTRDO0TT5nXnNx9ARnLeHYSBaqCofGJnmm417D+mjsfVmf0fQlO/bFkJ0lTGcV7
         p2rJ7Qj00svxyjMr/5XQg7BwYqw+WbFumwhSP7lUiboJvd17OeVe26VEjMBLHrNAKG5i
         y7Uw==
X-Google-Smtp-Source: AHgI3IaMjF3tt02j/rMrAij/98lIAHBujBXjVnoKtLZvAXMu5xj1vob58lRLeDdRoVNjv2zPT6KCzj166JHhuKyuR70=
X-Received: by 2002:aca:3a0b:: with SMTP id h11mr1823500oia.97.1551174389008;
 Tue, 26 Feb 2019 01:46:29 -0800 (PST)
MIME-Version: 1.0
References: <20190219123212.29838-1-larper@axis.com> <6d12d244-85be-52c4-c3bc-75d077a9c0ee@arm.com>
In-Reply-To: <6d12d244-85be-52c4-c3bc-75d077a9c0ee@arm.com>
From: Lars Persson <lists@bofh.nu>
Date: Tue, 26 Feb 2019 10:46:18 +0100
Message-ID: <CADnJP=tOJbFR2hq_P+PvR0dxsrr6HR6iE5BMybEx_3zWjV4+Ng@mail.gmail.com>
Subject: Re: [PATCH] mm: migrate: add missing flush_dcache_page for non-mapped
 page migrate
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Lars Persson <lars.persson@axis.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	linux-mips@vger.kernel.org, Lars Persson <larper@axis.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 10:23 AM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
> On 02/19/2019 06:02 PM, Lars Persson wrote:
> > Our MIPS 1004Kc SoCs were seeing random userspace crashes with SIGILL
> > and SIGSEGV that could not be traced back to a userspace code
> > bug. They had all the magic signs of an I/D cache coherency issue.
> >
> > Now recently we noticed that the /proc/sys/vm/compact_memory interface
> > was quite efficient at provoking this class of userspace crashes.
> >
> > Studying the code in mm/migrate.c there is a distinction made between
> > migrating a page that is mapped at the instant of migration and one
> > that is not mapped. Our problem turned out to be the non-mapped pages.
> >
> > For the non-mapped page the code performs a copy of the page content
> > and all relevant meta-data of the page without doing the required
> > D-cache maintenance. This leaves dirty data in the D-cache of the CPU
> > and on the 1004K cores this data is not visible to the I-cache. A
> > subsequent page-fault that triggers a mapping of the page will happily
> > serve the process with potentially stale code.
>
> Just curious. Is not the code path which tries to map this page should
> do the invalidation just before setting it up in the page table via
> set_pte_at() or other similar variants ? How it maps without doing the
> necessary flush.

In fact this is what happens when the flush_dcache_page API was used
correctly, but it is an arch implementation detail. All kernel code
that writes to a page cage page must also call flush_dcache_page
before the page becomes eligible for mapping. The arch code has the
option to postpone the actual flush until set_pte_at maps the page.

