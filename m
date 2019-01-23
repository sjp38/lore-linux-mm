Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEA06C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 16:50:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BC6B2085A
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 16:50:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BC6B2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A90278E0035; Wed, 23 Jan 2019 11:50:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A40778E001A; Wed, 23 Jan 2019 11:50:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 955428E0035; Wed, 23 Jan 2019 11:50:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 580F58E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 11:50:38 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id x26so1850541pgc.5
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 08:50:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:reply-to:to:cc:date:in-reply-to:references
         :organization:user-agent:mime-version;
        bh=n73MorgM5BfXTEufxFwRjcabWFxMT3tYBZfPdCnZH/g=;
        b=Ja4xRHX3EutStDc76ZUxFYdpdCu++/yrDD/csNneyQsa/smGHEl6iabk/zScW1O3js
         SRg9ilQ/Gh+pi989j+gmfXQcsS68k+OPRbSOpkkw+TrD9xC23QXEb1RdJavQuQVvkc6o
         WcHoMrmE78j5CQuTZNu8k9IdzC5wDoCP+6fVP3DrJvg0shqsycLuMEz6mPkEN5LdqB4M
         wSOSK2hlr2qejsw8lrgJpT+JaWVegsGi8+njNeQyzMF0nEqzYzNRWvgr2IQIEu+PzQpM
         kut7BxidwZbZLNiVOY+6E3XkoeBlD4HhDuDgFx9z9xIhZY3jDEiWjKNFcZbmWL7H0NaF
         cX0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jeffrey.t.kirsher@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=jeffrey.t.kirsher@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukeFj1yac2SEjnPb8/FzPWRdiW296Cbu0QF9BxVVikFWXyX1SZRF
	ySbAAedh05fXKc71/4oDIyhTLJAjUaQgs9xmxKgoencD8TQ960utlfTVX5F5XF1P1zRA+20jLfu
	XpmGOsnMCeTLXdUxm0Kz60TO2Z0r9Uhr53cwgWEB494jgydpZ4n34lFNwPSA2jE1vDQ==
X-Received: by 2002:a62:9719:: with SMTP id n25mr2742489pfe.240.1548262237850;
        Wed, 23 Jan 2019 08:50:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5hiVkUl77469s+HmIyQQmVx0TdMSl+wY65iyJC9NhnzWssViEWecgHFeO5VCkIaHM3LreT
X-Received: by 2002:a62:9719:: with SMTP id n25mr2742444pfe.240.1548262237122;
        Wed, 23 Jan 2019 08:50:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548262237; cv=none;
        d=google.com; s=arc-20160816;
        b=l1yxXpPlc8jiuhyOazBrGAlTLWWQY2ys6H/kuaQmcxoHfi3X3NJjzpP2Xh4Kulf7I5
         QxaTjctk3GYOOemEaNy0hCp31lgwakX71xleH1AUCOVKd3yJbUs1b1QplQtdQ3CF3CcB
         wjv1kdYHr76GJ0V0w/LlEZINLlIKuiD9PykEKKiWsfsFs5RVSlBsxipsCVZ/W4LOw4G6
         F51us0aXjp77hlD8U7c5qvP8Smj5La09qkXkd7ftvn/2HSkuxk75hzuOjZ29vbERneo9
         I4wDbw+qfkH0Fg7ryncuArfHNMKmAI8Tsb7Lxywts3uJ8M1lnP1Lfi3dIQfqcOZSolyk
         MBrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:reply-to:from:subject:message-id;
        bh=n73MorgM5BfXTEufxFwRjcabWFxMT3tYBZfPdCnZH/g=;
        b=iQkXX5KmyyKde1YI4ROCSRUHaf31tcursMHvoa+iKGfL5C3GZNDBUMVz+k32zOeBg3
         Q82NQl7Oqxi9cBglF5ZnATDOwd0aytKs6c9LtYP+HGohWxJMyy3rVB12W2oKsQX7OpkB
         808O8+1pL6IAfWhO+FgPopQJOLeBuLvHBcVJaAN2t130IYkT9a0292DPRbdw7aJjK8nl
         WwwZYQpLUrukJdMPpDXqcaMjZ1TOJETxtzn3GLWtcQwUBtlHFkMxWdY15oxMRvGAm4aA
         3IiIFUr2JliS27YLO5HpqdqKcC4Ou1febzBkiga4xHJ7+6V8YMwP7gJBt2OKWgyATDAl
         kCMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jeffrey.t.kirsher@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=jeffrey.t.kirsher@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id x128si6588679pfb.128.2019.01.23.08.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 08:50:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jeffrey.t.kirsher@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jeffrey.t.kirsher@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=jeffrey.t.kirsher@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jan 2019 08:50:36 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,512,1539673200"; 
   d="asc'?scan'208";a="312849120"
Received: from jtkirshe-desk1.jf.intel.com ([134.134.177.96])
  by fmsmga006.fm.intel.com with ESMTP; 23 Jan 2019 08:50:36 -0800
