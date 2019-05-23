Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A2B1C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 13:07:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A820C2133D
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 13:07:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ljJU6suY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A820C2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D2686B0003; Thu, 23 May 2019 09:07:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 484E26B000C; Thu, 23 May 2019 09:07:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 399FE6B000D; Thu, 23 May 2019 09:07:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 028A16B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 09:07:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d36so2858854pla.18
        for <linux-mm@kvack.org>; Thu, 23 May 2019 06:07:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=s9xCy18W59wKBWAvDaH6JYHoJT0+JbJc9ipAphcb2DM=;
        b=h8jbD+MOOU0mbJc64sWN48P50Z6hXZrRFXswe1FleztkP7NhiVCm93wRSl4DdO0Uad
         UupSMpf5KujSuntyjTXK4bCHeX0yVlvQU71/QKpZjdl16A7c6aNm62kuIwcbqByJYqX3
         idB+X9xBQzVNYsxe58b8QWtCC+wsnmBtvRkQ+WSxB9AmxU3N/kmeJKhlQpIIuVoBMAcV
         vuPj7ecLvYYGKBiPTlT2mFu18rDIgP2Tui9p5mJvHf2SICE1z9XwX8WQ7c1tM9ltJ4Ns
         xeMCy9UDmX1dDTSfbfNc+5qwXsIiTzSr7jnu5B4Dw9j6VPs2X7Efa8XIHqSP20JXvDfH
         5Zwg==
X-Gm-Message-State: APjAAAW/2GlFLJwk9pSpe1MiCoYEgMsygtwPYl4AhKnDiRu/e9q+S4Lq
	qA03PCAAcCmCzgxoyuu2gQCh+ekAhPy1Sm9H24dMM0yt7a81NdjdmjTd1XWiLLEN9yI2cE82zv3
	6E8qNWdyBFco9Gzc+oqJRE/v4RFCkzTTYhMj7+9uHIy6qDJ6eaH/Hi0Nv838vx+w=
X-Received: by 2002:a17:902:fa2:: with SMTP id 31mr99676363plz.128.1558616845553;
        Thu, 23 May 2019 06:07:25 -0700 (PDT)
X-Received: by 2002:a17:902:fa2:: with SMTP id 31mr99676243plz.128.1558616844665;
        Thu, 23 May 2019 06:07:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558616844; cv=none;
        d=google.com; s=arc-20160816;
        b=vzlycVrVnp1+ExYyfbsohaf8X1woGnKXl5vq4iWD6RaPGKSQpgInRJMIkclXsIBSPs
         DEHAFRsWj4eI5J1BULNLjbgp46KBKLgeiQU5+jXO2oFuQZmiZGKZB3GNzJ/5ba5OR4I1
         1K4nj+XBo44J+Cju30AnAL1+vLH+xOXsy8fK2NvCJiGvsQnSfckNArC2kOvFHAd02V58
         D51W//8HkADryS5cd4/O6Jer9xt5aSLWYAJPyKL7kdkhGwk+sbCkqobLTMILgjYavapt
         yzUjHvgNKiwRhYjtEZmo8wIp5+fG3poLJoZXe7W03fCP4C9zDGUf+dBiRH2QBpdX0aXe
         OUEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=s9xCy18W59wKBWAvDaH6JYHoJT0+JbJc9ipAphcb2DM=;
        b=bsTPNiDVM1wdN1bkhzSztsKYQeUqc4DJesxCZyKw16uKv31xCyCNSwq0nZhilPvQVt
         DO1cBrmESCi9iGA5/FicJFukREv6MYdp4pCHKcGlzepiOQMEfMd4jk1IBFLnmggUWG3F
         R+VRJXPab2EaA4lHedHBE746EmcQMMDmtNWs3yf4jVZPuLG28m56c/kD3tyB4wNqy8FB
         O5UBAJrXD7A+Sz/hYefJJSSaiLX6PATj6/ZDyWmgPFCB0m4a/uzumgcAMDZHbGBc62er
         CLyQJl3i6N29559izcEpnNtnGowzIgGfXcDkIjx0kWLVd5GCO2DnTSBx7hqcyJCp/oBB
         LYjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ljJU6suY;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor279828pjv.16.2019.05.23.06.07.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 06:07:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ljJU6suY;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=s9xCy18W59wKBWAvDaH6JYHoJT0+JbJc9ipAphcb2DM=;
        b=ljJU6suYXw3oRrTgoSVmjqUkCXi1M6cW8rzJN3n8+YRKzycDEPVDeKYbXn3/mMprqa
         fC16A8wn7VpuAGkN1uBB3G/k9Mjokt5JkLynZHE2vAkh9w/7owa46EWLrkiYt3tPegfL
         MWqz1Ug9XJL48A1GMq21a5uM9NYw3fplKybZZ6lS7T3TPwpM/5nfKV82w0Nbq8dzdyT2
         8Ahz/g2EZLckDjc587U1x5xNYmSxKRr73V8NLM7cngHFhsq1GU1Hou6Q/5IbjyhY8cEn
         ifwbNanA59oiVsd5rYAoHRmp/C3UqusAPv3tPAbERw00p/1IEjtQIkGw96Wng4n34vo+
         jmfQ==
