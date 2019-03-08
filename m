Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0D2EC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 20:08:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1458C205F4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 20:08:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="ztSEzU/6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1458C205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.ws
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E7FD8E0004; Fri,  8 Mar 2019 15:08:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9969A8E0002; Fri,  8 Mar 2019 15:08:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8883D8E0004; Fri,  8 Mar 2019 15:08:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4998E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 15:08:47 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id l11so28812621ywl.18
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 12:08:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lsDKYgY/vW+4PZgtpL6UxmadwcQMmmAKs9/Wm6oIc60=;
        b=eFDEHXsTxknG01nwTcA/a06wJ9PcC8Am/s09o9WyjEeUMtGxon+f4X4yQNzVrYIpMW
         IUWNf1icfWbacOckWbETAL+t01ET4/7KorTOorx0T+ET9yRIarkkUuD8X4DJ45Go9YPn
         Jej3Cow6udC7ri/0d5ynXiHZhI6tyHzY+Dtz1V4bHnao7LQZpEjSUxvw1ADSktvP+Ul/
         9QJhkb+kMepwL24JK61RIuXf0a90Dcg72ePURyCppnrdiEr/sHGg58rVx4pAYXdjS+pi
         YQN2Hd/VnVOhAnNVw0AHgyTmiB98W1BFzfeeA+CPtAvL6DreBJI4m7RiXa25Qq9txbU2
         xwjQ==
X-Gm-Message-State: APjAAAXOA2hIerI67hUskzb9Vnvax4r4TPM9JG2x9kK0mjN3rWbofBQi
	wxbRE8kZIyEj2hEn9jdz/l8sXqjFPAGZ0VgSptGe9kLtg/9bxBvAbxTuCMNNFFfX8njzuZ92COJ
	fTc8y1qyvX2TueR03WKF5IjltFC3vhDTYQAsjRR6hqSoqq9XMna28FGHIimSTle9I5Osn8FoWGp
	vCcghX5I7QzBXVntbp4lD4KEbuy1F6IepbHjaM3P8wJMaIdYbp6fgUWtKZx1Xhq4k1FnkV+Rb3P
	Mkx/ZFEU71h3XZ/Js5Qm+IVx6Y+VQwdEqHmolE+Ky175TWnGe4VvhUNiY9yZAA8VMHAXv5g9WwO
	bKDcMoYZ2i1Lf3/ktwg8kh9jnKsZX1If76XqPqONMhEA3M+DBmzn/dIR/0w+4hf4y91c6fBh1Xh
	K
X-Received: by 2002:a81:4c17:: with SMTP id z23mr15528230ywa.20.1552075727115;
        Fri, 08 Mar 2019 12:08:47 -0800 (PST)
X-Received: by 2002:a81:4c17:: with SMTP id z23mr15528192ywa.20.1552075726434;
        Fri, 08 Mar 2019 12:08:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552075726; cv=none;
        d=google.com; s=arc-20160816;
        b=IXSkBz8+9uxWBPc0rhbDjlVMlY3xw+PHP9BGzvBU4LgPi1AIFwDmJbBgeQTyThuwgf
         keKMTF+BZa/R320EoL+UWCcRxaBA3fQaeUOrgN0BmXteKUC776gNE9zSaAGQR0NV+SeP
         qBV8a9DSblaEdl2FRJsqtFw7eWfoljV0Xp6CW8BcsD9UiOsIsOe49OpmPXQMH6DzzPyi
         Mc7kv25PZ29cae4jsiO+YN7lKppzDYpeqZmGa8AmTNbMdQ+HrWLHVJsFI0iyZZgsjTG5
         g3cLkmFMsPj2oZfRFw8ZNwLpqsdbNRtXZzDwk6GhEpHXiTDxOWiD9g9cx5gUyfKCCqcS
         3cjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lsDKYgY/vW+4PZgtpL6UxmadwcQMmmAKs9/Wm6oIc60=;
        b=hZ+kKjnrjulMFFVbYtrwJGRVVI/Cb1lEBFR5/AdMVYcyFEaLVvBDR1YP4imcmqdI1b
         H3l1Oe9pdh4T9eq+p0P0bJn8xJ977KKeaitUJBb/LxFpECZ8TjP/FRdOfda5bOWLMUSH
         asAhmWYGYxxk4Ipt/TQ+ypCWGJMTzVOqY83m6aSPgjU6NdXdOBM6be3lWxPyhMs0iVZw
         FgiOquXG/xieerIXkTqJ5MUpA7HMn8Vz2FA6of8fszZWvU0ld9KMVO94UyU0Kz8bHC1c
         LW6wEs/5q0N7f2EdPFWgN6CbpXebWqXkm+PNwmj2TZPJrpOHivnKPjk+eeigkZoCNsrD
         YKWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b="ztSEzU/6";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a80sor1287856ywe.75.2019.03.08.12.08.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 12:08:46 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b="ztSEzU/6";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lsDKYgY/vW+4PZgtpL6UxmadwcQMmmAKs9/Wm6oIc60=;
        b=ztSEzU/6vBGBf9DrjQO0t5ZpIaSdOqZQyNVmCAsJmoAIkaaqfilKrcCTlQuxeJZbqE
         6Zardof+knqLJhbUghmNHG8oo+rpaByG1Z6DYq/6tVKVWpEtnySkX9np1nLchgYBXCfk
         bZeIJqhjnHWCSOv+tcoBYYaGO14uYTUykOH9M3QakiiJ8nq5aE+IWEgUHFriGvmMIPr4
         u7H+u6GUCvI4GLPfLWckLtm8EK/Y/8fr7JdfVIAQNaZ1T1SDbLTiOyytxe+IBxqr/NUz
         GIIIv/ggIVWjQc45wKQllONXB8b+oImRROVROuXY4lXNMLfuV+z7UcEgz3TP/rhHZk2g
         dgMQ==
