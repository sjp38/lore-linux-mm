Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0418C282C0
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 14:47:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81F6F2184A
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 14:47:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81F6F2184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=211mainstreet.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23A828E002D; Wed, 23 Jan 2019 09:47:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EAB18E001A; Wed, 23 Jan 2019 09:47:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1011E8E002D; Wed, 23 Jan 2019 09:47:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA45D8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:47:06 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id u197so2049938qka.8
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:47:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :references:in-reply-to:subject:date:message-id:mime-version
         :content-transfer-encoding:thread-index:content-language;
        bh=y0y4RvL8H+R2dVqHkWA4Zoenaa2QPu6tEhpqvImk4Oc=;
        b=MsTLJxzU3MikSeZ9vt5uGNuZbYXXR4Z2HNIqcVBhqeeAecuM9iBjgXxSYmCsMGbo0T
         Muwg1YShGaIunWUxvOXxozt1BEGm9v57IA7Zhc+iREiofbaFUWIjr87VktngoUUAti7G
         wbq36R+G05LVi0KMb/TMzOSzt8mpR0aOkhP8r9ZVvkc+qULUrLAfah9DUXqc531iU8o+
         7a8jzehtlAqA95lYD4hRzFDatPBWL9y4ifqpr+V2lUC4LYNuSBTCZw8SPxEJiCETC5v0
         bDNMl5SIku7/+TcPr+OvYQAlp9zwdp2x7SAR6zl10qHAxlMPD4tmAlFw7KOB740EvbD7
         VBdw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 216.220.167.73 is neither permitted nor denied by best guess record for domain of edwin@211mainstreet.net) smtp.mailfrom=edwin@211mainstreet.net
X-Gm-Message-State: AJcUukc7FsTdWOuEa2O+P4ef0jJhLUOtOVb6gobJ+6+3PsqYM+8N3qDJ
	YBANy5XnJMvHpGEFa8j/SdtjObx49IMkSrBCkBAqTCmZlAD4U7n4k9+81Oy0I1oAiVLPytbsxoA
	LfpEz/do5KTAZFjwPFDPXTQ7CeS5ikz5+7jakCdA5uevPJ80FceC8yJRACloedhk=
X-Received: by 2002:ac8:326a:: with SMTP id y39mr2598646qta.175.1548254826543;
        Wed, 23 Jan 2019 06:47:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5rMXkalY5qk0BYPkMp+106SNy9GQxGuHfdpMMcI2h2+FI4js1RnVZbCfb4zmRP/1+O0FQs
X-Received: by 2002:ac8:326a:: with SMTP id y39mr2598618qta.175.1548254826115;
        Wed, 23 Jan 2019 06:47:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548254826; cv=none;
        d=google.com; s=arc-20160816;
        b=y3QybLm7VgcjOlutsEvJVwSm7rJFmtijDrx4vA6Id3OLM4a0CDP1gMT7s4gVOWM/VX
         SrlhnjiKUCORuAmlpkiWptydwvl2d9IkopLjwQKq8SyVXpOEW/mdBDilabOxi8K5mt9V
         vnfuoGbUxySY96eS4qNF5240070nyN13hdNsM/HWdcPpCOjnW+iKrShWkOIHpsUHQn16
         mMMMJ1hryv0Q8AxO/SkPheoKp6Bab8P9yZICWJc2Q8xfQ4YfyOtoDvwMfSeGUgoPo7lk
         cEJSYfT0/4Httr1FsKogg6NDlr/yezs10UnER7c+pemIX99owCptr6+znxT5C39m61eo
         XCig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:thread-index:content-transfer-encoding
         :mime-version:message-id:date:subject:in-reply-to:references:cc:to
         :from;
        bh=y0y4RvL8H+R2dVqHkWA4Zoenaa2QPu6tEhpqvImk4Oc=;
        b=qGhONRSJXrmXfC6S6khg2Tjhxlksoh7lPiuBzVOTJtiQIfEo14WZG3P0SU8a6VTMy3
         WX9XQ2jjn+WhXv6DKr0DRcEFVFYSY4NEYWvraNjOWEcshSWeK1RoVjlRsjgJgVvU9x2H
         sqwFK5ukugAzS+hl139Hm7mSz4fniXwNL6pKReaKENINFx9dMXOi1lmvncy66HFpX5PZ
         jscGdNoijAB1pj0eL2xfv8a+9clpAoWWSC01g6OiG3D1R8lxCOJ2yGLnsUFqOowPHqya
         hx+z6LB716dRYTdWjLLbF3Al1URyciSXVgLkh6BhL/zRnxF5SH33h6B8wSz8hHzrZFv4
         WPZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 216.220.167.73 is neither permitted nor denied by best guess record for domain of edwin@211mainstreet.net) smtp.mailfrom=edwin@211mainstreet.net
