Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89944C28CBF
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 08:06:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3564821726
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 08:06:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cvbLWTuI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3564821726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 999116B026F; Mon, 27 May 2019 04:06:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96EA96B0270; Mon, 27 May 2019 04:06:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 883636B0271; Mon, 27 May 2019 04:06:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6AE6B026F
	for <linux-mm@kvack.org>; Mon, 27 May 2019 04:06:23 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 21so11308706pgl.5
        for <linux-mm@kvack.org>; Mon, 27 May 2019 01:06:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=x5rdJRMBeOB+xgTMZzJ1Pck6b2K6E2/69q0AHxR6+/s=;
        b=P2kFecBoBHZmSQI2W1BDHy0J3wy2cEqicqAlwnn6ntKa9XCyQlbplBiAcsv5dyUgXN
         ta1ma5bmUFlmhzP8DKcd7FTrKkWck+iGUos3RqcKTZbbVkJxvn4lE5Ypzpdj+ci/t5ee
         slmLmfbBInzJ+ozAa71AdsGQ46eOrybzpzpiJIE1bpeeOA1shwUkp5C30CD8U5rSp+fb
         rZrb0gDBhRxrqcQpI5ONfagXJ57RXsAWh2UjkIXDm1YheYF44PypDa0rPymvvpnLCPFf
         YnrJNNGoaOnyTIzaIY+ckUTL2Twma6evzZTfl1jg5x0TDgFS9wFBtPBk8C2OFElS2l43
         i2FQ==
X-Gm-Message-State: APjAAAXZ6GA/9892swK5iI80RWR66QHy36dLD2rK3KXuxdk9KxpJe9SH
	cJXR7NVpd4kXGA0FklBvkoYuLEonSXFSXeWQGx5vYdl1iG60i1DlPa7rQaWlBx4E5ZMDSKkXQOb
	QTpbeQ2tJomnzZJA/AyQXpzDQreDWJa01+ffpAFh0kXaZ0DopryLXL85MqMzB9fU=
X-Received: by 2002:a17:902:bb95:: with SMTP id m21mr1476175pls.154.1558944382991;
        Mon, 27 May 2019 01:06:22 -0700 (PDT)
X-Received: by 2002:a17:902:bb95:: with SMTP id m21mr1476077pls.154.1558944382173;
        Mon, 27 May 2019 01:06:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558944382; cv=none;
        d=google.com; s=arc-20160816;
        b=jmOvbGCENmj0XUE8mfqNYXB0YgbEcBUwRWq4t67e528qi7fTlufBWnVBqlml0nEmnI
         dXU8Jnr7u4k0JStS3e5SYHVDPwiK1tMIzINvW2/J9If1h1bWLZ7YITKcKiXBG3rVpIBv
         CTGOEcfbKAnYKFx4QjlNfanvXBUQf5G87gbhhvypimXz1je26AOUr2vWnhpKqsImvSe4
         2RDnNAHiap8ntviwNsPVcMFNiFo8cip0BSgzrbd3Ud0UhVgz3kJHvgDvuOyxifI24+Bg
         tCVPMmA3HhVvjvDAVsRbWKEO+/a5n9DIFX7bW+bCRN9obQR7In8glEq0lCC67VO+Jl8N
         Hz2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=x5rdJRMBeOB+xgTMZzJ1Pck6b2K6E2/69q0AHxR6+/s=;
        b=CD17ei2yzSrO9KLvecVe/3fUwHo2RfqHRWzyHedaCSYrUgNClADzEhzRH86ZckQRu6
         IhKKYa4ZWYKqELxX2TjpYykjhHDbbVRCkouwqG9Dmp/Y3uoxnnzxVFsMxuV9Lu8vu1N2
         z4F/HxfEI12B76kqGv5yOdPBrWAgTGcLYiFaQrJ0/xwdzNt/wXVsbAg8q9Zz9M5Ox9FV
         kHMjD5CEghkWwixU+NJn8EVpYunhvchGEo7WgJAKdY+Q7G/YMswGVXhQE0DJ19WfKNLm
         C9SyYfd6DGn+87A1DYdG65jbSP3r0y1po/1jkrD5OUUfyLmT7FL7yrKQ87+Wpj+8kZkY
         T2Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cvbLWTuI;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w5sor12585230plp.31.2019.05.27.01.06.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 01:06:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cvbLWTuI;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=x5rdJRMBeOB+xgTMZzJ1Pck6b2K6E2/69q0AHxR6+/s=;
        b=cvbLWTuIj7hifCDv34fIGfri4oZBxJy6aL2CNzKe9tHh3AdUqxPlw9JHMr/RmmAbCm
         LiNyDtBh3sTAw8Opw8Dx5pYuC0tS/9slXVrl7zo3Tp/pJ2eFCWw6asLPAZ2OVULhhbSl
         FxeJGvfma2snz5OPNYj625BHHYDG202pR+iBZAj8q0PRJFWHjkraE7F8JXYvd0t5ttCX
         lyi8aeH1gfmE6CwrURLqC4wfadIzFOxtuOBNSE4SZM3w1eVisSh6SJ0Ykh8V09rKDMRh
         8/wPskQB72rTjGRB+Qg59EyvF5PaL7rJcQeSW5LssbD+RkJY/7fXej16ibogoXQPi/F2
         v2Tg==