X-Google-Smtp-Source: APXvYqxq6tlH3XmO+b/yYa/g/R5gxvHmySxARKfdam4+aP/F+bTd15GfgEDVQRkid+zicODj41s4rw==
X-Received: by 2002:a25:9002:: with SMTP id s2mr415ybl.375.1552075725718;
        Fri, 08 Mar 2019 12:08:45 -0800 (PST)
Received: from cisco ([2601:282:901:dd7b:316c:2a55:1ab5:9f1c])
        by smtp.gmail.com with ESMTPSA id y67sm3073646ywf.89.2019.03.08.12.08.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Mar 2019 12:08:44 -0800 (PST)
Date: Fri, 8 Mar 2019 13:08:42 -0700
From: Tycho Andersen <tycho@tycho.ws>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: Christopher Lameter <cl@linux.com>,
	"Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC 02/15] slub: Add isolate() and migrate() methods
Message-ID: <20190308200842.GF373@cisco>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-3-tobin@kernel.org>
 <20190308152820.GB373@cisco>
 <010001695e16cdef-9831bf56-3075-4f0e-8c25-5d60103cb95f-000000@email.amazonses.com>
 <20190308162237.GD373@cisco>
 <20190308195322.GA25102@eros.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308195322.GA25102@eros.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 09, 2019 at 06:53:22AM +1100, Tobin C. Harding wrote:
> On Fri, Mar 08, 2019 at 09:22:37AM -0700, Tycho Andersen wrote:
> > On Fri, Mar 08, 2019 at 04:15:46PM +0000, Christopher Lameter wrote:
> > > On Fri, 8 Mar 2019, Tycho Andersen wrote:
> > > 
> > > > On Fri, Mar 08, 2019 at 03:14:13PM +1100, Tobin C. Harding wrote:
> > > > > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > > > > index f9d89c1b5977..754acdb292e4 100644
> > > > > --- a/mm/slab_common.c
> > > > > +++ b/mm/slab_common.c
> > > > > @@ -298,6 +298,10 @@ int slab_unmergeable(struct kmem_cache *s)
> > > > >  	if (!is_root_cache(s))
> > > > >  		return 1;
> > > > >
> > > > > +	/*
> > > > > +	 * s->isolate and s->migrate imply s->ctor so no need to
> > > > > +	 * check them explicitly.
> > > > > +	 */
> > > >
> > > > Shouldn't this implication go the other way, i.e.
> > > >     s->ctor => s->isolate & s->migrate
> > > 
> > > A cache can have a constructor but the object may not be movable (I.e.
> > > currently dentries and inodes).
> > 
> > Yep, thanks. Somehow I got confused by the comment.
> 
> I removed code here from the original RFC-v2, if this comment is
> confusing perhaps we are better off without it.

I'd say leave it, unless others have objections. I got lost in the
"no need" and return true for unmergable too-many-nots goop, but it's
definitely worth noting that one implies the other. An alternative
might be to move it to a comment on the struct member instead.

Tycho

