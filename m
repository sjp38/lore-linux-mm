Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC45EC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 03:11:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42FEC20883
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 03:10:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="QRp6gXYh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42FEC20883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D6446B0003; Sun, 24 Mar 2019 23:10:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AD3E6B0005; Sun, 24 Mar 2019 23:10:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64EE66B0007; Sun, 24 Mar 2019 23:10:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 266A36B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 23:10:59 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g83so8425932pfd.3
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 20:10:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=XvFuk1ZULvnL/gHmZQiHeVYELloI7dJAf4pxrQoUf0w=;
        b=DBhsGO5FxJXsZN4wCsmVYIjU8PicgwE8CC7TMZmvQo2uePWVyiBqkgGKDslBTgxqx1
         kn5fxZLOWaHYEHJta7rAiDMJ2sR0LalpWH4i5puGd5feaCMLb1k7rp2QkZVk5p/P+Xhx
         X3gYRTvDkectT4g2djHUMEhFzxmIsEE3ZUAJ9pGh2CtPxzjYPXu4OIv7LsgS1ypFXUX9
         Cd6PteZ93X05ELvhVqKf1ap7FZLPjnSjjApruWiG3FCu50+Er80EOcv3Un804M0Mc+iQ
         gbNgcfL5o5CLz/lpGNLJVEF9zBwOsBazNfUicfdF43fadO7MgGa20Il6+zsAUO920c1J
         O4ug==
X-Gm-Message-State: APjAAAXT2RQuGVN+HrX6E2XgWR/Q8hIsHMWMv7Uy9nsYLrUVU5e5yxaZ
	XJN7Up1aMolubSPBNMdhhCna765BDBlSmWb9xk+KeB4k8DfW2mf0TRo1v/M72honHyEXC7+NbSC
	i/4Swvrypr1r5hTi/oMqEFlDQ7gYNr7ce83Dd5SNvtkYuIEX40GDJzEZtpneULv2u9Q==
X-Received: by 2002:a62:1d90:: with SMTP id d138mr21591430pfd.232.1553483458673;
        Sun, 24 Mar 2019 20:10:58 -0700 (PDT)
X-Received: by 2002:a62:1d90:: with SMTP id d138mr21591370pfd.232.1553483457867;
        Sun, 24 Mar 2019 20:10:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553483457; cv=none;
        d=google.com; s=arc-20160816;
        b=0YF5sairxGn+zb/mrPb513C2Qnd6us/bwUrrEJqf3AO+CS11d1QYolMtCm+mgoLPT6
         oWPeVJfa5Jlk68fpSgXiDjwB39aX8XjBhCmyYeZPhSlcIsc7ZICgqJPPgPTeyEuasIqW
         UnQaPjdIhTq8O2MQ7QjQ6JHlx5nMHfY5vnKbaQHaP3h+7B3DJrIgilckcCMJg1mUB8+e
         jniYE6n7kCQZ8eT6rgqJ1sPTXToRtBVVeVNiAgImrJhg3k4S2M+ELlImUcPuItwtfBSs
         bq1gsdfV1/cflfYTg0LSZPHShWAM90Uok8UHQ4vgQaAJGtOVaR1Zm2F19fqeggvigmN1
         jq5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=XvFuk1ZULvnL/gHmZQiHeVYELloI7dJAf4pxrQoUf0w=;
        b=pCMxyzKzTWma5YoAPNTMeS9ZiJJfsFhJ/6avis0FaJXk40uMUsZ+lEz4VuTEihQBfu
         624L65ZcboexHj1WFdmCb4jcjqDRNWJXr/oBYax5tG97ktSLk0E59q3LXYLc0eQBfYbM
         j3AUcWxXRx0lPNDSjMyQHAvjt7z5GJevdhKvsm2FLKQJP++lrjDiO1yMleY8gQxzb4x3
         D65qRXCVW9cdZP9Ygw1WFPuO5tC/VpqQkqJ/kPTtbVutYgMwKRhbdpDOKTuR9muayVAE
         0KPGC7ml1CTM5PRuoaggYdyQ83hMgha6i0s+LFfJ1UqSdTB3kCqc9FArLnIVqOz86m9Q
         0Hlw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=QRp6gXYh;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p66sor12444378pga.76.2019.03.24.20.10.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Mar 2019 20:10:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=QRp6gXYh;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XvFuk1ZULvnL/gHmZQiHeVYELloI7dJAf4pxrQoUf0w=;
        b=QRp6gXYhcs1Uhuq8SNRZfOJ+XY5kjThhvW5f2e0yvCJPSST+OUjbFRUhw5gNREYqnL
         oNrr35PCDWTmWS095LfNgQEgt9ieX21a9Q9S1FM29wTD0zRGijyh0TfNL7bwzdOpgbcO
         9ab53+XY3o+fMCLtBOHTo8CE9dJ2F/jcD8W8o=
X-Google-Smtp-Source: APXvYqwhnGXSIS7/l9PxbL58eixk1pzks0Vb5JWmyyrQHCbQt2SQ4cAFRBfjH+FejfgJS8F+3z3Jbg==
X-Received: by 2002:a63:2106:: with SMTP id h6mr20970114pgh.441.1553483457384;
        Sun, 24 Mar 2019 20:10:57 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id h64sm23428744pfj.40.2019.03.24.20.10.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 24 Mar 2019 20:10:56 -0700 (PDT)
Date: Sun, 24 Mar 2019 23:10:55 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Christian Hansen <chansen3@cisco.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: idle-page marking in page-types tool
Message-ID: <20190325031055.GA51047@google.com>
References: <CAJWu+ort=_YTh2B=y7iPuhFGVAP2joJugNrmgg3K0yun4uPFQQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJWu+ort=_YTh2B=y7iPuhFGVAP2joJugNrmgg3K0yun4uPFQQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Ping? Thanks a lot.

On Fri, Mar 15, 2019 at 08:32:18AM -0700, Joel Fernandes wrote:
> Hi Christian,
> I am looking into idle page tracking and noticed the page-types tool
> in tools/vm/. It seems you are only marking pages as idle if the -f
> option is passed ("Walk file address space").
> 
> I was curious why you decided do the marking of idle pages only for
> files and not anonymous pages?
> As doing in the following code:
>         if (opt_mark_idle && opt_file)
>                 page_idle_fd = checked_open(SYS_KERNEL_MM_PAGE_IDLE, O_RDWR);
> 
> We mainly want to do idle page tracking for anonymous regions to
> determine howmuch  of its anonymous memory is a process really using
> actively.
> 
> But I was curious what was the reason you did it this way?
> 
> thanks,
>  - Joel
> 

