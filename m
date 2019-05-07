Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D836EC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 20:02:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E2D320449
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 20:02:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eohhKp0u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E2D320449
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D5EC6B0010; Tue,  7 May 2019 16:02:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 185EB6B0266; Tue,  7 May 2019 16:02:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04E086B0269; Tue,  7 May 2019 16:02:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id A49AC6B0010
	for <linux-mm@kvack.org>; Tue,  7 May 2019 16:02:12 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id n9so3651299wrq.12
        for <linux-mm@kvack.org>; Tue, 07 May 2019 13:02:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Gb9u8BwK6K2VHZrF75n3DXs/h9sjtM0WB9yfdMMjAhA=;
        b=TME4dZuBqd105RRssQ0k8LuP061U39PCZKuXjts4BRkEu4lOdUp4ve+olD1KGhzo5q
         JOndtrLKbPVOKojDVAE7+w4y9CaHh/nxCOl9r6uZ5rd5k+50IkHg/gx+Lumi5Ms08i1q
         CJ9dr17N7SIlVU1M1MbDffdB8jyPJmLpm9lkDybrvbl8kZ6INQ2WkeYVNwmDQwiB7p6a
         tbdfhWIoKr7Y1SMVYqJJMxqqay9lI21PiFR7wbfZl6mdEF0TflrnpqkGlCm2z2B30E+y
         LYb+xDd4/Oa8gl2Zxe9C/j1NQGLAePZiJDnVOQUcwYLDviY+9ZdVb3fHtdsE9Bs8FJb/
         IBgw==
X-Gm-Message-State: APjAAAUrmB39oyhGfvR0OU+dTL0hokzP8ivLn6wXFStoHDslS9X7kl7E
	m+CVi8tzf4cnwQvKpMwp/+qE8Uf+kJcIDgePZN0oWvSFhdLiIDnYu31TGzw0Vi0EmiWxlBBKQ/f
	JaUDMiFKvxCIolE6SbB1s1hxqxDXcoXSZ2omwbwFaJN55iwFsoGKy3m9x9n88BbNEJw==
X-Received: by 2002:a5d:4e8d:: with SMTP id e13mr102075wru.299.1557259332240;
        Tue, 07 May 2019 13:02:12 -0700 (PDT)
X-Received: by 2002:a5d:4e8d:: with SMTP id e13mr101990wru.299.1557259330414;
        Tue, 07 May 2019 13:02:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557259330; cv=none;
        d=google.com; s=arc-20160816;
        b=JHYtmVeG+AMAFHJj8xY8x+BQg+vylwluytyArbELhOlXnfhXag7lHJoD4+wRVtUesD
         DO/dKqVDsH5DOuB4U2wkWPlNJmrm3SRYAnKfNDtH61A/g30tw7R4qqo6FK6h0SmMa9BD
         YZYH29RHMRSOlGuQm0xGYhXKhP/zsIp6/43KNfTF15ilnvLK4nT7TXGkgw6BCm2emsSp
         Jfc/3W58pOut/iN/rm5tDL1CGzIij43Aqv9Xg6fNW01k/J82wxks0EGP7666sPevfTgj
         i8CzGxbr8OOSlYLp//T1zRrwbh1To3K5eh/hV90eaoqGNQfpbL4wB9dFZVv1c4y85EMx
         g4nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Gb9u8BwK6K2VHZrF75n3DXs/h9sjtM0WB9yfdMMjAhA=;
        b=06c8It1nNWWm8xzBjjIIiluZvQ4hrF0CBjSZakaQooFsFAmisESJ7Mm4xMh1FOFA/n
         OVCTXb/lLLdrKuba++P35/dWTg2TEZDrqmBMWCwnQyoGGVzgUZOHiumRTqcDUyA/WC8p
         LjbtWbOSxT5mypPYJ++tnn0G5xxOGEwg17NfExPm+k3pzomTx5IgI3ip1CC2lkVg6Tq+
         SSFCJeFuo4SzLepIbYK2fRsH1nHmKs0o7AsZZwAPmJkYzp4QjU2RNrkzXaAcC8EXoAT5
         ZDXsXCgj1TkXGjFkAr1pU/3bqG9FH6lO4eSTPfeuxAqbLkU0xslEqhlMAtCHYbHYpyAt
         ZcCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eohhKp0u;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q16sor6293615wro.38.2019.05.07.13.02.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 13:02:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eohhKp0u;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Gb9u8BwK6K2VHZrF75n3DXs/h9sjtM0WB9yfdMMjAhA=;
        b=eohhKp0uJ59T4vEbRM8AblhUOv5qTWeRAMn2c9ZZJbtbBZV39LMSdRmpjRZV012Tjk
         aQlKi86yUbKUQXNoAdPT7NP58zePSKmLAzMBVVPMJYSFAUVsRkBAanek3lVReA7NaMU2
         4hse+dLfBHZKk8lAb9E9N6aU1/TXBtwhPWPLLtHxpSnS+UaUapsKrN36Kp1i0/kIQZfo
         HVo2YxHWes539ea/pnrbW5nfLgZ4wpDXlX2mpUoIMAxbGkXnEIK/za1dC5fgNbsTm6zj
         NcPTwCKtweysI+H59YIFlYEQf8sREG19TYikWeSZCBllOYodPE7GHzOjREW0aovRq4Ks
         9YDw==
