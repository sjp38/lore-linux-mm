Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9BD5C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:21:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACB5A206CD
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:21:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="qCRPh/6M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACB5A206CD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0C0E6B0007; Thu,  5 Sep 2019 17:21:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBCC36B0008; Thu,  5 Sep 2019 17:21:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAA186B000A; Thu,  5 Sep 2019 17:21:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0E96B0007
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:21:19 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3A0E1824CA21
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:21:19 +0000 (UTC)
X-FDA: 75902137878.28.death60_45a6028e4fe22
X-HE-Tag: death60_45a6028e4fe22
X-Filterd-Recvd-Size: 24452
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:21:18 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id f10so3653583qkg.7
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:21:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=iz/+WrVQMB5Kzvy/w/GF/1l/wYCYrpC8ad5SF1zVApQ=;
        b=qCRPh/6Mb+QUKWQ6OMtKqvlkFvK3sJrAphCUM54Ez9dOOcfXbKhgEdlrQnTJTO7CbO
         FgMRhh+wXz0D1aK9cRWzwwHEpYHs1FB5tBD1KaLv5Yv7KNfYl+QO30SF/UaIfmqgtwBk
         +xaYOdToEh1d430DORMgy55UGezSxIudLIBMqHeJrn+YpNw9V/sZBXpvPnJ969XZ015K
         Mlk1A61BXPXRIdJ/XQ6OrZ1HJ1EigOMqgcZvNq4TQyO4kkrr8iUShs42HymKc3YhS/t/
         QHX7BkzRhpXSD7DeWdHFg4dwTACKT7zsGJokkU4FDZ/Ffq/GI5V53Xcun4t6YwxHarxn
         N2Sg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=iz/+WrVQMB5Kzvy/w/GF/1l/wYCYrpC8ad5SF1zVApQ=;
        b=SY9NI4Sy1+gu0vTW1KJIujOw5sxVu50ViSeIf/fkm+FcCZIuLD4soWy3HytJPTSPqB
         zMwtyDibxlN4vSJABMDhUg8Hn9mJLXQE+GmgguRk9/YyV4pkOnJpYK0jxluHN5u9gtXr
         m09LvUo+AFozSDGevxb3NL7JVnwmy6+AmYPf5WEiX1wZVGry7eUgWrsC4duBFuRnjHjl
         JBNL5KP6DoJC+cC6RPBhMqHDMJX2Zk6AuD4f3x9iusze4Kk0yJGJYtYoHoECvaMXqTxc
         9h90WMLPUOs58O/9bt5wOdW2CFMem4m2jqmy5DNB2NpkjFHTPPVkThfkWDucppK9UX+J
         RRDA==
X-Gm-Message-State: APjAAAVGcsm6SUV0yqUPkETZWa7aXLCEpoMMJLfvkgzVTBKiixGOmzmW
	DfXXHO4qF09J4GoDNf6oaQT/ZFrMm/w=
X-Google-Smtp-Source: APXvYqyJJHPxyRNNKsMGGluU/z3UQl7Y15j4e3vsydphGjSYIrgjMs0m2HjYQ8VWtYvtcjl/l8ov6g==
X-Received: by 2002:a37:4b02:: with SMTP id y2mr5379761qka.493.1567718477567;
        Thu, 05 Sep 2019 14:21:17 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id e17sm1863906qkn.61.2019.09.05.14.21.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Sep 2019 14:21:16 -0700 (PDT)
Message-ID: <1567718475.5576.108.camel@lca.pw>
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
From: Qian Cai <cai@lca.pw>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org
Date: Thu, 05 Sep 2019 17:21:15 -0400
In-Reply-To: <8ea5da51-a1ac-4450-17d9-0ea7be346765@i-love.sakura.ne.jp>
References: <20190903144512.9374-1-mhocko@kernel.org>
	 <1567522966.5576.51.camel@lca.pw> <20190903151307.GZ14028@dhcp22.suse.cz>
	 <1567699853.5576.98.camel@lca.pw>
	 <8ea5da51-a1ac-4450-17d9-0ea7be346765@i-love.sakura.ne.jp>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-09-06 at 05:59 +0900, Tetsuo Handa wrote:
