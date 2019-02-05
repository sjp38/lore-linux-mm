Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CDC6C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 23:11:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C93742184B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 23:11:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="dCs2TV6E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C93742184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25CAE8E009E; Tue,  5 Feb 2019 18:11:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20B118E009C; Tue,  5 Feb 2019 18:11:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FBC88E009E; Tue,  5 Feb 2019 18:11:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id D43898E009C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 18:11:22 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id l202so1500055vke.1
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 15:11:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=j5HkeUNThkthwBCR68NpvhUFgzSA/PWSkaEL6oAA0so=;
        b=cz+uu4RgzOrEIeh1q0OSjmabMr9D1gTKu65kNSxqibx5mrVc2JTA9A8tChZGnc7oUY
         ByRzdjkabnoHUcXiWHB37A8bjFI6Tc7uq0yC46IwQoBr9oPCAwHKebZvVfhKDs8cBbys
         DsiYWcby5x4LO/37nsTbn63aOX/oRZEY0IrbT1JtMhRlN1ZPv4vgqZvVdPJoSX9Dye5S
         TTm1eE7ZrwvQNDiy4dfqNyBgpiaRnJykmjD0ilqkEFyN0pzn/dEVKvE+bozPnQyNJ3Qp
         Anf/Pb43d1fUqRYmFFoYCdvafSLhvpP1sOPp7dq5y9vBuotoPNE1A85qArmmSNWry2rj
         F7lw==
X-Gm-Message-State: AHQUAubFjmnSMkaxkwNSurn63HOJZAmurrgzopU4pDBzdZ0YeAQhgEHI
	WXf+0axR5m+Dwtj+u22OrE/WKW8GtbHxYBQCzRN1WpY1b4LS+a+++2JGp0Afxstz+iV88VO469+
	hwGKKc4sBibJNJgJh1InYedtEZfGCFYl5+rAqlxg2EC/oD4u92Ta3n6jmGs9ksDvDriAPWg9nxK
	5R8A/Oz2jTFo8c92lz2VXt/gSU4oBYFixCAoF31XtwOU+LTiNsComQs7auFo8eil1qG2bMnASPH
	5Id6dumh6urFHanBDnk56f95HjRMEAn6rklzwGR5dNjsPffUYZSJCWuGuGtYYqUhr8ubmw9+dEO
	X2FlMyGuJluYMCsP//sqrK0oSJTaSp9xqgBaIjf2UlpMZT6+LpTZEutj67CpIEVLucrRM0d0pik
	z
X-Received: by 2002:a67:2a83:: with SMTP id q125mr3505724vsq.230.1549408282485;
        Tue, 05 Feb 2019 15:11:22 -0800 (PST)
X-Received: by 2002:a67:2a83:: with SMTP id q125mr3505695vsq.230.1549408281530;
        Tue, 05 Feb 2019 15:11:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549408281; cv=none;
        d=google.com; s=arc-20160816;
        b=oYx5Os67WJere1UTwZc3BUNJR0eSqh/We04atc62QFa6ikSa4FFIKcoaq763fyFlMP
         cOMyey+VPIUUX05Ts3ox1je5I16HftfvKNNgeulHXQBEOqT67gm4ty1RVLpcThvF4+0F
         TU8cKoYmY72xVmW5fcR02nUkjlOPX82RZ7y+WFrZ6+ZsTzD0dGkPxFGqNj0fDNYKIDww
         drMHQ/rDMdhcAikGNvAkCexC04rZrjSnNhkISkOlnZtq7rM3BK5pxePAvVKj8NIXpub8
         KkDFnX6EDP+TjjsPDgK006lalnIdnJUChP/IfnNU0rYVKbwYJZWaT7uM5/hmYgXRB6SL
         MzQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=j5HkeUNThkthwBCR68NpvhUFgzSA/PWSkaEL6oAA0so=;
        b=vP5q/l9YEFi9WKU/glAFH99pEz/OmuYGN9JnvxPmg32eQ7OQHQiv+zikVFGD9D/f+a
         etd+1ggK3vzYWJcZOGdyzTSofUw4S8TY0itWeUoSDDUrZZPko/uwjVrRwjwOI74GAMZX
         Q5IHMDK2BTqut0szDeUQBc7gkb2W1LWSua7CJKtet3nNsrwhbZGYrLeUDytrs3hFsSoJ
         oqmwIADPNAr2q93+KP4Pk3ZyRgsHFDzJgLtbkwYReNWgRBDq+01DWpdpOJW5M049H9JC
         XEZPvdZEhNCxPhhdQkHU+HArIjM8ifl/V5Ne92PtADFDNsNoStTztS8lngTVgXCkYscY
         Jp0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=dCs2TV6E;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e126sor3117234vsd.59.2019.02.05.15.11.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 15:11:21 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=dCs2TV6E;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=j5HkeUNThkthwBCR68NpvhUFgzSA/PWSkaEL6oAA0so=;
        b=dCs2TV6EswhYsGkHxXzoSizgamWNzyDPKTFsrF49nST+zEYbx0JwJuzXLVJUYEZwvr
         7lVHaP1Lg7vK7yuvorPST5mQnpxnP+llLDllFTvTPx8hEcj3yR4tEZ8DF91McZPJgyZo
         KVVaFiAHY3uI/piyeDdrK77bf9cvuloW7CAHk=