X-Google-Smtp-Source: APXvYqwGWTw0Hz7UkOv1TdhxRBDpDuc+1RV/rzH0FQlL8BvuDueyqIKjhlzyrClYaMah75xYTqt2OQ==
X-Received: by 2002:a17:902:f212:: with SMTP id gn18mr64846228plb.106.1558944381799;
        Mon, 27 May 2019 01:06:21 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id t15sm10712248pjb.6.2019.05.27.01.06.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 27 May 2019 01:06:19 -0700 (PDT)
Date: Mon, 27 May 2019 17:06:14 +0900
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
Message-ID: <20190527080614.GD6879@google.com>
References: <CAKOZuesjDcD3EM4PS7aO7yTa3KZ=FEzMP63MR0aEph4iW1NCYQ@mail.gmail.com>
 <CAHrFyr6iuoZ-r6e57zp1rz7b=Ee0Vko+syuUKW2an+TkAEz_iA@mail.gmail.com>
 <CAKOZueupb10vmm-bmL0j_b__qsC9ZrzhzHgpGhwPVUrfX0X-Og@mail.gmail.com>
 <20190522145216.jkimuudoxi6pder2@brauner.io>
 <CAKOZueu837QGDAGat-tdA9J1qtKaeuQ5rg0tDyEjyvd_hjVc6g@mail.gmail.com>
 <20190522154823.hu77qbjho5weado5@brauner.io>
 <CAKOZuev97fTvmXhEkjb7_RfDvjki4UoPw+QnVOsSAg0RB8RyMQ@mail.gmail.com>
 <20190522160108.l5i7t4lkfy3tyx3z@brauner.io>
 <CAKOZuevR2WTbeFdvpx8K9jJj0Sc=wpNJKr24ePWsvE_WS5wgNw@mail.gmail.com>
 <20190523130717.GA203306@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523130717.GA203306@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 10:07:17PM +0900, Minchan Kim wrote:
> On Wed, May 22, 2019 at 09:01:33AM -0700, Daniel Colascione wrote:
> > On Wed, May 22, 2019 at 9:01 AM Christian Brauner <christian@brauner.io> wrote:
> > >
> > > On Wed, May 22, 2019 at 08:57:47AM -0700, Daniel Colascione wrote:
> > > > On Wed, May 22, 2019 at 8:48 AM Christian Brauner <christian@brauner.io> wrote:
> > > > >
> > > > > On Wed, May 22, 2019 at 08:17:23AM -0700, Daniel Colascione wrote:
> > > > > > On Wed, May 22, 2019 at 7:52 AM Christian Brauner <christian@brauner.io> wrote:
> > > > > > > I'm not going to go into yet another long argument. I prefer pidfd_*.
> > > > > >
> > > > > > Ok. We're each allowed our opinion.
> > > > > >
> > > > > > > It's tied to the api, transparent for userspace, and disambiguates it
> > > > > > > from process_vm_{read,write}v that both take a pid_t.
> > > > > >
> > > > > > Speaking of process_vm_readv and process_vm_writev: both have a
> > > > > > currently-unused flags argument. Both should grow a flag that tells
> > > > > > them to interpret the pid argument as a pidfd. Or do you support
> > > > > > adding pidfd_vm_readv and pidfd_vm_writev system calls? If not, why
> > > > > > should process_madvise be called pidfd_madvise while process_vm_readv
> > > > > > isn't called pidfd_vm_readv?
> > > > >
> > > > > Actually, you should then do the same with process_madvise() and give it
> > > > > a flag for that too if that's not too crazy.
> > > >
> > > > I don't know what you mean. My gut feeling is that for the sake of
> > > > consistency, process_madvise, process_vm_readv, and process_vm_writev
> > > > should all accept a first argument interpreted as either a numeric PID
> > > > or a pidfd depending on a flag --- ideally the same flag. Is that what
> > > > you have in mind?
> > >
> > > Yes. For the sake of consistency they should probably all default to
> > > interpret as pid and if say PROCESS_{VM_}PIDFD is passed as flag
> > > interpret as pidfd.
> > 
> > Sounds good to me!
> 
> Then, I want to change from pidfd to pid at next revsion and stick to
> process_madvise as naming. Later, you guys could define PROCESS_PIDFD
> flag and change all at once every process_xxx syscall friends.
> 
> If you are faster so that I see PROCESS_PIDFD earlier, I am happy to
> use it.

Hi Folks,

I don't want to consume a new API argument too early so want to say
I will use process_madvise with pidfs argument because I agree with
Daniel that we don't need to export implmentation on the syscall name.

I hope every upcoming new syscall with process has by default pidfs
so people are familiar with pidfd slowly so finallly they forgot pid
in the long run so naturally replace pid with pidfs.

