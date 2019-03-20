Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AACAC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 05:07:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9CEF21874
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 05:07:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="XC2uir3X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9CEF21874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DE6C6B0003; Wed, 20 Mar 2019 01:07:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58D7E6B0006; Wed, 20 Mar 2019 01:07:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A29E6B0007; Wed, 20 Mar 2019 01:07:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08BFB6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 01:07:07 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z26so1377231pfa.7
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:07:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iFY+RF5AGk9Eae8efxsCo1T+4omBssQTKS3QA41G7/U=;
        b=UpFUksIN69Lq9xmVLMmrV+DL6XYBKex+K8pkpr0TXHlPyEgbmDowRZeN9Ls+LTOm6C
         oCFvmuW8aBWKG7kbAq1dnMikGSk90DqI39TgcfpolcQPLk0bvRGtBcmnZA04NXaFYwaS
         B+uCuUW+i15yTNVByQRUSZP9WFNwKln9W5G+9AFov9S7hblkZN+FrogZMDRnqxex6uoY
         JJU5yHuYEhsJ5a6jRflINyY7whOoIyuyEzmC0lAawQdK8Q3TXfIi22yUz4COuM8SM7f2
         fMY8ZUmU/qWi8mVV7Hd9Ouk3E7tf+TwNkxeimrtRErNgUJ0ONB5DgGKczN2lzlAYTeXJ
         jcHg==
X-Gm-Message-State: APjAAAUqvRcuXhQH5XKhtDx+tGeiU9Akc2uMYP4ts8XUuFqiFkTpKFZ+
	JtFMiDMg7V2t5LcqkGDvi+dFlBey9z9z6+s6cMg6YOGrxX2eY363OSUWoTxfYeBkxGXIY1+B43U
	7L9b7zF5KNL0/8fzg3zehkYbfxj4cmC72dq8ejkYS5NpZQjJN5Ubb4vdgRYL0fWDiuw==
X-Received: by 2002:a62:4214:: with SMTP id p20mr5868287pfa.204.1553058426528;
        Tue, 19 Mar 2019 22:07:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgL5KWQ3v/5BPv+Dhv+hnIPc68yWCEhEu7eAXBA648jN2aGB9clMFHbljwFi1l2oUbkY0t
X-Received: by 2002:a62:4214:: with SMTP id p20mr5868160pfa.204.1553058424455;
        Tue, 19 Mar 2019 22:07:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553058424; cv=none;
        d=google.com; s=arc-20160816;
        b=uTwSg5/oTrR83uG06hCM7v0HxzkgoOt5SlQ4GWCqC5g3adtqOvU8cPAWQ3ujoVrv+w
         r81qD4pl3kfgDAqov4AXn3KPQ+fiywOR59lcQe5yfjEAeQQaIZjX1W5oorOFvM6OxpkC
         Qy/0eIgSzjszVK/BzJCP1Leq+W4OjZz6YwUVGSss0Mh6vaWeSn7ql+pFqx3sYbNLNaDQ
         J2O531n5Ju8jYAkQHt7aEq4X++q8AB7gin79CXjk7VPvkcIn5JQaQWg49wxBn/VGkx9n
         OcBKaagJrhrHlPqO1jRgmi4AL1ZFAZmZnAKMWwq40k0SYdRjwyvdz8kPbD5FzY5bbDw4
         +GwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iFY+RF5AGk9Eae8efxsCo1T+4omBssQTKS3QA41G7/U=;
        b=UiYdPgdASrr7HTmwV2KNRakRq5FmD0g4DrvlR8vUbBseMn4V53H77XJvOpeS7ttcV4
         0+HeGPobqs7Ojy8zW1u7yZpkDdQRVJSI+8ZruSAsiMB2Tn+d99cdrQ8B9rV/06uQefxG
         tvcj2NV3NKDN7z1zEKxZmphhdTnJcbyZW28CoYsn7gxCXEkP7g2HsTAYO/AZ63uBkfD7
         q6ZUcOudtFGuyFmYal80kJfPD9ZguxJJCGUS3ceZicNI/pTNDdRKdwwfgX1kzLTYGx4t
         4tY0UFLG39mUJxwT4wmKbADrTQTj+zcV0W5j6PZLCSjsWPZurEDXCzJczIvrAYedykfd
         SccA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XC2uir3X;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q61si987180plb.245.2019.03.19.22.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 22:07:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XC2uir3X;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7A2482184E;
	Wed, 20 Mar 2019 05:07:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553058424;
	bh=8p/yQVuYxwPBUvtN5pJ6q3FFkPCc2jHRg4Ry482iwVw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=XC2uir3Xk/AX1uJ8bdb1jKQJ3kKkm7tM4nADXJ46Rw6BMufgdgUfmciBN6WOO6pf9
	 v3iWaJ+RUrn5x/HwsX3BpJ1+iLLndn9fG9LQ5Qf+WeKTLbtOoSUj1gW+hZCZqQZKLB
	 CxfwzlJTesAblrINzQ8FtW/YZxpWLW6CLFuUNnEk=
Date: Wed, 20 Mar 2019 06:06:59 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Jon Masters <jcm@jonmasters.org>
Cc: Sasha Levin <sashal@kernel.org>, Amir Goldstein <amir73il@gmail.com>,
	Steve French <smfrench@gmail.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190320050659.GA16580@kroah.com>
References: <20190212170012.GF69686@sasha-vm>
 <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
 <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
 <20190213091803.GA2308@kroah.com>
 <20190213192512.GH69686@sasha-vm>
 <20190213195232.GA10047@kroah.com>
 <79d10599-70d2-7d06-1cee-6e52d36233bf@jonmasters.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <79d10599-70d2-7d06-1cee-6e52d36233bf@jonmasters.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 11:46:09PM -0400, Jon Masters wrote:
> On 2/13/19 2:52 PM, Greg KH wrote:
> > On Wed, Feb 13, 2019 at 02:25:12PM -0500, Sasha Levin wrote:
> 
> >> So really, it sounds like a low hanging fruit: we don't really need to
> >> write much more testing code code nor do we have to refactor existing
> >> test suites. We just need to make sure the right tests are running on
> >> stable kernels. I really want to clarify what each subsystem sees as
> >> "sufficient" (and have that documented somewhere).
> > 
> > kernel.ci and 0-day and Linaro are starting to add the fs and mm tests
> > to their test suites to address these issues (I think 0-day already has
> > many of them).  So this is happening, but not quite obvious.  I know I
> > keep asking Linaro about this :(
> 
> We're working on investments for LDCG[0] in 2019 that include kernel CI
> changes for server use cases. Please keep us informed of what you folks
> ultimately want to see, and I'll pass on to the steering committee too.
> 
> Ultimately I've been pushing for a kernel 0-day project for Arm. That's
> probably going to require a lot of duplicated effort since the original
> 0-day project isn't open, but creating an open one could help everyone.

Why are you trying to duplicate it on your own?  That's what kernel.ci
should be doing, please join in and invest in that instead.  It's an
open source project with its own governance and needs sponsors, why
waste time and money doing it all on your own?

thanks,

greg k-h