X-Google-Smtp-Source: APXvYqxs+eKVLDUCD7g1rHPBXhFirmnfKqD64Voz1LQgEtV71NQil14wxCREeOhs+iddBtqX9ipfLYX5xoI8j2bfFO4=
X-Received: by 2002:adf:f2c7:: with SMTP id d7mr8881043wrp.320.1557259329560;
 Tue, 07 May 2019 13:02:09 -0700 (PDT)
MIME-Version: 1.0
References: <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain> <20190507070430.GA24150@kroah.com>
 <20190507072721.GA4364@sultan-box.localdomain> <20190507074334.GB26478@kroah.com>
 <20190507081236.GA1531@sultan-box.localdomain> <20190507105826.oi6vah6x5brt257h@brauner.io>
 <CAJuCfpFeOVzDUq5O_cVgVGjonWDWjVVR192On6eB5gf==_uPKw@mail.gmail.com> <20190507165344.GA12201@sultan-box.localdomain>
In-Reply-To: <20190507165344.GA12201@sultan-box.localdomain>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 7 May 2019 13:01:57 -0700
Message-ID: <CAJuCfpHmfccmT6SwZMqseOQh2SY7+8pXtfE1nppKkiUmayh-ug@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Christian Brauner <christian@brauner.io>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, Daniel Colascione <dancol@google.com>, 
	Todd Kjos <tkjos@android.com>, Kees Cook <keescook@chromium.org>, 
	Peter Zijlstra <peterz@infradead.org>, Martijn Coenen <maco@android.com>, 
	LKML <linux-kernel@vger.kernel.org>, Tim Murray <timmurray@google.com>, 
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Oleg Nesterov <oleg@redhat.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Andy Lutomirski <luto@amacapital.net>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Sultan Alsawaf <sultan@kerneltoast.com>
Date: Tue, May 7, 2019 at 9:53 AM
To: Suren Baghdasaryan
Cc: Christian Brauner, Greg Kroah-Hartman, open list:ANDROID DRIVERS,
Daniel Colascione, Todd Kjos, Kees Cook, Peter Zijlstra, Martijn
Coenen, LKML, Tim Murray, Michal Hocko, linux-mm, Arve Hj=C3=B8nnev=C3=A5g,=
 Ingo
Molnar, Steven Rostedt, Oleg Nesterov, Joel Fernandes, Andy
Lutomirski, kernel-team

> On Tue, May 07, 2019 at 09:28:47AM -0700, Suren Baghdasaryan wrote:
> > Hi Sultan,
> > Looks like you are posting this patch for devices that do not use
> > userspace LMKD solution due to them using older kernels or due to
> > their vendors sticking to in-kernel solution. If so, I see couple
> > logistical issues with this patch. I don't see it being adopted in
> > upstream kernel 5.x since it re-implements a deprecated mechanism even
> > though vendors still use it. Vendors on the other hand, will not adopt
> > it until you show evidence that it works way better than what
> > lowmemorykilled driver does now. You would have to provide measurable
> > data and explain your tests before they would consider spending time
> > on this.
>
> Yes, this is mostly for the devices already produced that are forced to s=
uffer
> with poor memory management. I can't even convince vendors to fix kernel
> memory leaks, so there's no way I'd be able to convince them of trying th=
is
> patch, especially since it seems like you're having trouble convincing ve=
ndors
> to stop using lowmemorykiller in the first place. And thankfully, convinc=
ing
> vendors isn't my job :)
>
> > On the implementation side I'm not convinced at all that this would
> > work better on all devices and in all circumstances. We had cases when
> > a new mechanism would show very good results until one usecase
> > completely broke it. Bulk killing of processes that you are doing in
> > your patch was a very good example of such a decision which later on
> > we had to rethink. That's why baking these policies into kernel is
> > very problematic. Another problem I see with the implementation that
> > it ties process killing with the reclaim scan depth. It's very similar
> > to how vmpressure works and vmpressure in my experience is very
> > unpredictable.
>
> Could you elaborate a bit on why bulk killing isn't good?

Yes. Several months ago we got reports that LMKD got very aggressive
killing more processes in situations which did not require that many
kills to recover from memory pressure. After investigation we tracked
it to the bulk killing which would kill too many processes during a
memory usage spike. When killing gradually the kills would be avoided,
so we had to get back to a more balanced approach. The conceptual
issue with bulk killing is that you can't cancel it when device
recovers quicker than you expected.

> > > > I linked in the previous message, Google made a rather large set of
> > > > modifications to the supposedly-defunct lowmemorykiller.c not one m=
onth ago.
> > > > What's going on?
> >
> > If you look into that commit, it adds ability to report kill stats. If
> > that was a change in how that driver works it would be rejected.
>
> Fair, though it was quite strange seeing something that was supposedly to=
tally
> abandoned receiving a large chunk of code for reporting stats.
>
> Thanks,
> Sultan