Received: from mail.emypeople.net (mail.emypeople.net. [216.220.167.73])
        by mx.google.com with ESMTP id u189si5490103qkf.44.2019.01.23.06.47.05
        for <linux-mm@kvack.org>;
        Wed, 23 Jan 2019 06:47:06 -0800 (PST)
Received-SPF: neutral (google.com: 216.220.167.73 is neither permitted nor denied by best guess record for domain of edwin@211mainstreet.net) client-ip=216.220.167.73;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 216.220.167.73 is neither permitted nor denied by best guess record for domain of edwin@211mainstreet.net) smtp.mailfrom=edwin@211mainstreet.net
Received: from Shop7 ([166.182.241.35])
        by mail.emypeople.net (12.1.1 build 4 DEB9 x64) with ASMTP id 201901230947053176;
        Wed, 23 Jan 2019 09:47:05 -0500
From: "Edwin Zimmerman" <edwin@211mainstreet.net>
To: "'Jani Nikula'" <jani.nikula@linux.intel.com>,
	"'Greg KH'" <gregkh@linuxfoundation.org>,
	"'Kees Cook'" <keescook@chromium.org>
Cc: <dev@openvswitch.org>,
	"'Ard Biesheuvel'" <ard.biesheuvel@linaro.org>,
	<netdev@vger.kernel.org>,
	<intel-gfx@lists.freedesktop.org>,
	<linux-usb@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<dri-devel@lists.freedesktop.org>,
	<linux-mm@kvack.org>,
	<linux-security-module@vger.kernel.org>,
	<kernel-hardening@lists.openwall.com>,
	<intel-wired-lan@lists.osuosl.org>,
	<linux-fsdevel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	"'Laura Abbott'" <labbott@redhat.com>,
	<linux-kbuild@vger.kernel.org>,
	"'Alexander Popov'" <alex.popov@linux.com>
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org> <20190123115829.GA31385@kroah.com> <874l9z31c5.fsf@intel.com>
In-Reply-To: <874l9z31c5.fsf@intel.com>
Subject: RE: [Intel-gfx] [PATCH 1/3] treewide: Lift switch variables out of switches
Date: Wed, 23 Jan 2019 09:47:06 -0500
Message-ID: <000001d4b32a$845e06e0$8d1a14a0$@211mainstreet.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Mailer: Microsoft Outlook 15.0
Thread-Index: AQK1qhpX7cEQ8qlEpLW6qt3JZ7VVWQH3EeYfAWqRE0oCq0D606PKlQEg
Content-Language: en-us
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000086, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123144706.kIfrScibv_V1V11umzzFTc1s-9pb2ewAwDe_l43ebUU@z>

On Wed, 23 Jan 2019, Jani Nikula <jani.nikula@linux.intel.com> wrote:
> On Wed, 23 Jan 2019, Greg KH <gregkh@linuxfoundation.org> wrote:
> > On Wed, Jan 23, 2019 at 03:03:47AM -0800, Kees Cook wrote:
> >> Variables declared in a switch statement before any case statements
> >> cannot be initialized, so move all instances out of the switches.
> >> After this, future always-initialized stack variables will work
> >> and not throw warnings like this:
> >>
> >> fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
> >> fs/fcntl.c:738:13: warning: statement will never be executed =
[-Wswitch-unreachable]
> >>    siginfo_t si;
> >>              ^~
> >
> > That's a pain, so this means we can't have any new variables in { }
> > scope except for at the top of a function?
> >
> > That's going to be a hard thing to keep from happening over time, as
> > this is valid C :(
>=20
> Not all valid C is meant to be used! ;)

Very true.  The other thing to keep in mind is the burden of enforcing a =
prohibition on a valid C construct like this. =20
It seems to me that patch reviewers and maintainers have enough to do =
without forcing them to watch for variable
declarations in switch statements.  Automating this prohibition, should =
it be accepted, seems like a good idea to me.

-Edwin Zimmerman

