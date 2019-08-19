Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B007C3A5A1
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 16:33:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EBD72087E
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 16:33:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="ZEMpBjD1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EBD72087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA3086B026B; Mon, 19 Aug 2019 12:33:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E949C6B026E; Mon, 19 Aug 2019 12:33:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D83246B026D; Mon, 19 Aug 2019 12:33:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0076.hostedemail.com [216.40.44.76])
	by kanga.kvack.org (Postfix) with ESMTP id B55D86B026B
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:33:44 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3E3F38248AA2
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:33:44 +0000 (UTC)
X-FDA: 75839723568.04.glass03_3daa71fc1dc12
X-HE-Tag: glass03_3daa71fc1dc12
X-Filterd-Recvd-Size: 4370
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:33:43 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id r12so2262899edo.5
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 09:33:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yVK+oDacf76Bx/B5cuYpj3efTA3uTCksTraTbtiiMb0=;
        b=ZEMpBjD1i8baVAX/ysJWrVswsclG5Ad98mIeqTE/tdXxI8qBuXPct792egADG2RR7r
         4WqNdNKNoNpDzDDyL8S5UElB1wql/7fcm9FEC9kEb9rR1nmCuc33o1Mu3CGfUOO4vaD1
         fVtFr3LF4sw1xugNbHHRMApJ+dbe8tCgl859HeK8Ezaw612OsfP2u11M5CKtz3i9aYuB
         raHJWrkU32+i55vWzSvZZhUa2Lorjv/Xn4/PRO2V0oFVOxB+GkW2KnO7ujnITNFll6K/
         wXTKtGUMyYu2QqZe/sMjFRDDbes+QqWwm1b95GyQAS45k3C2khb54EAK0qO674IRBVq6
         UlOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yVK+oDacf76Bx/B5cuYpj3efTA3uTCksTraTbtiiMb0=;
        b=DXwE6p/vTJ3Obf4SbMvikpyzMKTTmFQiroVPZHRFIdKNTaLzzlz2edXr64lSt23iny
         nD/KyF9EnJKWqX4WlLaHBwAyYHMjC6ciM7GSVkv4FlE3GJAJGjMdzV+shYtdgPIoQRJO
         6/6YdWpkdCcpK8JL4UUTwiFnf2F6bDaXVtm9n3SY8tg3Mq/N9vxrR8gPGAEHIoeeJ+7U
         pqQqQUIMGtPSftDM1a28f00lEwsmH/ql1oue+wZGxkiPxYUBa6GVHVJz6z3NgW88t1xi
         s/VDnK+Z88R+coBcmH8zbv+vWd+IANKGmc/MpgMm0HcgeWxI7jHquLUpF6K5ZTLrwRpw
         +hOQ==
X-Gm-Message-State: APjAAAU0DviahhRCJPVuxVdOmoRbzmlworNckg+Abka6N2OymgiLJYa+
	rMaTnF5RGw468to8ihP5cj++6wcZ1j3R6arccr+QBA==
X-Google-Smtp-Source: APXvYqyjbCqvgSjNDeQHl6JxdPMDE41wKcHDp+hgvJVj2Py8dcsk85GHr9ynLPCamRht+oDfymAzPK5UbbwLGbxAp2Y=
X-Received: by 2002:a17:906:ccc1:: with SMTP id ot1mr22297087ejb.156.1566232422354;
 Mon, 19 Aug 2019 09:33:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190817024629.26611-1-pasha.tatashin@soleen.com>
 <20190817024629.26611-4-pasha.tatashin@soleen.com> <20190819155824.GE9927@lakrids.cambridge.arm.com>
In-Reply-To: <20190819155824.GE9927@lakrids.cambridge.arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Mon, 19 Aug 2019 12:33:31 -0400
Message-ID: <CA+CK2bD4zE6eieSW2OLQwOQC7=4ncDc8wK6ZjhDO3Dv+BUqnzQ@mail.gmail.com>
Subject: Re: [PATCH v2 03/14] arm64, hibernate: add trans_table public functions
To: Mark Rutland <mark.rutland@arm.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, kexec mailing list <kexec@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	James Morse <james.morse@arm.com>, Vladimir Murzin <vladimir.murzin@arm.com>, 
	Matthias Brugger <matthias.bgg@gmail.com>, Bhupesh Sharma <bhsharma@redhat.com>, 
	linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 11:58 AM Mark Rutland <mark.rutland@arm.com> wrote:
>
> On Fri, Aug 16, 2019 at 10:46:18PM -0400, Pavel Tatashin wrote:
> > trans_table_create_copy() and trans_table_map_page() are going to be
> > the basis for public interface of new subsystem that handles page
> > tables for cases which are between kernels: kexec, and hibernate.
>
> While the architecture uses the term 'translation table', in the kernel
> we generally use 'pgdir' or 'pgd' to refer to the tables, so please keep
> to that naming scheme.

The idea is to have a unique name space for new subsystem of page
tables that are used between kernels:
between stage 1 and stage 2 kexec kernel, and similarly between
kernels during hibernate boot process.

I picked: "trans_table" that stands for transitional page table:
meaning they are used only during transition between worlds.

All public functions in this subsystem will have trans_table_* prefix,
and page directory will be named: "trans_table". If this is confusing,
I can either use a different prefix, or describe what "trans_table"
stand for in trans_table.h/.c

Thank you,
Pasha

