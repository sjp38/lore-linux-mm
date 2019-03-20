Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 304F6C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:28:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D74EC2186A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:28:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Hy2IuyxD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D74EC2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52FDA6B0003; Wed, 20 Mar 2019 02:28:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DE696B0006; Wed, 20 Mar 2019 02:28:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CDC06B0007; Wed, 20 Mar 2019 02:28:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3E096B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:28:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c15so1553695pfn.11
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 23:28:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LbIl5miV1UQk/NYOoLkhOwmfUEF1As80uuyi+JvPxtE=;
        b=ildNCgGMuhbc/4PQHDkfmm6S/1eq0JC48sFkG/zN8iUot1Lf01rOXSoK2w6NTmRosM
         UF/oi8MUgi0pH+90W9PDiDotcLrQ5UbyeyMkHhus+BAIkZK5/oVmQOlLidzXujxCyYhY
         xIRm0htuRI0GnF6tUPPtv4Qnstsk2Jokfp/vRwYIjWlbvbaOZWu+0DepqaH06hV03egR
         x+Fl0SJ/0IoWgf2PjBepS4J1YK9zHPFdXD9bjViwDzixuY26+qTOELVqsL4jRq8G05NZ
         fpa3j3Q5b9NlunglOsohN9qGQUPna8EyElBGIpqZhVa1X+yaagTvGu+xAVDQG21wDuB3
         HS9A==
X-Gm-Message-State: APjAAAXdi9EvgzKzDmdyTDjkRaQY6oUR13wjZAdmPbHblMnHPSWbEKv5
	KuS2SE2CMMjL6KfQ/tpB25iLh5cZdKerUWLNwrK6Y7G5BwWUmLkhBlcFrPT1kfqTny+6ad0JY/2
	gLptvVOfgM3oxwNbMAnuO1rqSRHGK1s3pJYPLCOB4UeEvENiP0wZgCWksQRugYiSVig==
X-Received: by 2002:a17:902:9a5:: with SMTP id 34mr6293010pln.287.1553063308644;
        Tue, 19 Mar 2019 23:28:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwm0CA4U+xoEDzOs8YKWJq9yP5b3YkiV8LQhfao3vFV5fQ1M9CzzuvjOccTliHlfo5juSk5
X-Received: by 2002:a17:902:9a5:: with SMTP id 34mr6292944pln.287.1553063307655;
        Tue, 19 Mar 2019 23:28:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553063307; cv=none;
        d=google.com; s=arc-20160816;
        b=m7VeHPlwXwIljGrjPtw+gk/Y/9PYbLua0mz2WKfYOjGP2m8L4162uI+j11zHaov7Lo
         FLeFHeDybeBVUujH/kmKlonpn39myWIS5JkB4G+W+OYuGQSj9CCzAQKMYxDdKCTwpt2n
         laCt3OJX2xK20ORiSlj8LKlkc2PhGJzzysxOq1cLIJSXm9bjSYXvHfOT2GgUZbQVLBz5
         l3UVWZlwU7xKfkEEiSQgj90SkOylOUudMdDz42JfDxnjV3FMrI4B5VY6uOHoPUVI9qHr
         vlG4WlVhBwYZtlhONtvc2Gm+vTu6ya371dxjXdfBR6tmUKnRJUS8az2ZJtocqLe6Qbz0
         ysJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LbIl5miV1UQk/NYOoLkhOwmfUEF1As80uuyi+JvPxtE=;
        b=NDjLIiJXsE7fVtdEQkEbPdgo+v06DheLllqm5ZNzx4I6R/3AnXVEHwTvgWw75Cj3UR
         vsIqSdXQohQi1LevUejIXfVt7s1lAtE8Q6paQL9BynSVAkCWlrJM+c6z245p/vUu8FtW
         A81kAZJozVbO1tMl9HQaYrBYyFYneLafUJfnnqoCgB9cpDIVp5IFQAP8BhNiVlPVDAD3
         zevFLOfHDbdsVT+Hk2bJoIeVuD+aaKHcYfZzdPAwmZ7HvruYcArS1rUWYhwnSeDWbz2s
         rP6AW7ycH2VI0qveF98iiCqQgXLY7mgaxbnzciVekAgvDXcKIRmHCDzVUKjC414qGe5Q
         KRew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Hy2IuyxD;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 42si1155886pld.383.2019.03.19.23.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 23:28:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Hy2IuyxD;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CAD752184E;
	Wed, 20 Mar 2019 06:28:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553063307;
	bh=q6Tl8p2X/rd5nPI6ZuGwZIG2VMWqvkZUQ3AmxOiHGqs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Hy2IuyxDTqyNO86MzHtCQRsYBqm+0SqWn1v35q0bJnaub/HMuIapUVQj9mhSDtyRp
	 O4yuN4G37XsHqbIcV6f+bUa20jPHvgnOqxjSfpbZI3UAaAY3fliJ/2gnTu7/5DRz3I
	 +cX44XzmOP4hxx4xtsOzOwT0U0FeKzIDTxpDQcJw=
