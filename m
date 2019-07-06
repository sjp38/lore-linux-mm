Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,GAPPY_SUBJECT,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21792C48BD5
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 18:33:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF33B20838
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 18:33:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rMLJmYNu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF33B20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D7418E0003; Sat,  6 Jul 2019 14:33:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 662088E0001; Sat,  6 Jul 2019 14:33:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 528B18E0003; Sat,  6 Jul 2019 14:33:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 258C08E0001
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 14:33:16 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id q16so6248090otn.11
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 11:33:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=L8R4z3fd/pNkVMb+89dxA4ui8k10ocj37Bt7whLaC1Q=;
        b=kC4S6gXXXoTiNxvYTEisWTabOC6ByCRy0b3PtrINqr6Y1+X4d3CmhyIMs0kz1MLelq
         6ZMXJ9t5fmUOB4jTqgFEL3r0kilXynnE8CFJYdDkxxixPqhPoIzMS0GMHoBo2CPZRUPt
         Q788ECF9L03qhMMOArQrLo8royuKHvnHa0POqpdKAZrdcMqB6freMC42YwB45xmiwT1Q
         RELQVx5aK0iL9rtTKMG3FgpGXeZlVFgS6SKTS+pjm7MQK5dwvWWChv/ZBEuKbr0UMuav
         L33g36v7lvpaceYMwQUBsConIuJpNu17BIKEGzalfXN6quTsqgLdnWWkWkPiQjK8Te9d
         jqoQ==
X-Gm-Message-State: APjAAAWmyd+rCUoftomXQcUVGoCuRFv8sv2buPE2FYzBqitdBM+xjy6S
	/7fOtNy5AN3tzd5FiGymCcROYeWWIGDFRGaG1wEY2CVBFDvMUu9Fwupjumb/DXiOEkmDsYI6cOF
	nmWpxHB74TL6HWsblDDgphsZRnwuG/vfYpQ056+p8DYWTiehc4Hp5LLH7Vwmfi1bz0A==
X-Received: by 2002:a9d:560b:: with SMTP id e11mr7987593oti.129.1562437995850;
        Sat, 06 Jul 2019 11:33:15 -0700 (PDT)
X-Received: by 2002:a9d:560b:: with SMTP id e11mr7987567oti.129.1562437995329;
        Sat, 06 Jul 2019 11:33:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562437995; cv=none;
        d=google.com; s=arc-20160816;
        b=zqj0Kj/hGx1RxpQR4qKlY9IrVXEqWo9RjybbwFWmz90e3OdrdCdOLTQu5iJn3CMzJw
         XOn+eOSgM4mNZJAHex9qUFYyNlgeo3wPeZuXnK2IsqWZp9x5eJcv3gLE5I9UVtJPwIvi
         lW4SOxuDmmzB4pVUUD64ChDvcK79bJZS/z267xSd84Iwlse5Wr8+H5pOFxvwYpnoxWKH
         GNCCCFGX3IK4xDFum2AjVlhn5pOZAJdWG+nehJADv7xZG+tnSFcAxMpPciEj/cP3hW0C
         GLxLMzpHzNeovnaFDin7cNR999G1+L+NSuwbe2MsOTfOEDlKJDvLFdJZkdOLRt40jWOz
         5XQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=L8R4z3fd/pNkVMb+89dxA4ui8k10ocj37Bt7whLaC1Q=;
        b=mmTKgQolFBfmd0uSgE26iDEp7EIE4buxb4qEjta/kw134PJdABDuWuxj/FjtPNPcoH
         wtvz6rWyjm+ZAsyDZ0OXdrIK/j/ws2JCMq9fEBpIbI64gR6P9GzEg4C963HeOifWahYl
         KRryePZCfIJIpaGJM8tXVZaB5FUEZQvkR/46twB0FjjXjj036iye4PT1D9+DWj3LIS6w
         f+6MOCEpYmXG5cc5zjCIC2ZMqLsKxxKU3IuElum8PU8ZhOAgw5yI/J1Eyae+WDG3UF5M
         P0SRvJ85X7Ja24DgxwGz1bJxxQj4UAdppq5oEToZZDBjhhk4t/vu51qvsthGP3spepX2
         fPFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rMLJmYNu;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7sor6473529otg.166.2019.07.06.11.33.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jul 2019 11:33:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rMLJmYNu;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=L8R4z3fd/pNkVMb+89dxA4ui8k10ocj37Bt7whLaC1Q=;
        b=rMLJmYNuSevuKWuCiVdI43bNmxi2G3pHLMt7d6UgYRzPT5IXjgo/GT6keDasRoZK4g
         /OBhvjWjUYS2v0qo9lkIJjfjkWE4kQLRuB6HOjB54kxbMOj7Ibd3pgQiMMTDL/I/5iCg
         2BeOM0HRHns6OEvAIi7NDoj2y/dlF3VxnijP9I+3HzHbLr7M1LTr+5Cg10Syh3dz5oTS
         pBae4r8DF086crOJ38wMkDHMpLDL60ovH7rl6Se08aUjhSzMzcn0vQpNsNrr1cgMoU/P
         YlfFMVxPhwry/SRvgTR1K80hTe9zWiuHkC34F1tIefAjUxRB4y7wu0+32btM3e8V9hGs
         3xLA==
X-Google-Smtp-Source: APXvYqyBcck06VlUCnJhTINmdA4ZJqB4oH2g6lhQMqchyhM/oF3KhFa6xeVxaox70u4OowtbK7dZn6ufESL4f0s1zvE=
X-Received: by 2002:a9d:774a:: with SMTP id t10mr7301075otl.228.1562437994877;
 Sat, 06 Jul 2019 11:33:14 -0700 (PDT)
MIME-Version: 1.0
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com> <1562410493-8661-5-git-send-email-s.mesoraca16@gmail.com>
In-Reply-To: <1562410493-8661-5-git-send-email-s.mesoraca16@gmail.com>
From: Jann Horn <jannh@google.com>
Date: Sat, 6 Jul 2019 20:32:48 +0200
Message-ID: <CAG48ez35oJhey5WNzMQR14ko6RPJUJp+nCuAHVUJqX7EPPPokA@mail.gmail.com>
Subject: Re: [PATCH v5 04/12] S.A.R.A.: generic DFA for string matching
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: kernel list <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Brad Spengler <spender@grsecurity.net>, 
	Casey Schaufler <casey@schaufler-ca.com>, Christoph Hellwig <hch@infradead.org>, 
	James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>, 
	PaX Team <pageexec@freemail.hu>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 6, 2019 at 12:55 PM Salvatore Mesoraca
<s.mesoraca16@gmail.com> wrote:
> Creation of a generic Discrete Finite Automata implementation
> for string matching. The transition tables have to be produced
> in user-space.
> This allows us to possibly support advanced string matching
> patterns like regular expressions, but they need to be supported
> by user-space tools.

AppArmor already has a DFA implementation that takes a DFA machine
from userspace and runs it against file paths; see e.g.
aa_dfa_match(). Did you look into whether you could move their DFA to
some place like lib/ and reuse it instead of adding yet another
generic rule interface to the kernel?

[...]
> +++ b/security/sara/dfa.c
> @@ -0,0 +1,335 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +/*
> + * S.A.R.A. Linux Security Module
> + *
> + * Copyright (C) 2017 Salvatore Mesoraca <s.mesoraca16@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2, as
> + * published by the Free Software Foundation.

Throughout the series, you are adding files that both add an SPDX
identifier and have a description of the license in the comment block
at the top. The SPDX identifier already identifies the license.

