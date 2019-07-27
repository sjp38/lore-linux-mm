Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0FB5C433FF
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 11:48:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6537C2082E
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 11:48:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="fCjKeF9+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6537C2082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FFD28E0003; Sat, 27 Jul 2019 07:48:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B19E8E0002; Sat, 27 Jul 2019 07:48:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79F6B8E0003; Sat, 27 Jul 2019 07:48:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 590C28E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 07:48:14 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x17so47441355qkf.14
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 04:48:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=3QcusByxnBLEAwsrMGgC+4eQjoFDrnykdiClscYz6rg=;
        b=KdFR/aNHeox1vWHmxyklwmwIBMHKRkT4P67p/c4yA1U2r4xuScCBnphqvrElv6JGK4
         HS/YRy/0izpNevjrsJyfZr9UjFSi2BaiEaq/D/R8L+RLZR8peN3aO9gvmZB3KjnbRWL4
         hn9wGi1u5S7ECVIGgEtmmiRfAyprbtnS4yQMnmh0p3TV5AH1J7/jJbJ9ERJo4BpLE1u7
         LtizGMcZMaQBqO/M5SETcSyiZL6B5GA+A4vMe5UTFx7cFdtWWWj8dVpwVM8DbtURPQOB
         z1aMpk+SUBWTe/q9xIc0OmyfomtIpddS+0jhwFeaH4PXBEbCEg9f9h+zKlpx9zJjRDJ/
         YbFw==
X-Gm-Message-State: APjAAAViht4lkeuKlytIiGJU1lY2xaL8aOAtLSdSzThpI4Mu+ybaiRbs
	rXAb35D8TA9zMKLhpZNacgseovp5VhcIKY9B1WAElZksLNleBLI2YQkdmb9uMhuXAbgk/t6qrnc
	5982ENjBEPUVnULXSNNLUSIQjax41w+FjgTBiR31pG2Gilq/gBI7KQkGfVQghTpsqcQ==
X-Received: by 2002:ac8:738e:: with SMTP id t14mr39117113qtp.386.1564228094001;
        Sat, 27 Jul 2019 04:48:14 -0700 (PDT)
X-Received: by 2002:ac8:738e:: with SMTP id t14mr39117082qtp.386.1564228093398;
        Sat, 27 Jul 2019 04:48:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564228093; cv=none;
        d=google.com; s=arc-20160816;
        b=wqviEFzaxyIbYh6+RU8a6n4fZ9mENv2lJ3t1U8EICZq8PDSSlHwq9IUTVzDx2qB4Gt
         dvr73DCV0/ywfuQSgjmfWvtOOAep3ASizDCP6geE5gqgnORenlmRjQ6sYCovRrSrnopN
         CUN5HiQF5QKt17+ujS0C4/Iz6chISrf1rzzwifqCpd7yOK6Jw0EGDWlQ1Odsdrvg0ibj
         WZVhHPN9O7uItVtPumEqdVthlu6EE1TXdKgkJ6/HHes93R1PfQFhxOVVUN+1fVbaaFya
         YwUBjz8fj7Ou0+kN5NnZjlMqE/r8Gppc718YzLE/7u407DITK5XMpodeugrHKybFuSxn
         8w+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=3QcusByxnBLEAwsrMGgC+4eQjoFDrnykdiClscYz6rg=;
        b=CZB9peDsv9yGUpa1FNs5LdKBFNZ/2HXv66N6gM3MpS5FMvs9VTH2qe2eQAUxisHUjp
         6RsUunUn37FqhJVFvqTG80iNi1d4kRMeRq/C4ojtb6HjL2GHHNboWbwHpXhs0YPQGkJs
         1XsRjk1s4WsfKQz+R4BP7ucG+uKS9OGzXQZRP1idG9rYORHssZQGwnujeZaywnMws3y6
         UeeAQYgOMyaW7PFe/9SGnzYQtKH5iBnZ92S5AgEe/NRFOo0JkYpjrzT1wAFjp6Iz7Rq+
         9rh/9U4U0IJxw4I6zI6oCtN6oVhNWevQ3wt5zQMe1YzgcPJHkgPF2bpxrzaHKwzVfhRl
         74dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=fCjKeF9+;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d22sor73136214qtd.60.2019.07.27.04.48.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 27 Jul 2019 04:48:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=fCjKeF9+;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=3QcusByxnBLEAwsrMGgC+4eQjoFDrnykdiClscYz6rg=;
        b=fCjKeF9+kIWLJsh5NY0adar+npSdusjEbiBOdDLkMLWFNgXvxvOcUbvLse7dGRcQag
         BME+G1RBmmri5esgH8la40Lxb8Z+wUKfryfwU3nPESK9lRIOME80o1IfprMlShFGeOaL
         lM/pAY5AJscBJ3DIIVbal01jAxMmkMP53HyXZgjnxJ9o64Z68JGdb9Dny4Irx93KiVPt
         bY73e8cBLldad9kzE8Z0Px7tw2RH7iOzKRoJ9HzECeV+L+bvN50WC4dHabCB0eFo+Vwr
         mUQsG/tYvDHrGz0LBfoo3S0FsEB0jrzDw7fQ/OO2SkW38PW4brFUDekWsYuwRMTDMPQW
         bCmg==
X-Google-Smtp-Source: APXvYqwhYpOWEJA6y7KtdbabIBqP6vNi7PHVTa6ERXqKtsvLJNqqB0E1lHclFWVXE5cfyitHXd0R0A==
X-Received: by 2002:aed:21f5:: with SMTP id m50mr70103521qtc.66.1564228092972;
        Sat, 27 Jul 2019 04:48:12 -0700 (PDT)
Received: from qians-mbp.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id q32sm23811313qtd.79.2019.07.27.04.48.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Jul 2019 04:48:12 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH] Revert "kmemleak: allow to coexist with fault injection"
From: Qian Cai <cai@lca.pw>
In-Reply-To: <20190727101352.GA14316@arrakis.emea.arm.com>
Date: Sat, 27 Jul 2019 07:48:09 -0400
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
 mhocko@suse.com,
 Dmitry Vyukov <dvyukov@google.com>,
 rientjes@google.com,
 willy@infradead.org,
 Andrew Morton <akpm@linux-foundation.org>,
 linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <00205B2E-36E0-4169-997B-B9A522482CD1@lca.pw>
References: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563301410.4610.8.camel@lca.pw>
 <20190727101352.GA14316@arrakis.emea.arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 27, 2019, at 6:13 AM, Catalin Marinas <catalin.marinas@arm.com> =
wrote:
>=20
> On Tue, Jul 16, 2019 at 02:23:30PM -0400, Qian Cai wrote:
>> As mentioned in anther thread, the situation for kmemleak under =
memory pressure
>> has already been unhealthy. I don't feel comfortable to make it even =
worse by
>> reverting this commit alone. This could potentially make kmemleak =
kill itself
>> easier and miss some more real memory leak later.
>>=20
>> To make it really a short-term solution before the reverting, I think =
someone
>> needs to follow up with the mempool solution with tunable pool size =
mentioned
>> in,
>>=20
>> =
https://lore.kernel.org/linux-mm/20190328145917.GC10283@arrakis.emea.arm.c=
om/
>=20
> Before my little bit of spare time disappears, let's add the tunable =
to
> the mempool size so that I can repost the patch. Are you ok with a
> kernel cmdline parameter or you'd rather change it at runtime? The
> latter implies a minor extension to mempool to allow it to refill on
> demand. I'd personally go for the former.

Agreed. The cmdline is good enough.=