> On 2019/09/06 1:10, Qian Cai wrote:
> > On Tue, 2019-09-03 at 17:13 +0200, Michal Hocko wrote:
> > > On Tue 03-09-19 11:02:46, Qian Cai wrote:
> > > > Well, I still see OOM sometimes kills wrong processes like ssh, s=
ystemd
> > > > processes while LTP OOM tests with staight-forward allocation pat=
terns.
> > >=20
> > > Please report those. Most cases I have seen so far just turned out =
to
> > > work as expected and memory hogs just used oom_score_adj or similar=
.
> >=20
> > Here is the one where oom01 should be one to be killed.
>=20
> I assume that there are previous OOM killer events before
>=20
> >=20
> > [92598.855697][ T2588] Swap cache stats: add 105240923, delete 105250=
445, find
> > 42196/101577
>=20
> line. Please be sure to include.

Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 1 hugepages_total=3D=
0
hugepages_free=3D0 hugepages_surp=3D0 hugepages_size=3D1048576kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 1 hugepages_total=3D=
0
hugepages_free=3D0 hugepages_surp=3D0 hugepages_size=3D2048kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 104 total pagecache pag=
es
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 72 pages in swap cache
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Swap cache stats: add 1=
05228915, delete
105238918, find 41766/100491
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Free swap=C2=A0=C2=A0=3D=
 16382644kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Total swap =3D 16465916=
kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 7275091 pages RAM
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 0 pages HighMem/Movable=
Only
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 1315554 pages reserved
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 16384 pages cma reserve=
d
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Tasks state (memory val=
ues in pages):
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: [=C2=A0=C2=A0pid=C2=A0=C2=
=A0]=C2=A0=C2=A0=C2=A0uid=C2=A0=C2=A0tgid total_vm=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0rss
pgtables_bytes swapents oom_score_adj name
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A01662]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A01662=C2=
=A0=C2=A0=C2=A0=C2=A029511=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0290816=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0296=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 sy=
stemd-
journal
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02586]=C2=A0=C2=A0=C2=A0998=C2=A0=C2=A02586=C2=A0=C2=A0=
=C2=A0508086=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A0=
=C2=A0368640=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01838=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 polkitd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02587]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02587=C2=
=A0=C2=A0=C2=A0=C2=A052786=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0421888=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0500=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ss=
sd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02588]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02588=C2=
=A0=C2=A0=C2=A0=C2=A031223=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0139264=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0207=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
irqbalance
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02589]=C2=A0=C2=A0=C2=A0=C2=A081=C2=A0=C2=A02589=C2=A0=C2=
=A0=C2=A0=C2=A018381=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=
=C2=A0=C2=A0167936=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0217=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-900 dbus-
daemon
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02590]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02590=C2=
=A0=C2=A0=C2=A0=C2=A097260=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0372736=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0621=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
NetworkManager
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02594]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02594=C2=
=A0=C2=A0=C2=A0=C2=A095350=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
1=C2=A0=C2=A0=C2=A0229376=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0758=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 rn=
gd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02598]=C2=A0=C2=A0=C2=A0995=C2=A0=C2=A02598=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A07364=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=
=A0=C2=A0=C2=A0=C2=A094208=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0102=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ch=
ronyd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02629]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02629=C2=
=A0=C2=A0=C2=A0106234=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=
=A0=C2=A0=C2=A0442368=C2=A0=C2=A0=C2=A0=C2=A0=C2=A03959=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 tuned
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02638]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02638=C2=
=A0=C2=A0=C2=A0=C2=A023604=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0212992=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0240=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-1000 sshd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02642]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02642=C2=
=A0=C2=A0=C2=A0=C2=A010392=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0102400=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0138=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
rhsmcertd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02691]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02691=C2=
=A0=C2=A0=C2=A0=C2=A021877=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0208896=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0277=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 sy=
stemd-
logind
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02700]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02700=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A03916=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00=C2=A0=C2=A0=C2=A0=C2=A069632=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A045=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A00 agetty
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02705]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02705=C2=
=A0=C2=A0=C2=A0=C2=A023370=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0225280=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0393=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 sy=
stemd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02730]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02730=C2=
=A0=C2=A0=C2=A0=C2=A037063=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0294912=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0667=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 (s=
d-pam)
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02922]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02922=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A09020=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00=C2=A0=C2=A0=C2=A0=C2=A098304=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02=
32=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00 crond
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A03036]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A03036=C2=
=A0=C2=A0=C2=A0=C2=A037797=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
1=C2=A0=C2=A0=C2=A0307200=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0305=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ss=
hd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A03057]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A03057=C2=
=A0=C2=A0=C2=A0=C2=A037797=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0303104=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0335=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ss=
hd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A03065]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A03065=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A06343=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A01=C2=A0=C2=A0=C2=A0=C2=A086016=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01=
63=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00 bash
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: [=C2=A0=C2=A038249]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
38249=C2=A0=C2=A0=C2=A0=C2=A058330=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A00=C2=A0=C2=A0=C2=A0221184=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0293=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A00 rsyslogd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: [=C2=A0=C2=A011329]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
11329=C2=A0=C2=A0=C2=A0=C2=A055131=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A00=C2=A0=C2=A0=C2=A0454656=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0427=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A00 sssd_nss
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: [=C2=A0=C2=A011331]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
11331=C2=A0=C2=A0=C2=A0=C2=A054424=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A00=C2=A0=C2=A0=C2=A0434176=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0637=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A00 sssd_be
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: [=C2=A0=C2=A025247]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
25247=C2=A0=C2=A0=C2=A0=C2=A025746=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A01=C2=A0=C2=A0=C2=A0212992=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0300=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-1000 systemd-udevd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: [=C2=A0=C2=A025391]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
25391=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02184=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A00=C2=A0=C2=A0=C2=A0=C2=A065536=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A032=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A00 oom01

