Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91068C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 16:01:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 479C020879
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 16:01:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="Xt/t8fO/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 479C020879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D41966B0007; Wed, 22 May 2019 12:01:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF2D46B0008; Wed, 22 May 2019 12:01:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE0DB6B000A; Wed, 22 May 2019 12:01:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 70CBE6B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 12:01:13 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k10so1350587wrx.23
        for <linux-mm@kvack.org>; Wed, 22 May 2019 09:01:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fuynlKhllfIeQm52cXMWcD0lUs6CispzZaQZtwuYuAg=;
        b=ZouYMEk/v2m99PbEQNa9I+ru70VYcLahciOlmehRWHckluutNBdqh25BUehgcbebXH
         IUQm45/oHuoAe+W7M1uiY1GzOp2I7A8DINDKsOzED6+LVTXlDkYWsN3Y4HDQ0jfjW+b7
         jnYw79m3+jm55MmYIUU447ZpMUfD5h91ozCjrMum3vFR5tMsoYooRwtpkLWknzXSopSr
         nH0VsM8Cu85Fk8SFKZLAXB3O9Sl47ChHK3BVPOsbtSjzwgV23Z8Gw0jJJoyl+UyWnYXY
         leIYw1ZMcvfYk0X2VlQXMI61Srt096Vun0od5CSaV+qgv2AvbWsYA6q9GukVe45rWyyO
         pgpQ==
X-Gm-Message-State: APjAAAXlKTI+wmG9TeuRSs5jWwQADqXxep1GRDnqv/gEJwN8dxotMQnD
	HwLAjChHrPLFv62mK/T7A1F4sZpqsiiOICQtcabqIqbmppX0zp9wMmJ/x8P+FQCKd/kR2rFwGhR
	0ppUTkEoilBoipkKUna/mICV3XlhmHPVWlMl404Jz0ff35wzpXGrzQmlgf97VlQjH0w==
X-Received: by 2002:a1c:e386:: with SMTP id a128mr8356571wmh.69.1558540873037;
        Wed, 22 May 2019 09:01:13 -0700 (PDT)
X-Received: by 2002:a1c:e386:: with SMTP id a128mr8356495wmh.69.1558540872150;
        Wed, 22 May 2019 09:01:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558540872; cv=none;
        d=google.com; s=arc-20160816;
        b=nQ7SzQz3xqQ0tix+mTRqt2ldLPC/q4HIZgt10l2yI6QPE+BG9yUYEXWnHA1mgKfAsp
         oTiS6NdAM8csejsgX0P3UjsIbwdth7ZLSLmve2CewNKdxrXi0i9+zONpwvi0WG2riPoZ
         XTJUoSDEQysjHUyr2SM/jjN246hIPtAADFKy/A7WVXW20QVWFbOeurlqumZhVQXny9vn
         yGQQqnYrZUI0PrP8dTNwgHO6AjraY+JQOGclymN2cYZrYhskBeqlTjx+Plp6JSsJhO1F
         PSbwSXfa+7D9IngowkUBvVEgE27aTpaJlWI42nRqtmvZ6IhvHoz6k3jvIpZDBXsV9DvV
         iI+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fuynlKhllfIeQm52cXMWcD0lUs6CispzZaQZtwuYuAg=;
        b=tREBHoCFnEqTnZadS10V9O52Q+pBigMLTz0CmXQRAtsbxBEEd5GTwSQJP5+IiX6D+U
         p1ikMNwqRrpm2KSDJJU1IV5r3I4E3KBN7S+fv4Dd2V9lRUzkwfuVXqAh5H75G7a5EmWc
         VUOmGLi9gMcsQJ8d/KBp/yy/Ko1U1vzCBrKBkP1YFDcII7EG88Hmmtka1TL+dz7CppwU
         uE0Z0OzYabYqZW2ypvUVoRKHCBxBJy1QH4+NciwT6XRyh3kHLcZewxtSRwq6wkXQIGly
         tl21xSIqgi0Ol/ZZtevPNDpH6yLYFRlZGjW9RQwtL9KSA1ZS52sguyvjhQo227jNKBEr
         CiCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b="Xt/t8fO/";
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3sor12082717wrw.39.2019.05.22.09.01.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 09:01:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b="Xt/t8fO/";
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fuynlKhllfIeQm52cXMWcD0lUs6CispzZaQZtwuYuAg=;
        b=Xt/t8fO/1a/GpjPYTtXUr5AFRVjDBYkZmO5Ma1d5Z4Y7booTaJs+tYhgg7B1Hhhv5M
         RQg5GVXm9Sk6FUf1hmMBWGrEmSWDPyAivd8s6isQZ0ZrwZk9/3n/ypCKK6lE8tlQmyYf
         yIzxa0rS3JKH84++TLbteyVEjEWHRwAJL/hA//PRCYGdXj6YSGbMXXfzt16FLkUs5wOR
         rUtyGvhrdu4a+ppko+BiMNLr8W7BBuhX+I9ikxYy4JgrPOngOJ20vo3YHVtSKknC+EHZ
         lrK2WsWl+oc+9k7kAcEFYMtBgOcVBhlvDYJ+ggv1EdfN5Wfp4ppRdMe4qZrSXrKiyr1w
         F2bw==
