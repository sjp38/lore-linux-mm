Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEF03C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 16:10:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3994020825
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 16:10:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="XHsnwvGJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3994020825
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D952F6B0274; Thu,  5 Sep 2019 12:10:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D45CC6B0275; Thu,  5 Sep 2019 12:10:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C34A86B0276; Thu,  5 Sep 2019 12:10:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0103.hostedemail.com [216.40.44.103])
	by kanga.kvack.org (Postfix) with ESMTP id 937096B0274
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 12:10:57 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 35F30181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:10:57 +0000 (UTC)
X-FDA: 75901355754.12.fire84_7ca7d2b2dee60
X-HE-Tag: fire84_7ca7d2b2dee60
X-Filterd-Recvd-Size: 9215
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:10:56 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id 4so2644873qki.6
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 09:10:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=MJcWwYRIZlVdMWckmfT4XUshiFQ6YOOkK12+Ir5VBak=;
        b=XHsnwvGJdFEAxB2ECjFSz96hU8P06SMz68POkJKj0e6iHfHunTLJ6ffq/FhD3ML1Rz
         Rfm3hSpNvEnqZ4mopDrqHwLEksHCA6LnyWnkoOxzeb6liZy6d52bV6EE5drZLK8slGHp
         QAmfVdB2ve89Yv+V2dUqWa88NC9gKPH6zhW/UlW5C5atM0sYnfvzjNkPTVos4bZkxZCd
         oViIM9DGJyLxz9cOWJU2UM3h81vKajHisRr8UOtClVmcxgOUm5OtF1L/MJdXosjIGw0f
         ogytLrIdzYPk8KZAnY+EkXHfPC1zFhREK/qs+PP0U/6AT5ZmbMHYdT0RnwMRSd7poaF6
         A6lQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=MJcWwYRIZlVdMWckmfT4XUshiFQ6YOOkK12+Ir5VBak=;
        b=OiIywrFU5Zd9znLpt4W1y1VwsGAvJVRCudmOkQiA+hIspg5oIQwGs10eeDRjVH0sf/
         K4akuMgVhnPoHhL1vmAXX3hxcUhuYNNHaMMBLrShirpvVEMtRlc3qUdeKackwKGFFAZh
         1tfuZIOV+M+QmQBby8PiEQHUpfFSU+62XFfkTTlylFqUS715s9qzzJQ3iqor7J3Yw2h2
         FBdQU7UL5kiUjJuPq2+o2f3ZIn4HAUv2fEJXoWKjBzDCp7GCQQ3S1ESv8OcCfFdty/Af
         mFyddSF61vJKcqCWe6R9NkunZC/bZfflDj8946YsDDiu75UfuHxhlG8n8fvNEU9qj29U
         6aAQ==
X-Gm-Message-State: APjAAAW+ZhwQb7geFtikgd/2R21K0YQAylb0IJ6hE/0Hl0hMab3ikh++
	J3bWeT8dJ/poELpRkE3jPIYV6w==
X-Google-Smtp-Source: APXvYqyXRTABc9mFwjZ3y6ApYMKWe3oG7+ROIYzo5aOQc0yODJboxwxAwsPhdcdKS5r59olUBt382g==
X-Received: by 2002:a37:9cd6:: with SMTP id f205mr3722320qke.500.1567699855894;
        Thu, 05 Sep 2019 09:10:55 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id u28sm1748493qtu.22.2019.09.05.09.10.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Sep 2019 09:10:55 -0700 (PDT)
Message-ID: <1567699853.5576.98.camel@lca.pw>
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo
 Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes
 <rientjes@google.com>,  LKML <linux-kernel@vger.kernel.org>
Date: Thu, 05 Sep 2019 12:10:53 -0400
In-Reply-To: <20190903151307.GZ14028@dhcp22.suse.cz>
References: <20190903144512.9374-1-mhocko@kernel.org>
	 <1567522966.5576.51.camel@lca.pw> <20190903151307.GZ14028@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-09-03 at 17:13 +0200, Michal Hocko wrote:
