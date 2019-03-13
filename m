Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9039C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:29:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E990206BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:29:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E990206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19C768E0003; Wed, 13 Mar 2019 12:29:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14ADE8E0001; Wed, 13 Mar 2019 12:29:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A9E8E0003; Wed, 13 Mar 2019 12:29:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8A98E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:29:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f15so1180137edt.7
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:29:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OY7cVf7fiSetvbco/da0cjAAKk/48aTVYLVyCJZ/wyo=;
        b=kmfOUM6SvmFtXvo3iQsEPuk6t2ftYp+VMLFoaXxyYA0sBXah3Ysx8nVWZl2LKNxYdO
         f3k1sxFTVHJnIqxsfJ+8s4GjXt72N5LH60lHX2bCiweTEVq3a8M5sLvuK83BQbqYuep7
         wLxUFFQB9rvmxYKrRXa+wDvFGtwsS7PAffdGQ1NEYWeOg45RNbXeo/uO9ape8n66aWVb
         7XVUeuZyOYf8GwsvXyUTbUH5N/Zu/eTHh/6EltSgEB19PhfH23H34FiTc2aZW9evDgIC
         ro6tl8YzSiYuKH94TVGrzGMHmmm+4/p0yQAP8GMLeo3q1p9InuoBPFhF6Fn6v7j0e7t8
         aRCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWQlMOMaHbu3cLBl+aPY+HoEV8P6BVi3s0I6anHAJ6OJxlmW+q+
	DNAWmCy04UZw9p9tPKk9QexHNnJkEAGdDMBrMLdDImfMJwHbfBbac51wR0eGMZFHUFoDZ1jHDFj
	F/ETyofGe2myxYvjuDXrJh1Bw2Lo7f70vc8KGUhMOrAGW/zs4HXNK2GPTq+s3k5aplw==
X-Received: by 2002:a50:b493:: with SMTP id w19mr8761027edd.11.1552494550175;
        Wed, 13 Mar 2019 09:29:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwV2UtXqKG2iwC9wbt8PzBnRh720eZ1YMgT+mcwns8K0plkqb1oTDKZN3oT+/PLpOKF1Tjj
X-Received: by 2002:a50:b493:: with SMTP id w19mr8760973edd.11.1552494549287;
        Wed, 13 Mar 2019 09:29:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552494549; cv=none;
        d=google.com; s=arc-20160816;
        b=H6DYxc8NRJees2sQ7Toy+nBG8aaQboL9QnD98PlJzvGS6ld7EE5z6OmHWmjnUwQATZ
         xcxF+nED0zLaBRpmVGEu4DhxQRCJJJC22VIpoXzGK0HaDuaYOSEXhQs/OEidy959kMeb
         NYI0lFjJOkgzrcUcV0BkG/3i1mcGVLRAuwG6qeLV2b/cZaucxap/M3rI/ereFwtPbx+Q
         hUkXndSc8Q5KGXbgUS/DPvHhMeOU8eBsd+6D1X6/yGp4uau8hjCL9/yCS3IqYhEdq80I
         x5Jj/JRNZGOwnCwjGNvB6HeiJtSGg2dZIjloByRpsE2kFkDWNQfs4rAqXms8vMB5gmgO
         Udpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OY7cVf7fiSetvbco/da0cjAAKk/48aTVYLVyCJZ/wyo=;
        b=Myk4dI5Hu1HOJEyJaY4nj3+e3BkMwBeE5lt/eCLn92AB/MfwsGAONjv8nfxzo/WFrP
         yTTOU3cUtYpi8SB15VzytrMlzWJEKxybup9wN0qoSlcyPJru5HRE5/XUCzWvigyEdMcp
         h/01kos9ysUJYPSkb2nIV2lnivb64RbCWi1E2ACwC2LskCNUztwpmXFYmQ0nhxuZw8Lq
         NDv93QuOG1NXNj1u0hGOdik4oJsBrqgABaPnNeCxxxd6NE9CLuDOvfg9BTdojmXVEXpS
         cVqQNxyk2i/Er2OcqZylBPqXiDiisPrhKSfExg3apHWbNhHzDM6IkYmfcsrzg0T+QsXu
         ECLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z1si996578edl.211.2019.03.13.09.29.09
        for <linux-mm@kvack.org>;
        Wed, 13 Mar 2019 09:29:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1FEE280D;
	Wed, 13 Mar 2019 09:29:08 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BC8233F71D;
	Wed, 13 Mar 2019 09:29:06 -0700 (PDT)
Date: Wed, 13 Mar 2019 16:29:04 +0000
From: Mark Rutland <mark.rutland@arm.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
	Jason Gunthorpe <jgg@mellanox.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
Message-ID: <20190313162903.GB39315@lakrids.cambridge.arm.com>
References: <20190310183051.87303-1-cai@lca.pw>
 <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
 <20190311122100.GF22862@mellanox.com>
 <1552312822.7087.11.camel@lca.pw>
 <CAK8P3a0QB7+oPz4sfbW_g2EGZZmC=LMEnkMNLCW_FD=fEZoQPA@mail.gmail.com>
 <20190313091844.GA24390@hirez.programming.kicks-ass.net>
 <20190313143552.GA39315@lakrids.cambridge.arm.com>
 <CAK8P3a3V+1sQJfTAipYyOeV5b379eYZXasRFjWnf9oKPtCTviQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a3V+1sQJfTAipYyOeV5b379eYZXasRFjWnf9oKPtCTviQ@mail.gmail.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 03:57:42PM +0100, Arnd Bergmann wrote:
> On Wed, Mar 13, 2019 at 3:36 PM Mark Rutland <mark.rutland@arm.com> wrote:
> > On Wed, Mar 13, 2019 at 10:18:44AM +0100, Peter Zijlstra wrote:
> > > On Mon, Mar 11, 2019 at 03:20:04PM +0100, Arnd Bergmann wrote:
> > > > On Mon, Mar 11, 2019 at 3:00 PM Qian Cai <cai@lca.pw> wrote:
> >
> > I think that using s64 consistently (with any necessary alignment
> > annotation) makes the most sense. That's unambigious, and what the
> > common headers now use.
> >
> > Now that the scripted atomics are merged, I'd like to move arches over
> > to arch_atomic_*(), so the argument and return types will become s64
> > everywhere.
> 
> Yes, that sounds like the easiest way, especially if we don't touch the
> internal implementation but simply rename all the symbols provided
> by the architectures. Is that what you had in mind, or would you go
> beyond the minimum changes here?

I'd expected to convert arches one-by-one, updating the types during
conversion. I guess it's not strictly necessary to change the internal
types, but it would seem nicer to do that.

I don't think it's possible to do that rename right now, unless we do it
treewide. There are a few core things that need to be fixed up first,
e.g. making <asm-generic/atomic{,64}.h> play nicely with
<asm-generic/atomic-instrumented.h>.

In the end, what I'd like to get to is:

* Arch code provids arch_atomic*_*().

* Common code fleshes out the entire API as raw_atomic*_*(), build atop
  of arch_atomic*_*(). All the ifdeffery lives here.

* Common code builds the instrumented atomic*_*() API atop of the
  raw_atomic*_*() API. No ifdeffery necessary here.

Thanks,
Mark.