X-Google-Smtp-Source: APXvYqzeqkgWRWxY32f4i08YJhohV1p2HVc+Y20YULwQSETBfkni16XErxYOS6q6dHcenp/CA5kJew==
X-Received: by 2002:a5d:4cd0:: with SMTP id c16mr28980251wrt.20.1558540871772;
        Wed, 22 May 2019 09:01:11 -0700 (PDT)
Received: from brauner.io ([185.197.132.10])
        by smtp.gmail.com with ESMTPSA id y17sm22149428wrp.70.2019.05.22.09.01.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 22 May 2019 09:01:11 -0700 (PDT)
Date: Wed, 22 May 2019 18:01:09 +0200
From: Christian Brauner <christian@brauner.io>
To: Daniel Colascione <dancol@google.com>
Cc: Minchan Kim <minchan@kernel.org>,
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
Message-ID: <20190522160108.l5i7t4lkfy3tyx3z@brauner.io>
References: <20190521110552.GG219653@google.com>
 <20190521113029.76iopljdicymghvq@brauner.io>
 <20190521113911.2rypoh7uniuri2bj@brauner.io>
 <CAKOZuesjDcD3EM4PS7aO7yTa3KZ=FEzMP63MR0aEph4iW1NCYQ@mail.gmail.com>
 <CAHrFyr6iuoZ-r6e57zp1rz7b=Ee0Vko+syuUKW2an+TkAEz_iA@mail.gmail.com>
 <CAKOZueupb10vmm-bmL0j_b__qsC9ZrzhzHgpGhwPVUrfX0X-Og@mail.gmail.com>
 <20190522145216.jkimuudoxi6pder2@brauner.io>
 <CAKOZueu837QGDAGat-tdA9J1qtKaeuQ5rg0tDyEjyvd_hjVc6g@mail.gmail.com>
 <20190522154823.hu77qbjho5weado5@brauner.io>
 <CAKOZuev97fTvmXhEkjb7_RfDvjki4UoPw+QnVOsSAg0RB8RyMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAKOZuev97fTvmXhEkjb7_RfDvjki4UoPw+QnVOsSAg0RB8RyMQ@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 08:57:47AM -0700, Daniel Colascione wrote:
> On Wed, May 22, 2019 at 8:48 AM Christian Brauner <christian@brauner.io> wrote:
> >
> > On Wed, May 22, 2019 at 08:17:23AM -0700, Daniel Colascione wrote:
> > > On Wed, May 22, 2019 at 7:52 AM Christian Brauner <christian@brauner.io> wrote:
> > > > I'm not going to go into yet another long argument. I prefer pidfd_*.
> > >
> > > Ok. We're each allowed our opinion.
> > >
> > > > It's tied to the api, transparent for userspace, and disambiguates it
> > > > from process_vm_{read,write}v that both take a pid_t.
> > >
> > > Speaking of process_vm_readv and process_vm_writev: both have a
> > > currently-unused flags argument. Both should grow a flag that tells
> > > them to interpret the pid argument as a pidfd. Or do you support
> > > adding pidfd_vm_readv and pidfd_vm_writev system calls? If not, why
> > > should process_madvise be called pidfd_madvise while process_vm_readv
> > > isn't called pidfd_vm_readv?
> >
> > Actually, you should then do the same with process_madvise() and give it
> > a flag for that too if that's not too crazy.
> 
> I don't know what you mean. My gut feeling is that for the sake of
> consistency, process_madvise, process_vm_readv, and process_vm_writev
> should all accept a first argument interpreted as either a numeric PID
> or a pidfd depending on a flag --- ideally the same flag. Is that what
> you have in mind?

Yes. For the sake of consistency they should probably all default to
interpret as pid and if say PROCESS_{VM_}PIDFD is passed as flag
interpret as pidfd.