Message-ID: <7d8a6120ea335d74c41a5fba3754518ea60e936e.camel@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/3] treewide: Lift switch variables
 out of switches
From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: dev@openvswitch.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
 netdev@vger.kernel.org, intel-gfx@lists.freedesktop.org, 
 linux-usb@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org,  linux-security-module@vger.kernel.org,
 kernel-hardening@lists.openwall.com,  intel-wired-lan@lists.osuosl.org,
 linux-fsdevel@vger.kernel.org,  xen-devel@lists.xenproject.org, Laura
 Abbott <labbott@redhat.com>,  linux-kbuild@vger.kernel.org, Alexander Popov
 <alex.popov@linux.com>
Date: Wed, 23 Jan 2019 08:51:38 -0800
In-Reply-To: <20190123110349.35882-2-keescook@chromium.org>
References: <20190123110349.35882-1-keescook@chromium.org>
	 <20190123110349.35882-2-keescook@chromium.org>
Organization: Intel
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-ckUn9AFZsnGNoWsnxDog"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123165138.FvgeVM_gbWl4tcZsTRM99QOdkzBTlmL7cXyhQHn_xTw@z>


--=-ckUn9AFZsnGNoWsnxDog
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-01-23 at 03:03 -0800, Kees Cook wrote:
> Variables declared in a switch statement before any case statements
> cannot be initialized, so move all instances out of the switches.
> After this, future always-initialized stack variables will work
> and not throw warnings like this:
>=20
> fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
> fs/fcntl.c:738:13: warning: statement will never be executed [-
> Wswitch-unreachable]
>    siginfo_t si;
>              ^~
>=20
> Signed-off-by: Kees Cook <keescook@chromium.org>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

For the e1000 changes.

> ---
>  arch/x86/xen/enlighten_pv.c                   |  7 ++++---
>  drivers/char/pcmcia/cm4000_cs.c               |  2 +-
>  drivers/char/ppdev.c                          | 20 ++++++++---------
> --
>  drivers/gpu/drm/drm_edid.c                    |  4 ++--
>  drivers/gpu/drm/i915/intel_display.c          |  2 +-
>  drivers/gpu/drm/i915/intel_pm.c               |  4 ++--
>  drivers/net/ethernet/intel/e1000/e1000_main.c |  3 ++-
>  drivers/tty/n_tty.c                           |  3 +--
>  drivers/usb/gadget/udc/net2280.c              |  5 ++---
>  fs/fcntl.c                                    |  3 ++-
>  mm/shmem.c                                    |  5 +++--
>  net/core/skbuff.c                             |  4 ++--
>  net/ipv6/ip6_gre.c                            |  4 ++--
>  net/ipv6/ip6_tunnel.c                         |  4 ++--
>  net/openvswitch/flow_netlink.c                |  7 +++----
>  security/tomoyo/common.c                      |  3 ++-
>  security/tomoyo/condition.c                   |  7 ++++---
>  security/tomoyo/util.c                        |  4 ++--
>  18 files changed, 45 insertions(+), 46 deletions(-)


--=-ckUn9AFZsnGNoWsnxDog
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlxIm5oACgkQ5W/vlVpL
7c6nHA/+I5AUD+yELZtkueGqZrZ0E/i+TX7+2pxKNRieTprDcNtILryQEfP4XrvX
r7X4QwfM9Rfmrlr1WcZrQW2LVn+uuflivdbtCmE0ZX4iBnIhAoeguyZ6+hInlbDY
oN+TzAFm96uYB70bOnyqutGVBKfMkazDXiVtqzbu+7HAMWFnQFFzKX6/o+eL0/Np
1qBQP1okUj2dM/ujfQKLxWQu8IupAI5nDeucqFsscZO1Yh/g9IjOyClDUGSXAyBO
Xr67/lCCAt1/Z0GkqN+HElzbtjokp0xitLFF9MyOkmrHiHKcvD62I4OJ97OXlFuF
YXvwIg6/9NfVhGgh/k8z6xAAB9JDIZ0rb5yezcdu1FqSYVrAyzI4tmD+l3fS7zyr
AnHaQ4tTzsmj0T70bz1wooR2oOnyA2MhVhGUfPXNER24TaApApki5eqydsVPpsMk
3gukrduJogzBL2AVMTp780UAj2WnHYsJhso62fYOPT0huDhAsIWaqcuVi5Fs0o94
b9t84vtQG5NHFEBmaaaVdFhB9+Tw3sOHh+nglVzHm3UZNHcFi+lEgxjtV6cTcm0C
1oIX6J17KkZPxkOf0ENU8Cj/gnvNRF/ZhkDPe0r1bMYnL8w0WxB/rCSPQfWD/F5r
bdTuBQbV5MKBc4evjKtB1mFUYD9WrOMIbPjMo9pkJ0XQuttdthc=
=MB+1
-----END PGP SIGNATURE-----

--=-ckUn9AFZsnGNoWsnxDog--