X-Google-Smtp-Source: AHgI3IZhMGv/+jFTOxS7oSYLyrJlcIXL1pF3dvCNFnN8ifwIBddM3NkzkSFSNCPsGoh8cJZl19QZgw==
X-Received: by 2002:a67:c584:: with SMTP id h4mr3283041vsk.142.1549408280523;
        Tue, 05 Feb 2019 15:11:20 -0800 (PST)
Received: from mail-vs1-f52.google.com (mail-vs1-f52.google.com. [209.85.217.52])
        by smtp.gmail.com with ESMTPSA id k200sm24080894vke.9.2019.02.05.15.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 15:11:19 -0800 (PST)
Received: by mail-vs1-f52.google.com with SMTP id x1so3283092vsc.10
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 15:11:18 -0800 (PST)
X-Received: by 2002:a67:e15e:: with SMTP id o30mr3333598vsl.66.1549408278541;
 Tue, 05 Feb 2019 15:11:18 -0800 (PST)
MIME-Version: 1.0
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154899811738.3165233.12325692939590944259.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190205140415.544ae2876ee44e6edb8ca743@linux-foundation.org>
In-Reply-To: <20190205140415.544ae2876ee44e6edb8ca743@linux-foundation.org>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 5 Feb 2019 23:11:06 +0000
X-Gmail-Original-Message-ID: <CAGXu5jJJQq358_H=xAcf=17WixnFx-P6HqTuv8uQn2zGgNg3Fw@mail.gmail.com>
Message-ID: <CAGXu5jJJQq358_H=xAcf=17WixnFx-P6HqTuv8uQn2zGgNg3Fw@mail.gmail.com>
Subject: Re: [PATCH v10 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Keith Busch <keith.busch@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 5, 2019 at 10:04 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Thu, 31 Jan 2019 21:15:17 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
> > +config SHUFFLE_PAGE_ALLOCATOR
> > +     bool "Page allocator randomization"
> > +     default SLAB_FREELIST_RANDOM && ACPI_NUMA
> > +     help
>
> SLAB_FREELIST_RANDOM is default n, so this patchset won't get much
> runtime testing.
>
> How about you cook up a (-mm only) patch which makes the kernel default
> to SLAB_FREELIST_RANDOM=y, SHUFFLE_PAGE_ALLOCATOR=y (or whatever) to
> ensure we get a decent amount of runtime testing?  Then I can hold that
> in -mm (and -next) until we get bored of it?

I love this plan. :)

FWIW, distros have enabled it by default for a while. Here's Ubuntu,
for example:

$ grep SLAB_FREELIST /boot/config-4.1*
/boot/config-4.15.0-45-generic:CONFIG_SLAB_FREELIST_RANDOM=y
/boot/config-4.15.0-45-generic:CONFIG_SLAB_FREELIST_HARDENED=y
/boot/config-4.18.0-13-generic:CONFIG_SLAB_FREELIST_RANDOM=y
/boot/config-4.18.0-13-generic:CONFIG_SLAB_FREELIST_HARDENED=y
/boot/config-4.18.0-14-generic:CONFIG_SLAB_FREELIST_RANDOM=y
/boot/config-4.18.0-14-generic:CONFIG_SLAB_FREELIST_HARDENED=y

and Fedora too:

$ curl -s 'https://git.kernel.org/pub/scm/linux/kernel/git/jwboyer/fedora.git/patch/fedora/configs/kernel-4.16.12-x86_64.config?h=f26'
| grep SLAB_FREELIST
+CONFIG_SLAB_FREELIST_RANDOM=y
+CONFIG_SLAB_FREELIST_HARDENED=y

-- 
Kees Cook