25392=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02184=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A00=C2=A0=C2=A0=C2=A0=C2=A065536=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A039=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A00 oom01
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: [=C2=A0=C2=A025507]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00 25507=C2=A0=C2=A01581195=C2=A0=C2=A01411594
11395072=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A048=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 oom01
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: oom-
kill:constraint=3DCONSTRAINT_NONE,nodemask=3D(null),cpuset=3D/,mems_allow=
ed=3D0-
1,global_oom,task_memcg=3D/user.slice,task=3Doom01,pid=3D25507,uid=3D0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Out of memory: Killed p=
rocess 25507
(oom01) total-vm:6324780kB, anon-rss:5647168kB, file-rss:0kB, shmem-rss:0=
kB,
UID:0 pgtables:11395072kB oom_score_adj:0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: oom_reaper: reaped proc=
ess 25507
(oom01), now anon-rss:5647452kB, file-rss:0kB, shmem-rss:0kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: irqbalance invoked oom-=
killer:
gfp_mask=3D0x100cca(GFP_HIGHUSER_MOVABLE), order=3D0, oom_score_adj=3D0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: CPU: 40 PID: 2588 Comm:=
 irqbalance Not
tainted 5.3.0-rc7-next-20190904+ #5
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Hardware name: HP ProLi=
ant XL420
Gen9/ProLiant XL420 Gen9, BIOS U19 12/27/2015
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Call Trace:
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: dump_stack+0x62/0x9a
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: dump_header+0xf4/0x610
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? ___ratelimit+0x4a/0x1=
a0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? find_lock_task_mm+0x1=
10/0x110
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? ___ratelimit+0xfa/0x1=
a0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: oom_kill_process+0x136/=
0x1b0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: out_of_memory+0x1fb/0x9=
60
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? oom_killer_disable+0x=
230/0x230
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? mutex_trylock+0x17d/0=
x1a0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: __alloc_pages_nodemask+=
0x1475/0x1bb0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? gfp_pfmemalloc_allowe=
d+0xc0/0xc0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? __swp_swapcount+0xbf/=
0x160
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? rwlock_bug.part.0+0x6=
0/0x60
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? __swp_swapcount+0x14a=
/0x160
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? __swp_swapcount+0x109=
/0x160
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: alloc_pages_vma+0x18f/0=
x200
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: __read_swap_cache_async=
+0x3ba/0x790
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? lookup_swap_cache+0x3=
c0/0x3c0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: read_swap_cache_async+0=
x69/0xd0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? __read_swap_cache_asy=
nc+0x790/0x790
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? si_swapinfo+0xc0/0x15=
0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: swap_cluster_readahead+=
0x2a4/0x640
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? read_swap_cache_async=
+0xd0/0xd0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? __kasan_check_read+0x=
11/0x20
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? check_chain_key+0x1df=
/0x2e0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? lookup_swap_cache+0xd=
3/0x3c0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: swapin_readahead+0xb9/0=
x83a
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? exit_swap_address_spa=
ce+0x160/0x160
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? lookup_swap_cache+0x1=
24/0x3c0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? swp_swap_info+0x8e/0x=
e0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? swapcache_prepare+0x2=
0/0x20
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: do_swap_page+0x64e/0x14=
10
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? lock_downgrade+0x390/=
0x390
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? unmap_mapping_range+0=
x30/0x30
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: __handle_mm_fault+0xe0c=
/0x1a50
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? vmf_insert_mixed_mkwr=
ite+0x20/0x20
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? __kasan_check_read+0x=
11/0x20
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: ? __count_memcg_events+=
0x56/0x1d0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: handle_mm_fault+0x17f/0=
x37e
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: __do_page_fault+0x369/0=
x630
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: do_page_fault+0x50/0x2d=
3
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: page_fault+0x2f/0x40
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: RIP: 0033:0x7f89fb1a4b1=
4
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Code: Bad RIP value.
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: RSP: 002b:00007ffcf7a88=
148 EFLAGS:
00010206
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: RAX: 0000000000000000 R=
BX:
0000556844dd5db0 RCX: 00007f89fa4bf211
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: RDX: 00000000000026f3 R=
SI:
0000000000000002 RDI: 0000000000000000
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: RBP: 0000000000000002 R=
08:
0000000000000000 R09: 0000556844dc37e0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: R10: 0000556844dc4f20 R=
11:
0000000000000000 R12: 0000556844d9c720
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: R13: 0000000000000000 R=
14:
00000000000026f3 R15: 0000000000000002
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Mem-Info:
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: active_anon:112189 inac=
tive_anon:307421
isolated_anon:0#012 active_file:0 inactive_file:1797 isolated_file:0#012
unevictable:984241 dirty:0 writeback:511 unstable:0#012 slab_reclaimable:=
14317
slab_unreclaimable:498931#012 mapped:27 shmem:0 pagetables:4114 bounce:0#=
012
free:36874 free_pcp:549 free_cma:0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 0 active_anon:2328=
kB
inactive_anon:434856kB active_file:0kB inactive_file:20kB unevictable:414=
264kB
isolated(anon):0kB isolated(file):0kB mapped:20kB dirty:0kB writeback:0kB
shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp=
:0kB
unstable:0kB all_unreclaimable? yes
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 1 active_anon:4488=
04kB
inactive_anon:1107116kB active_file:40kB inactive_file:8440kB
unevictable:3200440kB isolated(anon):0kB isolated(file):0kB mapped:2076kB
dirty:0kB writeback:2304kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 2353152kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 0 DMA free:15864kB=
 min:12kB
