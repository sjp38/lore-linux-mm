Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C395CC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9663321783
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:55:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9663321783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lwn.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ECEC6B0003; Wed, 19 Jun 2019 10:55:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09D0D8E0002; Wed, 19 Jun 2019 10:55:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF4668E0001; Wed, 19 Jun 2019 10:55:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B61976B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:55:01 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 5so11847228pff.11
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:55:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=tcZNwi9G4Yk7hT5LwUqNQZcxMc6PC6VOvhWu42ccB9w=;
        b=YQ+LIZg2i+ISJr9dO4FWlyPOOxj6uIqjRA/Uh3MKnPMnRBLxyr31QZnD0jM//vM0Id
         XZsKltNkR38o4D51lxwQD9SSuRVWfOi/VjhnO2SHecD1b2gyErOxQXCFTCAOlJWDQETn
         BtRs/3jysjf6lVkdrBuVs6EFXoS3vvzeXi/+CooZrMI4S+Nj+ZtIWZB9eMsw+psRqFN7
         lIfADQgNXiVGgkWBaCqm2tWgGapr5uWc4/DbDDzgYt0jk6PAW+dtiRgu2pIYCfZLYwqG
         zv04lzpYnm7/Uw93bTyCESUs5kp5XhCCx9OyI8aSz9BX7+iIz7bYv2kTbKUnDaMHx8Zn
         /gqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
X-Gm-Message-State: APjAAAXpPS0WNOc+3VaksM4mrem7/FO1KuG3NX9WgcezWSGs80rfSREI
	AQZ1Vwh3YjSes/unS+WJIdvftTZuBEPf+P7uVcRXt1NAQgRnShFOn4Fs9MnT1BYt2DX3hplcDU4
	vE8ck3uy2GqUpiqkiVMYx3F6UANfVDMiBoAXWzPfzct8VWhfn7ByXDwiWKU16bySGHg==
X-Received: by 2002:a17:902:6b07:: with SMTP id o7mr97135525plk.180.1560956101421;
        Wed, 19 Jun 2019 07:55:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwa3+1iH48pjt+A5mvL3IlxV+tD5CR+iQjfg4L9P12PLhCeI7UnHxAFr+436tf+T63oj1yF
X-Received: by 2002:a17:902:6b07:: with SMTP id o7mr97135466plk.180.1560956100716;
        Wed, 19 Jun 2019 07:55:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560956100; cv=none;
        d=google.com; s=arc-20160816;
        b=CidhLd4l33GGYmtGNq3w97HjFf8b1r5AZrvg5xh9m8zikHv7TbL1hYnT+9oQ83lRKi
         MgrKOUUsA4iheW0tFzgJGy0PH0DdFKFbg4Rm111rjTo3QffLOOZYWyVkmgqyitZulxz+
         X3aIV1w7VeuEFTrlq/XeSrGH2bWYCGWOtprqFn5sUHU851Zov5xLQvLu9dSFsBvKLxQ8
         V2zHWZ45aZCi84YmiaQnHUwy/jFkZ6lgYEx6dg8baNwY/Eqa5NEmnhecDye4Hj66kZ4e
         vtNeX5aRd8Ie4c2M3r3QcMYxuEhWyV3fg+GeZxRuTVzSZfYwKHz15vX2S3RaFRZhfv13
         aFpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=tcZNwi9G4Yk7hT5LwUqNQZcxMc6PC6VOvhWu42ccB9w=;
        b=ZM/99eVjv7AujFIDmF0u4tXstAceZ1cAjzM8c1OWEI2yDP0LO9APDK6QINCn+7Vf7l
         u+sEiOERnq0wTGJ2wzsUreaxVykKVbEKc3sgmZx4Ecsimjvu/uryA8sGnFmto2Y9br1D
         Zu4iA1HnwvS02CPjkM+FXKEqfsMHPPxxpGtqaLr4PRgDqK/npKl/HnnBRiVqs5z8lWIr
         tj78vqCjnbeKZgAiTTO1LpgyNX+UTwl17+OYMWLWTXdTo4avdhaR9go64e8HREl1tNyZ
         2n7NhxZQr7W/cMgj6cez8m0FMYCT4hKl9ONVIR3j/I9m3PaCYQ/wFSacFJ+29GN9c0up
         4Taw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id s13si13616719plp.235.2019.06.19.07.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 07:55:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) client-ip=45.79.88.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from lwn.net (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ms.lwn.net (Postfix) with ESMTPSA id EA3012BA;
	Wed, 19 Jun 2019 14:54:59 +0000 (UTC)
Date: Wed, 19 Jun 2019 08:54:58 -0600
From: Jonathan Corbet <corbet@lwn.net>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: David Howells <dhowells@redhat.com>, Linux Doc Mailing List
 <linux-doc@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main
 dir
Message-ID: <20190619085458.08872dbb@lwn.net>
In-Reply-To: <20190619111528.3e2665e3@coco.lan>
References: <20190619072218.4437f891@coco.lan>
	<cover.1560890771.git.mchehab+samsung@kernel.org>
	<b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
	<CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com>
	<11422.1560951550@warthog.procyon.org.uk>
	<20190619111528.3e2665e3@coco.lan>
Organization: LWN.net
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Trimming the CC list from hell made sense, but it might have been better
to leave me on it...]

On Wed, 19 Jun 2019 11:15:28 -0300
Mauro Carvalho Chehab <mchehab+samsung@kernel.org> wrote:

> Em Wed, 19 Jun 2019 14:39:10 +0100
> David Howells <dhowells@redhat.com> escreveu:
> 
> > Mauro Carvalho Chehab <mchehab+samsung@kernel.org> wrote:
> >   
> > > > > -Documentation/nommu-mmap.rst
> > > > > +Documentation/driver-api/nommu-mmap.rst      
> > 
> > Why is this moving to Documentation/driver-api?    
> 
> Good point. I tried to do my best with those document renames, but
> I'm pretty sure some of them ended by going to the wrong place - or
> at least there are arguments in favor of moving it to different
> places :-)

I think that a lot of this might also be an argument for slowing down just
a little bit.  I really don't think that blasting through and reformatting
all of our text documents is the most urgent problem right now and, in
cases like this, it might create others.

Organization of the documentation tree is important; it has never really
gotten any attention so far, and we're trying to make it better.  But
moving documents will, by its nature, annoy people.  We can generally get
past that, but I'd really like to avoid moving things twice.  In general,
I would rather see a single document converted, read critically and
updated, and carefully integrated with the rest than a hundred of them
swept into different piles...

See what I'm getting at?

Thanks,

jon

