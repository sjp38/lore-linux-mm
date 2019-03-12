Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7515C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 20:34:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F6F42171F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 20:34:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F6F42171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9B2A8E0003; Tue, 12 Mar 2019 16:34:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E48EE8E0002; Tue, 12 Mar 2019 16:34:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D11758E0003; Tue, 12 Mar 2019 16:34:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3778E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 16:34:41 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id m10so4364014pfj.4
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:34:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lnw/i8+cwkwS041v7FVN5RKf/++KHvsp9rzwYmaSjcA=;
        b=F+0Pouhjw+72JtTjIliolWPj61VcOKc3V8DFNoeBCTEtaYV6nLxZVttVfcHSCIW38T
         AeISvfQfkJlh9y6WX1/wMMWUz9zEwKqcDOkjxvleOiWLaJBeX6ND1SX4JNYNVuU1lN+o
         HgKd5t5EWI4DD3fgVLyOcscBpH8ecYGihskGxs2j2wui3+IBtXGXoyNNUHBLoENLDl3v
         MupNs+H5im5jpqD4Iw2S4fHTx+XypnTvJTAtDv8NW2UEQNS5qMqIXIIbUsdJXibOjCWd
         EkMwEBdpp1QfEPYLKftlA+u0Ut1gbXaS0nea2J6Jf9ow3/Ho+O4TVoAE+xJ/2tQMtWpQ
         PDYA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAW/f1svW7cbhu3Gh7t03NPEr+EnKrL0noLsLKqGXtAn7t5hOdAA
	X2YVb1dj4xLIu4/CCptIK+0A9GRZgvN6/k1JEwk6+xQSCiGAER5mM2WlI0V97iG98HdougqfwNk
	19WRxQIBWW13iwehe8KqOopBVS9ZABM4NH2Zr/qTMkU34JzIT4rKwADMLj3CE724=
X-Received: by 2002:a65:6497:: with SMTP id e23mr35844035pgv.21.1552422881002;
        Tue, 12 Mar 2019 13:34:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcqZeC45YT5ITn/gJyMGNumAZ2388zJmKbnLJHXML+e7SZnSoKrv+xnZA7LEekg+VdKkF3
X-Received: by 2002:a65:6497:: with SMTP id e23mr35843968pgv.21.1552422879637;
        Tue, 12 Mar 2019 13:34:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552422879; cv=none;
        d=google.com; s=arc-20160816;
        b=P/ABok82vldpynd4NwL/va7D0f4ffHzwmwSnzZk0Jbn0T4UbsrK/1M3FJELVNDuBuU
         aiKM1nbfgxFVYPUlMhU5oJn/e28OhqmTFf9PEL31yVOAuEpy+dSL+7diewwEocOplVXQ
         MWa+kp/rWBBqmqOxABNs18I9nxqT6WIRyaxi7smOev3uqJPyJnmwBXEdhZobL0mYBapB
         IF/XpP7LmGzwCWZL7Ws6FMPE4dNilWCyhV4qX7H8VBM5+zQpVR+xLc5K9ANg9sXzbdeC
         w+0kotMTEepXzJ4QprzH3uT4TERzhYNCTWplun+/inr35w4r5iJee9L8Tb3aO3jc9LVV
         /y3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lnw/i8+cwkwS041v7FVN5RKf/++KHvsp9rzwYmaSjcA=;
        b=nQhLExMLD6o2Q7n7SC0/EKI7W6GE+/HXvokxTN+yv4zK0gboTC27gGOYOzVop8aNts
         Ln9YgZzZerYYXbQYr0ynFm1d8iJh0MD2TphQcvbyxY1tviuiJKCe+hCLewkBGr2NgRmp
         UubIroj9JJtl1LaFBdKg6jRHLy3wj1m9eI6kfo8cPK1DQB3AL1Kj7zNsAJNrQ6dI2guY
         O6lYLNXxlg+3GA0RRwO+K8aa51Qk14F/7uA3xAmN6N4adXSsh6ipJ7GFBCaCAo5ZzKTM
         9WjRjpcGl9vYmE8dtwedoh0d3ndVV779k7O7eaVWWu+Ap3b8flOotaQEN0kDYFRHuJnH
         8DYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id d62si8803506pfg.160.2019.03.12.13.34.38
        for <linux-mm@kvack.org>;
        Tue, 12 Mar 2019 13:34:39 -0700 (PDT)
Received-SPF: neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.136;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail01.adl6.internode.on.net with ESMTP; 13 Mar 2019 07:04:36 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1h3o6e-0001QJ-6W; Wed, 13 Mar 2019 07:34:36 +1100
Date: Wed, 13 Mar 2019 07:34:36 +1100
From: Dave Chinner <david@fromorbit.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190312203436.GE23020@dastard>
References: <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
 <20190307094654.35391e0066396b204d133927@linux-foundation.org>
 <20190307185623.GD3835@redhat.com>
 <CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
 <20190312152551.GA3233@redhat.com>
 <CAPcyv4iYzTVpP+4iezH1BekawwPwJYiMvk2GZDzfzFLUnO+RgA@mail.gmail.com>
 <20190312190606.GA15675@redhat.com>
 <CAPcyv4g-z8nkM1B65oR-3PT_RFQbmQMsM-J-P0-nzyvvJ8gVog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g-z8nkM1B65oR-3PT_RFQbmQMsM-J-P0-nzyvvJ8gVog@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 12:30:52PM -0700, Dan Williams wrote:
> On Tue, Mar 12, 2019 at 12:06 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > On Tue, Mar 12, 2019 at 09:06:12AM -0700, Dan Williams wrote:
> > > On Tue, Mar 12, 2019 at 8:26 AM Jerome Glisse <jglisse@redhat.com> wrote:
> [..]
> > > > Spirit of the rule is better than blind application of rule.
> > >
> > > Again, I fail to see why HMM is suddenly unable to make forward
> > > progress when the infrastructure that came before it was merged with
> > > consumers in the same development cycle.
> > >
> > > A gate to upstream merge is about the only lever a reviewer has to
> > > push for change, and these requests to uncouple the consumer only
> > > serve to weaken that review tool in my mind.
> >
> > Well let just agree to disagree and leave it at that and stop
> > wasting each other time
> 
> I'm fine to continue this discussion if you are. Please be specific
> about where we disagree and what aspect of the proposed rules about
> merge staging are either acceptable, painful-but-doable, or
> show-stoppers. Do you agree that HMM is doing something novel with
> merge staging, am I off base there? I expect I can find folks that
> would balk with even a one cycle deferment of consumers, but can we
> start with that concession and see how it goes? I'm missing where I've
> proposed something that is untenable for the future of HMM which is
> addressing some real needs in gaps in the kernel's support for new
> hardware.

/me quietly wonders why the hmm infrastructure can't be staged in a
maintainer tree development branch on a kernel.org and then
all merged in one go when that branch has both infrastructure and
drivers merged into it...

i.e. everyone doing hmm driver work gets the infrastructure from the
dev tree, not mainline. That's a pretty standard procedure for
developing complex features, and it avoids all the issues being
argued over right now...

Cheers,

Dave/
-- 
Dave Chinner
david@fromorbit.com