low:24kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:15948kB
managed:15864kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB
free_pcp:0kB local_pcp:0kB free_cma:0kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: lowmem_reserve[]: 0 127=
3 7711 7711 7711
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 0 DMA32 free:26876=
kB min:1064kB
low:2368kB high:3672kB active_anon:0kB inactive_anon:246988kB active_file=
:4kB
inactive_file:4kB unevictable:172kB writepending:0kB present:1821440kB
managed:1304560kB mlocked:184kB kernel_stack:288kB pagetables:480kB bounc=
e:0kB
free_pcp:28kB local_pcp:0kB free_cma:0kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: lowmem_reserve[]: 0 0 6=
437 6437 6437
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 0 Normal free:5792=
kB min:5392kB
low:11980kB high:18568kB active_anon:2572kB inactive_anon:601564kB
active_file:0kB inactive_file:4kB unevictable:244kB writepending:0kB
present:10485760kB managed:6591660kB mlocked:4kB kernel_stack:7616kB
pagetables:3304kB bounce:0kB free_pcp:292kB local_pcp:0kB free_cma:0kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: lowmem_reserve[]: 0 0 0=
 0 0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 1 Normal free:9449=
2kB min:13024kB
low:28948kB high:44872kB active_anon:450828kB inactive_anon:4304996kB
active_file:52kB inactive_file:10544kB unevictable:268kB writepending:12k=
B
present:16777216kB managed:15926064kB mlocked:60kB kernel_stack:7744kB
pagetables:12672kB bounce:0kB free_pcp:6376kB local_pcp:0kB free_cma:0kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: lowmem_reserve[]: 0 0 0=
 0 0
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 0 DMA: 0*4kB 1*8kB=
 (U) 1*16kB (U)
