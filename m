Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30E06C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:42:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA9A620828
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:42:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="G7vIcUpX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA9A620828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E1B16B0271; Thu, 29 Aug 2019 11:42:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 692D56B0272; Thu, 29 Aug 2019 11:42:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A8906B0273; Thu, 29 Aug 2019 11:42:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFD56B0271
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:42:28 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DD0E982437D2
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:42:27 +0000 (UTC)
X-FDA: 75875882334.19.debt72_328d8df074902
X-HE-Tag: debt72_328d8df074902
X-Filterd-Recvd-Size: 7862
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:42:27 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id f13so3268796qkm.9
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 08:42:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=e13R8hnmhpY/divDO7DdtrQUgOCBRjC8fBV+Hlaeks4=;
        b=G7vIcUpXIyfAddMCAAprYrXSRVr0dgeGKNoQQ1RtOFMUKnx5GCLeNtr5LIcP5wf8HT
         xPWrdCkXGG+zbB0D2u+TW/X6oEp7J4d9RrpbdHDgAwZAEvn+ZiKszGcHrjPHrxSXa2bl
         Mz7W+AVtcOEJiy+atquNgK9YFeZe8/aGMjeS6R3TeNkdvwyTPMBmLrmzZyJovpV6dkdZ
         RvaxBDw3oAdFsfLjUcFmRde4E8PYxkTzPuSIewtiGE1qaYptcRsbbPDpz63DT6Ywtsoj
         FWsaFeYn0HmCtivbVG5Tq9NT0tsfCbh7/35+Ur5hspWdtT64ZR6yKZLouX0bbnRBxry0
         1C+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=e13R8hnmhpY/divDO7DdtrQUgOCBRjC8fBV+Hlaeks4=;
        b=GushtVB0QtxZFtVN1Sz1WEoeYPIY1IhDD9MGVI6TxnXQMSUJpLOWvOj0F49gnA3aL+
         VL5RMEu1X4MtF+lWwgbOac3rtX5xnoZr/sq2Gou2/UtWbXlgGy9g3f7S0kXvl79KijLh
         Td3CbkcWNVqbbujj6MtSFjaRKV/9DnC7RzSpt+3P0mWsgGo9cK/XgmfjMkqUyDPcwf3S
         iYj6NO748+RCG9E4rJov7Fly4nnAm1RVON3W+Uc5lTuBhsgp+Y8SMKJPqrw6LdmUkEAV
         LtpvPpIGMNZgrIMRBclWvnsJIPP3tU0juamucHzhxtFdzRwvqL74oM3EtIRsLCLwH40E
         u9cQ==
X-Gm-Message-State: APjAAAU7gt93xfiuBE2plWLA9iR0aN63kpCUtv5wT31T8twPoiF0KHLA
	3Oh2W2BQp7vf5aqOSkQkrjPCvQ==
X-Google-Smtp-Source: APXvYqx1BS4vkCOlpjk4W7mCJhFDZaNa7KO6ITvbKA2fO7/VzGJCEn76C3qEpWPdnZiVFWLB5Um1cw==
X-Received: by 2002:a05:620a:12f0:: with SMTP id f16mr10064503qkl.483.1567093346657;
        Thu, 29 Aug 2019 08:42:26 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id y67sm1405561qkd.40.2019.08.29.08.42.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Aug 2019 08:42:25 -0700 (PDT)
Message-ID: <1567093344.5576.23.camel@lca.pw>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
From: Qian Cai <cai@lca.pw>
To: Edward Chron <echron@arista.com>, Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton
 <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner
 <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Shakeel Butt
 <shakeelb@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Ivan Delalande <colona@arista.com>
Date: Thu, 29 Aug 2019 11:42:24 -0400
In-Reply-To: <CAM3twVSZm69U8Sg+VxQ67DeycHUMC5C3_f2EpND4_LC4UHx7BA@mail.gmail.com>
References: <20190826193638.6638-1-echron@arista.com>
	 <20190827071523.GR7538@dhcp22.suse.cz>
	 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
	 <20190828065955.GB7386@dhcp22.suse.cz>
	 <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
	 <20190829071105.GQ28313@dhcp22.suse.cz>
	 <297cf049-d92e-f13a-1386-403553d86401@i-love.sakura.ne.jp>
	 <20190829115608.GD28313@dhcp22.suse.cz>
	 <CAM3twVSZm69U8Sg+VxQ67DeycHUMC5C3_f2EpND4_LC4UHx7BA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-08-29 at 08:03 -0700, Edward Chron wrote:
> On Thu, Aug 29, 2019 at 4:56 AM Michal Hocko <mhocko@kernel.org> wrote:
> >=20
> > On Thu 29-08-19 19:14:46, Tetsuo Handa wrote:
> > > On 2019/08/29 16:11, Michal Hocko wrote:
> > > > On Wed 28-08-19 12:46:20, Edward Chron wrote:
> > > > > Our belief is if you really think eBPF is the preferred mechani=
sm
> > > > > then move OOM reporting to an eBPF.
> > > >=20
> > > > I've said that all this additional information has to be dynamica=
lly
> > > > extensible rather than a part of the core kernel. Whether eBPF is=
 the
> > > > suitable tool, I do not know. I haven't explored that. There are =
other
> > > > ways to inject code to the kernel. systemtap/kprobes, kernel modu=
les and
> > > > probably others.
> > >=20
> > > As for SystemTap, guru mode (an expert mode which disables protecti=
on
> > > provided
> > > by SystemTap; allowing kernel to crash when something went wrong) c=
ould be
> > > used
> > > for holding spinlock. However, as far as I know, holding mutex (or =
doing
> > > any
> > > operation that might sleep) from such dynamic hooks is not allowed.=
 Also
> > > we will
> > > need to export various symbols in order to allow access from such d=
ynamic
> > > hooks.
> >=20
> > This is the oom path and it should better not use any sleeping locks =
in
> > the first place.
> >=20
> > > I'm not familiar with eBPF, but I guess that eBPF is similar.
> > >=20
> > > But please be aware that, I REPEAT AGAIN, I don't think neither eBP=
F nor
> > > SystemTap will be suitable for dumping OOM information. OOM situati=
on
> > > means
> > > that even single page fault event cannot complete, and temporary me=
mory
> > > allocation for reading from kernel or writing to files cannot compl=
ete.
> >=20
> > And I repeat that no such reporting is going to write to files. This =
is
> > an OOM path afterall.
> >=20
> > > Therefore, we will need to hold all information in kernel memory (w=
ithout
> > > allocating any memory when OOM event happened). Dynamic hooks could=
 hold
> > > a few lines of output, but not all lines we want. The only possible=
 buffer
> > > which is preallocated and large enough would be printk()'s buffer. =
Thus,
> > > I believe that we will have to use printk() in order to dump OOM
> > > information.
> > > At that point,
> >=20
> > Yes, this is what I've had in mind.
> >=20
>=20
> +1: It makes sense to keep the report going to the dmesg to persist.
> That is where it has always gone and there is no reason to change.
> You can have several OOMs back to back and you'd like to retain the out=
put.
> All the information should be kept together in the OOM report.
>=20
> > >=20
> > > =C2=A0 static bool (*oom_handler)(struct oom_control *oc) =3D defau=
lt_oom_killer;
> > >=20
> > > =C2=A0 bool out_of_memory(struct oom_control *oc)
> > > =C2=A0 {
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return =
oom_handler(oc);
> > > =C2=A0 }
> > >=20
> > > and let in-tree kernel modules override current OOM killer would be
> > > the only practical choice (if we refuse adding many knobs).
> >=20
> > Or simply provide a hook with the oom_control to be called to report
> > without replacing the whole oom killer behavior. That is not necessar=
y.
>=20
> For very simple addition, to add a line of output this works.
> It would still be nice to address the fact the existing OOM Report prin=
ts
> all of the user processes or none. It would be nice to add some control
> for that. That's what we did.

Feel like you are going in circles to "sell" without any new information.=
 If you
need to deal with OOM that often, it might also worth working with FB on =
oomd.

https://github.com/facebookincubator/oomd

It is well-known that kernel OOM could be slow and painful to deal with, =
so I
don't buy-in the argument that kernel OOM recover is better/faster than a=
 kdump
reboot.

It is not unusual that when the system is triggering a kernel OOM, it is =
almost
trashed/dead. Although developers are working hard to improve the recover=
y after
OOM, there are still many error-paths that are not going to survive which=
 would
leak memories, introduce undefined behaviors, corrupt memory etc.

