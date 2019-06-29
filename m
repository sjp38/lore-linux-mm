Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDE1FC5B57B
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 23:52:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63C3621743
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 23:52:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VOuG3yeR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63C3621743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D76A86B0006; Sat, 29 Jun 2019 19:52:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D27098E0003; Sat, 29 Jun 2019 19:52:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3F728E0002; Sat, 29 Jun 2019 19:52:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f207.google.com (mail-pl1-f207.google.com [209.85.214.207])
	by kanga.kvack.org (Postfix) with ESMTP id 895C66B0006
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 19:52:04 -0400 (EDT)
Received: by mail-pl1-f207.google.com with SMTP id 91so5442262pla.7
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 16:52:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nP4lp/e6AIs94o4YYLZYg3jH19AwRg6rp3ToZBgb4Xc=;
        b=Ff7rxC1HIE/ztDgPxH9HccX3G6gWlZhIfy3v2bhQr1xtRdqUSt5Tc5aLw59XhlYPXK
         vovybAC2PQQOstL3p6MaNyZYgqZNNlu5lEyohZKR5h6Wgb6O+SUoLCIt6Bwfzv2XTBy2
         c8gpT3x7WSw0pT3D3+b/iDfp96bjroZCybKWGfhJ5xhAlqt1IXbWff53XUVV9qLqw1Z1
         kSQA2hh+tHzlou4raAVx1OusWWvJ4+lbf6Zcx8q5eMryXqu0vwqUSE3eOcS4OfY9715i
         sggrSf4fZK4ksRxGKqOjM3zBW6ogs2R1CcbwssL3AQjeMxWFxph8g2aLxJ8un+68jLEp
         bsjQ==
X-Gm-Message-State: APjAAAXj3zPZv8DlhjxqeOhPfyHoKbM1PcIpu5dzsUnIGVMa4aUxZWqt
	p02DjJQ5e28lC8JGlQfySaZjgqKh1YKSpJ4b/UEMO59nTG4gIHqsJgW+dFNS330mCAJRK+UZIAX
	lt62bglB6vVs1kGuUmPJtn8k3+72XV3i0djywIY4ZMXV59PEAsi8Hstnu9XTJeLFBJw==
X-Received: by 2002:a17:902:6a88:: with SMTP id n8mr20331741plk.70.1561852324240;
        Sat, 29 Jun 2019 16:52:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6R+guRam+z/+bTyx8r2M5V1t6MDkeLFpPDOX9rkQl1ir3xtA8qrq6ZkNV+PvLkK62WeE2
X-Received: by 2002:a17:902:6a88:: with SMTP id n8mr20331706plk.70.1561852323497;
        Sat, 29 Jun 2019 16:52:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561852323; cv=none;
        d=google.com; s=arc-20160816;
        b=gMxtNLXEICunGb4TCF3wpOwslT4WPRbZuv5L6+4a4IGwpX1OODVsAsnRU5RYcxa85M
         CahEz6kraCW2hRwbiZne60Kf3wPpbxZRujmYKBRH/072PM1tSU5zAs4UTyT9NCbkkHEI
         T7MZw2Ps57bq0fHQv8ZAQ96uEtAYlXSr63Jq4ndzsuWmdraAR91/v03bNXkBMv+YDnp0
         oRMVPcf3BXoX2wgfVvPo0ecwvbvwxwYFiDsY1Gz6YzeVCnrJWv4pOHYHX+E4gAwrXOWz
         +fkBX4HUiCWv4Syaib+f02S9fzjhk+nIFt3kw7ywmfGbjUO2EaoZBDQl8tUpyjFnf9oy
         4Rgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nP4lp/e6AIs94o4YYLZYg3jH19AwRg6rp3ToZBgb4Xc=;
        b=BmZ1AB8XykENMwLNCneHNmQlJ1Xg12NpwfJ6wD2oNVyJ3NpVIzJ4jPwZSIumjZTHrF
         kqS87eMD9hKSwJgpyMHTk0SIwKkbFYdF+9NL4oQT+oR72v3e/cHaNbk5x/4aHB3KGApv
         hl1DJMO4gh/v6l8l7CyOE+YOQrnUu7P72njQv1mw1qeVHKQU6txbQeWzuuFfbIATEPBY
         HZ0cxp2nQxouSnVUrs5zdUlZJz21+aFEeO+XlpyhuDimXH22vX39zXn2ttWzIaQOHZLP
         h2L7HmJuYS1hCL6CRObG2JzetV+ZWRN/o5N/80YXkSQn2U9rm9uo0TRiCjj23t3FmyWv
         aZVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VOuG3yeR;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e12si6194358pgs.34.2019.06.29.16.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jun 2019 16:52:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VOuG3yeR;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D11412183F
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 23:52:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561852323;
	bh=6zNQnfiowkbQ8h6I1Y7teWbbkPJhz6He7iJKmvs4QWA=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=VOuG3yeRXBw73ehV65Jk05S6ykpdaWN2++D3t48FGNnRIpDyvwGQ/O+9+jEcQ2kLh
	 vJaCio+aAWmRuF+Q74veK48algDDWoAePRXa6sfpOSPcNYY4cIAvDYMztVQaxLrq6F
	 GUxAMYw40KHXc3GwNPQztaUlUU75iWpM7vkEfIdA=