1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048=
kB (M)
3*4096kB (M) =3D 15864kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 0 DMA32: 13*4kB (U=
) 17*8kB (U)
584*16kB (UMEH) 202*32kB (UMEH) 96*64kB (UMEH) 21*128kB (UMEH) 4*256kB (U=
M)
0*512kB 1*1024kB (H) 0*2048kB 0*4096kB =3D 26876kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 0 Normal: 0*4kB 0*=
8kB 18*16kB (UME)
176*32kB (UM) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D=
 5920kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 1 Normal: 0*4kB 0*=
8kB 10*16kB
(UMEH) 10*32kB (MH) 7*64kB (UMEH) 600*128kB (M) 2082*256kB (UM) 0*512kB 0=
*1024kB
0*2048kB 0*4096kB =3D 610720kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 0 hugepages_total=3D=
0
hugepages_free=3D0 hugepages_surp=3D0 hugepages_size=3D1048576kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 0 hugepages_total=3D=
0
hugepages_free=3D0 hugepages_surp=3D0 hugepages_size=3D2048kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 1 hugepages_total=3D=
0
hugepages_free=3D0 hugepages_surp=3D0 hugepages_size=3D1048576kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Node 1 hugepages_total=3D=
0
hugepages_free=3D0 hugepages_surp=3D0 hugepages_size=3D2048kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 3936 total pagecache pa=
ges
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 541 pages in swap cache
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Swap cache stats: add 1=
05240923, delete
105250445, find 42196/101577
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Free swap=C2=A0=C2=A0=3D=
 16383612kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Total swap =3D 16465916=