> On Tue 03-09-19 11:02:46, Qian Cai wrote:
> > On Tue, 2019-09-03 at 16:45 +0200, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > >=20
> > > dump_tasks has been introduced by quite some time ago fef1bdd68c81
> > > ("oom: add sysctl to enable task memory dump"). It's primary purpos=
e is
> > > to help analyse oom victim selection decision. This has been certai=
nly
> > > useful at times when the heuristic to chose a victim was much more
> > > volatile. Since a63d83f427fb ("oom: badness heuristic rewrite")
> > > situation became much more stable (mostly because the only selectio=
n
> > > criterion is the memory usage) and reports about a wrong process to
> > > be shot down have become effectively non-existent.
> >=20
> > Well, I still see OOM sometimes kills wrong processes like ssh, syste=
md
> > processes while LTP OOM tests with staight-forward allocation pattern=
s.
>=20
> Please report those. Most cases I have seen so far just turned out to
> work as expected and memory hogs just used oom_score_adj or similar.

Here is the one where oom01 should be one to be killed.

[92598.855697][ T2588] Swap cache stats: add 105240923, delete 105250445,=
 find
42196/101577
[92598.893970][ T2588] Free swap=C2=A0=C2=A0=3D 16383612kB
[92598.913482][ T2588] Total swap =3D 16465916kB
[92598.932938][ T2588] 7275091 pages RAM
[92598.950212][ T2588] 0 pages HighMem/MovableOnly
[92598.971539][ T2588] 1315554 pages reserved
[92598.990698][ T2588] 16384 pages cma reserved
[92599.010760][ T2588] Tasks state (memory values in pages):
[92599.036265][ T2588] [=C2=A0=C2=A0pid=C2=A0=C2=A0]=C2=A0=C2=A0=C2=A0uid=
=C2=A0=C2=A0tgid total_vm=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0rss pgtables=
_bytes
swapents oom_score_adj name
[92599.080129][ T2588]
[=C2=A0=C2=A0=C2=A01662]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A01662=C2=
=A0=C2=A0=C2=A0=C2=A029511=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01034=C2=A0=C2=A0=C2=
=A0290816=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0244=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 systemd-
journal
[92599.126163][ T2588]
[=C2=A0=C2=A0=C2=A02586]=C2=A0=C2=A0=C2=A0998=C2=A0=C2=A02586=C2=A0=C2=A0=
=C2=A0508086=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A0=
=C2=A0368640=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01838=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 polkitd
[92599.168706][ T2588]
[=C2=A0=C2=A0=C2=A02587]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02587=C2=
=A0=C2=A0=C2=A0=C2=A052786=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0421888=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0500=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ss=
sd
[92599.210082][ T2588]
[=C2=A0=C2=A0=C2=A02588]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02588=C2=
=A0=C2=A0=C2=A0=C2=A031223=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0139264=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0195=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
irqbalance
[92599.255606][ T2588]
[=C2=A0=C2=A0=C2=A02589]=C2=A0=C2=A0=C2=A0=C2=A081=C2=A0=C2=A02589=C2=A0=C2=
=A0=C2=A0=C2=A018381=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=
=C2=A0=C2=A0167936=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0217=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-900 dbus-
daemon
[92599.303678][ T2588]
[=C2=A0=C2=A0=C2=A02590]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02590=C2=
=A0=C2=A0=C2=A0=C2=A097260=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0193=C2=A0=C2=
=A0=C2=A0372736=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0573=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
NetworkManager
[92599.348957][ T2588]
[=C2=A0=C2=A0=C2=A02594]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02594=C2=
=A0=C2=A0=C2=A0=C2=A095350=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
1=C2=A0=C2=A0=C2=A0229376=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0758=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 rn=
gd
[92599.390216][ T2588]
[=C2=A0=C2=A0=C2=A02598]=C2=A0=C2=A0=C2=A0995=C2=A0=C2=A02598=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A07364=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=
=A0=C2=A0=C2=A0=C2=A094208=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0103=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ch=
ronyd
[92599.432447][ T2588]
[=C2=A0=C2=A0=C2=A02629]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02629=C2=
=A0=C2=A0=C2=A0106234=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0399=C2=A0=C2=A0=C2=
=A0442368=C2=A0=C2=A0=C2=A0=C2=A0=C2=A03836=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 tuned
[92599.473950][ T2588]
[=C2=A0=C2=A0=C2=A02638]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02638=C2=
=A0=C2=A0=C2=A0=C2=A023604=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0212992=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0240=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-1000 sshd
[92599.515158][ T2588]
[=C2=A0=C2=A0=C2=A02642]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02642=C2=
=A0=C2=A0=C2=A0=C2=A010392=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0102400=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0138=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
rhsmcertd
[92599.560435][ T2588]
[=C2=A0=C2=A0=C2=A02691]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02691=C2=
=A0=C2=A0=C2=A0=C2=A021877=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0208896=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0277=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 sy=
stemd-
logind
[92599.605035][ T2588]
[=C2=A0=C2=A0=C2=A02700]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02700=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A03916=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00=C2=A0=C2=A0=C2=A0=C2=A069632=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A045=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A00 agetty
[92599.646750][ T2588]
[=C2=A0=C2=A0=C2=A02705]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02705=C2=
=A0=C2=A0=C2=A0=C2=A023370=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0225280=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0393=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 sy=
stemd
[92599.688063][ T2588]
[=C2=A0=C2=A0=C2=A02730]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02730=C2=
=A0=C2=A0=C2=A0=C2=A037063=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0294912=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0667=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 (s=
d-pam)
[92599.729028][ T2588]
[=C2=A0=C2=A0=C2=A02922]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A02922=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A09020=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00=C2=A0=C2=A0=C2=A0=C2=A098304=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02=
32=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00 crond
[92599.769130][ T2588]
[=C2=A0=C2=A0=C2=A03036]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A03036=C2=
=A0=C2=A0=C2=A0=C2=A037797=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
1=C2=A0=C2=A0=C2=A0307200=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0305=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ss=
hd
[92599.813768][ T2588]
[=C2=A0=C2=A0=C2=A03057]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A03057=C2=
=A0=C2=A0=C2=A0=C2=A037797=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
0=C2=A0=C2=A0=C2=A0303104=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0335=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 ss=
hd
[92599.853450][ T2588]
[=C2=A0=C2=A0=C2=A03065]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=C2=A0=C2=A03065=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A06343=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A01=C2=A0=C2=A0=C2=A0=C2=A086016=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01=
63=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A00 bash
[92599.892899][ T2588] [=C2=A0=C2=A038249]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
38249=C2=A0=C2=A0=C2=A0=C2=A058330=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0293=
=C2=A0=C2=A0=C2=A0221184=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0246=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 rsysl=
ogd
[92599.934457][ T2588] [=C2=A0=C2=A011329]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
11329=C2=A0=C2=A0=C2=A0=C2=A055131=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A073=C2=A0=C2=A0=C2=A0454656=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0396=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00=
 sssd_nss