X-Google-Smtp-Source: APXvYqwOrAosXxrN7lYZl1zDX9p1VHy989m4OxZl4V043iIEU+gL/oZsLZGr/sDCZOW1bvXAmmDLhA==
X-Received: by 2002:a17:90a:8e86:: with SMTP id f6mr966074pjo.66.1558616844214;
        Thu, 23 May 2019 06:07:24 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id j72sm654518pje.12.2019.05.23.06.07.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 23 May 2019 06:07:22 -0700 (PDT)
Date: Thu, 23 May 2019 22:07:17 +0900
From: Minchan Kim <minchan@kernel.org>
To: Daniel Colascione <dancol@google.com>
Cc: Christian Brauner <christian@brauner.io>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, Jann Horn <jannh@google.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190523130717.GA203306@google.com>
References: <20190521113911.2rypoh7uniuri2bj@brauner.io>
 <CAKOZuesjDcD3EM4PS7aO7yTa3KZ=FEzMP63MR0aEph4iW1NCYQ@mail.gmail.com>
 <CAHrFyr6iuoZ-r6e57zp1rz7b=Ee0Vko+syuUKW2an+TkAEz_iA@mail.gmail.com>
 <CAKOZueupb10vmm-bmL0j_b__qsC9ZrzhzHgpGhwPVUrfX0X-Og@mail.gmail.com>
 <20190522145216.jkimuudoxi6pder2@brauner.io>
 <CAKOZueu837QGDAGat-tdA9J1qtKaeuQ5rg0tDyEjyvd_hjVc6g@mail.gmail.com>
 <20190522154823.hu77qbjho5weado5@brauner.io>
 <CAKOZuev97fTvmXhEkjb7_RfDvjki4UoPw+QnVOsSAg0RB8RyMQ@mail.gmail.com>
 <20190522160108.l5i7t4lkfy3tyx3z@brauner.io>
 <CAKOZuevR2WTbeFdvpx8K9jJj0Sc=wpNJKr24ePWsvE_WS5wgNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuevR2WTbeFdvpx8K9jJj0Sc=wpNJKr24ePWsvE_WS5wgNw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 09:01:33AM -0700, Daniel Colascione wrote:
> On Wed, May 22, 2019 at 9:01 AM Christian Brauner <christian@brauner.io> wrote:
> >
> > On Wed, May 22, 2019 at 08:57:47AM -0700, Daniel Colascione wrote:
> > > On Wed, May 22, 2019 at 8:48 AM Christian Brauner <christian@brauner.io> wrote:
> > > >
> > > > On Wed, May 22, 2019 at 08:17:23AM -0700, Daniel Colascione wrote:
> > > > > On Wed, May 22, 2019 at 7:52 AM Christian Brauner <christian@brauner.io> wrote:
> > > > > > I'm not going to go into yet another long argument. I prefer pidfd_*.
> > > > >
> > > > > Ok. We're each allowed our opinion.
> > > > >
> > > > > > It's tied to the api, transparent for userspace, and disambiguates it
> > > > > > from process_vm_{read,write}v that both take a pid_t.
> > > > >
> > > > > Speaking of process_vm_readv and process_vm_writev: both have a
> > > > > currently-unused flags argument. Both should grow a flag that tells
> > > > > them to interpret the pid argument as a pidfd. Or do you support
> > > > > adding pidfd_vm_readv and pidfd_vm_writev system calls? If not, why
> > > > > should process_madvise be called pidfd_madvise while process_vm_readv
> > > > > isn't called pidfd_vm_readv?
> > > >
> > > > Actually, you should then do the same with process_madvise() and give it
> > > > a flag for that too if that's not too crazy.
> > >
> > > I don't know what you mean. My gut feeling is that for the sake of
> > > consistency, process_madvise, process_vm_readv, and process_vm_writev
> > > should all accept a first argument interpreted as either a numeric PID
> > > or a pidfd depending on a flag --- ideally the same flag. Is that what
> > > you have in mind?
> >
> > Yes. For the sake of consistency they should probably all default to
> > interpret as pid and if say PROCESS_{VM_}PIDFD is passed as flag
> > interpret as pidfd.
> 
> Sounds good to me!

Then, I want to change from pidfd to pid at next revsion and stick to
process_madvise as naming. Later, you guys could define PROCESS_PIDFD
flag and change all at once every process_xxx syscall friends.

If you are faster so that I see PROCESS_PIDFD earlier, I am happy to
use it.

Thanks.