kB
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 7275091 pages RAM
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 0 pages HighMem/Movable=
Only
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 1315554 pages reserved
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: 16384 pages cma reserve=
d
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: Tasks state (memory val=
ues in pages):
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel: [=C2=A0=C2=A0pid=C2=A0=C2=
=A0]=C2=A0=C2=A0=C2=A0uid=C2=A0=C2=A0tgid total_vm=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0rss
pgtables_bytes swapents oom_score_adj name
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A01662]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A01662=C2=
=A0=C2=A0=C2=A0=C2=A029511=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01034=C2=A0=C2=A0=C2=
=A0290816=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0244=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 systemd-
journal
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02586]=C2=A0=C2=A0=C2=A0998=C2=A0=C2=A02586=C2=A0=C2=A0=
=C2=A0508086=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A0=
=C2=A0368640=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01838=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 polkitd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02587]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02587=C2=
=A0=C2=A0=C2=A0=C2=A052786=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0421888=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0500=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ss=
sd
Sep=C2=A0=C2=A05 12:00:52 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02588]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02588=C2=
=A0=C2=A0=C2=A0=C2=A031223=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0139264=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0195=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
irqbalance
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02589]=C2=A0=C2=A0=C2=A0=C2=A081=C2=A0=C2=A02589=C2=A0=C2=
=A0=C2=A0=C2=A018381=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=
=C2=A0=C2=A0167936=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0217=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-900 dbus-
daemon
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02590]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02590=C2=
=A0=C2=A0=C2=A0=C2=A097260=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0193=C2=A0=C2=
=A0=C2=A0372736=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0573=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
NetworkManager
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02594]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02594=C2=
=A0=C2=A0=C2=A0=C2=A095350=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
1=C2=A0=C2=A0=C2=A0229376=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0758=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 rn=
gd
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02598]=C2=A0=C2=A0=C2=A0995=C2=A0=C2=A02598=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A07364=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=
=A0=C2=A0=C2=A0=C2=A094208=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0103=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ch=
ronyd
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02629]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02629=C2=
=A0=C2=A0=C2=A0106234=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0399=C2=A0=C2=A0=C2=
=A0442368=C2=A0=C2=A0=C2=A0=C2=A0=C2=A03836=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 tuned
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02638]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02638=C2=
=A0=C2=A0=C2=A0=C2=A023604=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0212992=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0240=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-1000 sshd
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02642]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02642=C2=
=A0=C2=A0=C2=A0=C2=A010392=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0102400=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0138=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
rhsmcertd
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02691]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02691=C2=
=A0=C2=A0=C2=A0=C2=A021877=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0208896=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0277=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 sy=
stemd-
logind
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02700]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02700=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A03916=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00=C2=A0=C2=A0=C2=A0=C2=A069632=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A045=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A00 agetty
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02705]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02705=C2=
=A0=C2=A0=C2=A0=C2=A023370=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0225280=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0393=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 sy=
stemd
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02730]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02730=C2=
=A0=C2=A0=C2=A0=C2=A037063=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0294912=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0667=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 (s=
d-pam)
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A02922]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02922=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A09020=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00=C2=A0=C2=A0=C2=A0=C2=A098304=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02=
32=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00 crond
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A03036]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A03036=C2=
=A0=C2=A0=C2=A0=C2=A037797=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
1=C2=A0=C2=A0=C2=A0307200=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0305=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ss=
hd
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A03057]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A03057=C2=
=A0=C2=A0=C2=A0=C2=A037797=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0303104=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0335=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ss=
hd
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel:
[=C2=A0=C2=A0=C2=A03065]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A03065=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A06343=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A01=C2=A0=C2=A0=C2=A0=C2=A086016=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01=
63=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00 bash
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel: [=C2=A0=C2=A038249]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
38249=C2=A0=C2=A0=C2=A0=C2=A058330=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0293=
=C2=A0=C2=A0=C2=A0221184=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0246=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 rsysl=
ogd
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel: [=C2=A0=C2=A011329]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
11329=C2=A0=C2=A0=C2=A0=C2=A055131=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A073=C2=A0=C2=A0=C2=A0454656=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0396=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=
 sssd_nss
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel: [=C2=A0=C2=A011331]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
11331=C2=A0=C2=A0=C2=A0=C2=A054424=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A01=C2=A0=C2=A0=C2=A0434176=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0610=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A00 sssd_be
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel: [=C2=A0=C2=A025247]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
25247=C2=A0=C2=A0=C2=A0=C2=A025746=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A01=C2=A0=C2=A0=C2=A0212992=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0300=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-1000 systemd-udevd
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel: [=C2=A0=C2=A025391]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
25391=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02184=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A00=C2=A0=C2=A0=C2=A0=C2=A065536=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A032=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A00 oom01
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel: [=C2=A0=C2=A025392]=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A00
25392=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02184=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A00=C2=A0=C2=A0=C2=A0=C2=A065536=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A039=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A00 oom01
Sep=C2=A0=C2=A05 12:00:53 hp-xl420gen9-01 kernel: oom-
kill:constraint=3DCONSTRAINT_NONE,nodemask=3D(null),cpuset=3D/,mems_allow=
ed=3D0-
1,global_oom,task_memcg=3D/system.slice/tuned.service,task=3Dtuned,pid=3D=
2629,uid=3D0
Sep=C2=A0=C2=A05 12:00:54 hp-xl420gen9-01 kernel: Out of memory: Killed p=
rocess 2629
(tuned) total-vm:424936kB, anon-rss:328kB, file-rss:1268kB, shmem-rss:0kB=
, UID:0
pgtables:442368kB oom_score_adj:0
Sep=C2=A0=C2=A05 12:00:54 hp-xl420gen9-01 kernel: oom_reaper: reaped proc=
ess 2629 (tuned),
now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
Sep=C2=A0=C2=A05 12:00:54 hp-xl420gen9-01 systemd[1]: tuned.service: Main=
 process exited,
code=3Dkilled, status=3D9/KILL
Sep=C2=A0=C2=A05 12:00:54 hp-xl420gen9-01 systemd[1]: tuned.service: Fail=
ed with result
'signal'.
Sep=C2=A0=C2=A05 12:06:32 hp-xl420gen9-01 kernel: oom01 invoked oom-kille=
r:
gfp_mask=3D0x400dc0(GFP_KERNEL_ACCOUNT|__GFP_ZERO), order=3D0, oom_score_=
adj=3D0
Sep=C2=A0=C2=A05 12:10:06 hp-xl420gen9-01 kernel: CPU: 35 PID: 25560 Comm=
: oom01 Not
tainted 5.3.0-rc7-next-20190904+ #5
Sep=C2=A0=C2=A05 12:10:06 hp-xl420gen9-01 kernel: Hardware name: HP ProLi=
ant XL420
Gen9/ProLiant XL420 Gen9, BIOS U19 12/27/2015

>=20
> Any chance it is https://lkml.org/lkml/2017/7/28/317 ?

I am not sure.