[92599.976240][ T2588] [=C2=A0=C2=A011331]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
11331=C2=A0=C2=A0=C2=A0=C2=A054424=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A01=C2=A0=C2=A0=C2=A0434176=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0610=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A00 sssd_be
[92600.017106][ T2588] [=C2=A0=C2=A025247]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
25247=C2=A0=C2=A0=C2=A0=C2=A025746=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A01=C2=A0=C2=A0=C2=A0212992=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0300=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-1000 systemd-udevd
[92600.060539][ T2588] [=C2=A0=C2=A025391]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
25391=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02184=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A00=C2=A0=C2=A0=C2=A0=C2=A065536=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A032=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A00 oom01
[92600.100648][ T2588] [=C2=A0=C2=A025392]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
25392=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02184=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A00=C2=A0=C2=A0=C2=A0=C2=A065536=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A039=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A00 oom01
[92600.143516][ T2588] oom-
kill:constraint=3DCONSTRAINT_NONE,nodemask=3D(null),cpuset=3D/,mems_allow=
ed=3D0-
1,global_oom,task_memcg=3D/system.slice/tuned.service,task=3Dtuned,pid=3D=
2629,uid=3D0
[92600.213724][ T2588] Out of memory: Killed process 2629 (tuned) total-
vm:424936kB, anon-rss:328kB, file-rss:1268kB, shmem-rss:0kB, UID:0
pgtables:442368kB oom_score_adj:0
[92600.297832][=C2=A0=C2=A0T305] oom_reaper: reaped process 2629 (tuned),=
 now anon-
rss:0kB, file-rss:0kB, shmem-rss:0kB


>=20
> > I just
> > have not had a chance to debug them fully. The situation could be wor=
se with
> > more complex allocations like random stress or fuzzy testing.

