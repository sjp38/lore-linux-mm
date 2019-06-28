Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9F16C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 06:17:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C8962070D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 06:17:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C8962070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=units.it
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02E136B0003; Fri, 28 Jun 2019 02:17:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFA408E0003; Fri, 28 Jun 2019 02:17:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC01D8E0002; Fri, 28 Jun 2019 02:17:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 961176B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 02:17:16 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id o9so1217886ljg.11
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 23:17:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from:cc
         :subject:in-reply-to:mime-version:content-id
         :content-transfer-encoding:date:message-id;
        bh=fRytH9Gq+nPrWerGKX8EZeg1z5oEqUgArcOcPWmw9WI=;
        b=brrRpuvxWuX1SnT8QTJ5Kx0e4vaNFLw4bG2cC58WYKyrk8VjEmbkkvLHuzwcBFndxw
         F5CLJnsOujNZXLWfixNw6sqfai4rcdd5iEgBq5jJ5oT8MkvTFHAkTWRAd+FZp5UtBsP3
         cxzQGIxKoqgqOQft1XPNRCRLQ5qZQF6uZ5TCxD9i2qhrt81FM6D4uC728YJH3VRwhVk4
         DdInsru3wet1M+dg09OEPtiz2NHr5Fz6jooOpcIKn2gG9tT5cqyYFz0PfekxQgOYkRNa
         UPWu6rkmf3bDpYmx/TE3f+B1efbBEEQAgqokP6WsbrYc7KTl6CBMCEwixO1apWmiAv+s
         Rz/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
X-Gm-Message-State: APjAAAV+l+ghTACKR1gofLHJjUc7J/U2SWzJHQuYtuA75/av+4XMXmKN
	TBwKuWA3N68HjvL/adtsoiGKOr48Hl8YdCWy3nK1+HIXmFmOiUTCBxCmEwqEDJW7bwdBkEquQZh
	emQiZRy3ovlguRKA5PB8VRqYq7sR7E9q4eFYhXkDrjURc4qrzDUQfmarfl9cXQ6zCkA==
X-Received: by 2002:a2e:95d5:: with SMTP id y21mr4849201ljh.84.1561702636004;
        Thu, 27 Jun 2019 23:17:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh+Ky+DMHWAML5R2/BnxFNI/YwTIrWb/lnKHeCwrjT8+oIzFbKF0+xqA31sT/Bxs8E8S75
X-Received: by 2002:a2e:95d5:: with SMTP id y21mr4849165ljh.84.1561702635225;
        Thu, 27 Jun 2019 23:17:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561702635; cv=none;
        d=google.com; s=arc-20160816;
        b=No6J6YN7DXrmlMXMRsurKgWTSVq1YxWgSNxQTff8vnobmhmdrMLgvdYDlRcSI/PSxO
         myvuIpTy8lCkaypPqKrBZmnmR7sIQSdBav7uwD5wwn3PveL+bkz5z0bui9LkooY3v+t2
         ZbeTa6l8Umf7sRJeyxUpfqpWRsHLS0UCfyTHvRYcoyuc4hXP2kHC6t8qc3ytYApXk9F/
         GtI9Mqaf87eq+5R8/pNNL263oBfY+ZLzITWPnNHPGGD0Y2/ePca4D/vcspEH6F71FkWx
         V9SOLzBdYEZ2x+duy+kB7d5da74FEg3b+SHoYLLr9dNGPlWdKjUWTlqMuuuNRBcXqXJ0
         4+og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-transfer-encoding:content-id:mime-version
         :in-reply-to:subject:cc:from:to;
        bh=fRytH9Gq+nPrWerGKX8EZeg1z5oEqUgArcOcPWmw9WI=;
        b=eguYcGRkqKvr+s02pZfzaWva62IyUckvwyDSj/O71Skfgjy8NSlNl34aLmggh+Ljf3
         fFUaqRsYDjf7R4IVDTOHw2KFpLXI6vlI7edqd+AYntlYaO7xBtoU/qyPfZ11S8m9VCtZ
         CwQb6q0HEE3/W/PJnQ6LPmGXwwRWsqlnHaol3H7zuvqqWQ07oe6dJvcDT6UDJuuBLWbr
         rXlgaBKlgx9m/wutttruWp3RJVLuQXPGLzhBZTX26nPsKEPUrlv7eUIbwQEvdELLDOqj
         GOQG8LQSGDrebayWSwaqWo1A5WTQomRCFBXWvHNoQz+HD5hpyE8TnbidX+GbSziQKUKg
         u5lA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (dschgrazlin2.univ.trieste.it. [140.105.55.81])
        by mx.google.com with ESMTP id u3si1191439lji.232.2019.06.27.23.17.14
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 23:17:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) client-ip=140.105.55.81;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (loopback [127.0.0.1])
	by dschgrazlin2.units.it (8.15.2/8.15.2) with ESMTP id x5S6GldK015323;
	Fri, 28 Jun 2019 08:16:47 +0200
To: bugzilla-daemon@bugzilla.kernel.org
From: balducci@units.it
CC: linux-mm@kvack.org, akpm@linux-foundation.org
Subject: Re: [Bug 203715] BUG: unable to handle kernel NULL pointer dereference under stress (possibly related to https://lkml.org/lkml/2019/5/24/292 ?)
In-reply-to: Your message of "Tue, 25 Jun 2019 12:13:52 -0000."
             <bug-203715-9581-Ws6dSkF6YF@https.bugzilla.kernel.org/>
X-Mailer: MH-E 8.6+git; nmh 1.7.1; GNU Emacs 26.2.90
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <15321.1561702631.1@dschgrazlin2.units.it>
Content-Transfer-Encoding: quoted-printable
Date: Fri, 28 Jun 2019 08:16:47 +0200
Message-ID: <15322.1561702631@dschgrazlin2.units.it>
X-Greylist: inspected by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Fri, 28 Jun 2019 08:16:47 +0200 (CEST) for IP:'127.0.0.1' DOMAIN:'loopback' HELO:'dschgrazlin2.units.it' FROM:'balducci@units.it' RCPT:''
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Fri, 28 Jun 2019 08:16:47 +0200 (CEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002502, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> That's fine. Thanks for doing the preliminary test and either report a p=
roble
> m
> or close the bug whenever you feel it's appropriate.

OK: I've performed a number of tests and all passed fine, so I close
this

the problem seems to be solved, AFAICS, at least since 5.1.14 (I have
run the tests with both 5.1.14 and 5.1.15)

thanks again for your valuable help and work

ciao
-g