Received: by mail-wm1-f52.google.com with SMTP id s3so12362486wms.2
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 16:52:02 -0700 (PDT)
X-Received: by 2002:a7b:c450:: with SMTP id l16mr12352705wmi.0.1561852321259;
 Sat, 29 Jun 2019 16:52:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190501211217.5039-1-yu-cheng.yu@intel.com> <20190502111003.GO3567@e103592.cambridge.arm.com>
 <CALCETrVZCzh+KFCF6ijuf4QEPn=R2gJ8FHLpyFd=n+pNOMMMjA@mail.gmail.com> <87ef3fweoq.fsf@oldenburg2.str.redhat.com>
In-Reply-To: <87ef3fweoq.fsf@oldenburg2.str.redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Sat, 29 Jun 2019 16:51:50 -0700
X-Gmail-Original-Message-ID: <CALCETrUPJXW7An9EBaRQLppB3vHEQFfYP1o8h-4PSFcZt5Pa2A@mail.gmail.com>
Message-ID: <CALCETrUPJXW7An9EBaRQLppB3vHEQFfYP1o8h-4PSFcZt5Pa2A@mail.gmail.com>
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
To: Florian Weimer <fweimer@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Martin <Dave.Martin@arm.com>, 
	Yu-cheng Yu <yu-cheng.yu@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, 
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, 
	Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Szabolcs Nagy <szabolcs.nagy@arm.com>, 
	libc-alpha <libc-alpha@sourceware.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 2:39 AM Florian Weimer <fweimer@redhat.com> wrote:
>
> * Andy Lutomirski:
>
> > Also, I don't think there's any actual requirement that the upstream
> > kernel recognize existing CET-enabled RHEL 8 binaries as being
> > CET-enabled.  I tend to think that RHEL 8 jumped the gun here.
>
> The ABI was supposed to be finalized and everyone involved thought it
> had been reviewed by the GNU gABI community and other interested
> parties.  It had been included in binutils for several releases.
>
> From my point of view, the kernel is just a consumer of the ABI.  The
> kernel would not change an instruction encoding if it doesn't like it
> for some reason, either.

I read the only relevant gABI thing I could find easily, and it seems
to document the "gnu property" thing.  I have no problem with that.

>
> > While the upstream kernel should make some reasonble effort to make
> > sure that RHEL 8 binaries will continue to run, I don't see why we
> > need to go out of our way to keep the full set of mitigations
> > available for binaries that were developed against a non-upstream
> > kernel.
>
> They were developed against the ABI specification.
>
> I do not have a strong opinion what the kernel should do going forward.
> I just want to make clear what happened.

I admit that I'm not really clear on exactly what RHEL 8 shipped.
Some of this stuff is very much an ELF ABI that belongs to the
toolchain, but some if it is kernel API.  For example, the IBT legacy
bitmap API is very much in flux, and I don't think anything credible
has been submitted for upstream inclusion.  Does RHEL 8's glibc
attempt to cope with the case where some libraries are CET-compatible
and some are not?  If so, how does this work?  What, if any, services
does the RHEL 8 kernel provide in this direction?