Date: Wed, 20 Mar 2019 07:28:24 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Jon Masters <jcm@jonmasters.org>
Cc: Sasha Levin <sashal@kernel.org>, Amir Goldstein <amir73il@gmail.com>,
	Steve French <smfrench@gmail.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190320062824.GA11080@kroah.com>
References: <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
 <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
 <20190213091803.GA2308@kroah.com>
 <20190213192512.GH69686@sasha-vm>
 <20190213195232.GA10047@kroah.com>
 <79d10599-70d2-7d06-1cee-6e52d36233bf@jonmasters.org>
 <20190320050659.GA16580@kroah.com>
 <134e0fe1-e468-5243-90b5-ccb81d63e9a1@jonmasters.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <134e0fe1-e468-5243-90b5-ccb81d63e9a1@jonmasters.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 02:14:09AM -0400, Jon Masters wrote:
> On 3/20/19 1:06 AM, Greg KH wrote:
> > On Tue, Mar 19, 2019 at 11:46:09PM -0400, Jon Masters wrote:
> >> On 2/13/19 2:52 PM, Greg KH wrote:
> >>> On Wed, Feb 13, 2019 at 02:25:12PM -0500, Sasha Levin wrote:
> >>
> >>>> So really, it sounds like a low hanging fruit: we don't really need to
> >>>> write much more testing code code nor do we have to refactor existing
> >>>> test suites. We just need to make sure the right tests are running on
> >>>> stable kernels. I really want to clarify what each subsystem sees as
> >>>> "sufficient" (and have that documented somewhere).
> >>>
> >>> kernel.ci and 0-day and Linaro are starting to add the fs and mm tests
> >>> to their test suites to address these issues (I think 0-day already has
> >>> many of them).  So this is happening, but not quite obvious.  I know I
> >>> keep asking Linaro about this :(
> >>
> >> We're working on investments for LDCG[0] in 2019 that include kernel CI
> >> changes for server use cases. Please keep us informed of what you folks
> >> ultimately want to see, and I'll pass on to the steering committee too.
> >>
> >> Ultimately I've been pushing for a kernel 0-day project for Arm. That's
> >> probably going to require a lot of duplicated effort since the original
> >> 0-day project isn't open, but creating an open one could help everyone.
> > 
> > Why are you trying to duplicate it on your own?  That's what kernel.ci
> > should be doing, please join in and invest in that instead.  It's an
> > open source project with its own governance and needs sponsors, why
> > waste time and money doing it all on your own?
> 
> To clarify, I'm pushing for investment in kernel.ci to achieve that goal
> that it could provide the same 0-day capability for Arm and others.

Great, that's what I was trying to suggest :)

> It'll ultimately result in duplicated effort vs if 0-day were open.

"Half" of 0-day is open, but it's that other half that is still
needed...

thanks,

greg k-h

