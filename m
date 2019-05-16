Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23A15C04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 07:53:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D791E205ED
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 07:53:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="TuDI+0XF";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="4+Ynej1g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D791E205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kroah.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66FFD6B0005; Thu, 16 May 2019 03:53:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6218B6B0006; Thu, 16 May 2019 03:53:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E87E6B0007; Thu, 16 May 2019 03:53:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4A66B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 03:53:16 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l20so2418646qtq.21
        for <linux-mm@kvack.org>; Thu, 16 May 2019 00:53:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=He5ihOaVJM+Plo3d4jGHJxUuKm1xliYsYWOaqQ0envA=;
        b=F093CAp755Ly9OBGHvha2r2vCOFHH00AmdXHReD1aYEcAJMrktyhj9MBrfra/qqaS+
         +f6NpAQnO2ArGxzDUQKjuw+6bIgUmJJI/DyAdETNeVm/Hqovlv4fUBifI+rUqwT3Wc1X
         dBF/gKdNfRslnloWsfN9hM/b3zGaAj0vi6UD2lkFLMca1X27LvDS8g/2xKF9ukyugRqR
         R/CdChyicdhQvAUOeNm5hzctHhWK5lIBtSwmErYWXago3y3zMiEYEo5Aqe5ujuEnBmpC
         xrw/p9VNsvuUUeQajzffw0HffIiRNwq1m9jlobQnj2oWM/xveNvR3XrvmAWLstd15Wgh
         7ZZQ==
X-Gm-Message-State: APjAAAVgmXsTZjOmPyF6X7BW7oB/af/tfJMtIT7zpLqMyj0cmeABzsJm
	s1Nc+IqRGi1a8REoLFd42ov9tEaL2lKXP7CXsGQSeycpbgZtPDmDrwqeczcsJPMYuxQFXQnB5PO
	rGyQYX6dlCCLi2UlJrahwTuppIq0wBGaPm4mFqtAS31piW+FDd2XPjmph/8UL618jTg==
X-Received: by 2002:a0c:b6d8:: with SMTP id h24mr37557907qve.178.1557993195957;
        Thu, 16 May 2019 00:53:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuQNjFZDmYUO9jz0iWjc8CU6GPvVxUC9wadapKsZslHc44nbhjh/oh3vaJo8KdYarSReKE
X-Received: by 2002:a0c:b6d8:: with SMTP id h24mr37557884qve.178.1557993195419;
        Thu, 16 May 2019 00:53:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557993195; cv=none;
        d=google.com; s=arc-20160816;
        b=YP5+f/08FQ/2DbYaQR0clCtocJq5YOE3niwIgsywO90EPxalLv2IozrT2KktTKJ8bh
         pbYRpC04X3Uc+d0MbU+ADhY0ILetr8HDyhnXowaqxo7IgVnKspxBBf6YsWAmo9jkqsuy
         r2Ot5GAEppx/z8FZ6Z2n9m0a8Zgus3fU22knfrOdXIZotpAfqovQdDvL8AbVaNKmWOr+
         OMQdRxsFpqiMcjSQ9MmaRztEDzJJ4uBpdO9KgGyCzEHsEnTgXGK7iBRVqnWDIyuTFP1R
         MIojZjtrdcifnyhIcWMyz2mTNdWBJfFoeBzvBqsuuJwoh2krOrGJ3ZINM87z6ug1U8Ak
         ZbWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=He5ihOaVJM+Plo3d4jGHJxUuKm1xliYsYWOaqQ0envA=;
        b=a0EbKtyT9sW0KHeyDKNiqpye04xvzTLHrkZ+1AIp0a1I3G23hGEgwTUDvBx1hFd2uH
         Ww5Z5mIYn5FET3IJpv3Ads4IX6wLLcbalNLP3sw1DoxTaG1qKMzMy0rIsaAhdrujZpGD
         /ATb2LxbGDVUvUsgsgHouzYpt31HkK0IOJ0+qtXsj4i2X9xH6BxJ05gmwj8Gubget0uN
         Ll2k8HqHbvQKo3W7WdRyYur/H5gMBpcv1ePxA0JwRNugNZvLEt6GCpu6fREVRHU3C4ZL
         sL39Y8u1z1bnWp/AM/xfwc1VPCZeMGtjGx/WgLT7HHYuumWBeGEw8LErAPT/Tru9Hzw7
         sVjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kroah.com header.s=fm3 header.b=TuDI+0XF;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4+Ynej1g;
       spf=pass (google.com: domain of greg@kroah.com designates 66.111.4.229 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com. [66.111.4.229])
        by mx.google.com with ESMTPS id r11si3165793qtb.372.2019.05.16.00.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 00:53:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of greg@kroah.com designates 66.111.4.229 as permitted sender) client-ip=66.111.4.229;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kroah.com header.s=fm3 header.b=TuDI+0XF;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4+Ynej1g;
       spf=pass (google.com: domain of greg@kroah.com designates 66.111.4.229 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailnew.nyi.internal (Postfix) with ESMTP id 16A5814BEB;
	Thu, 16 May 2019 03:53:15 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute6.internal (MEProxy); Thu, 16 May 2019 03:53:15 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=
	date:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=He5ihOaVJM+Plo3d4jGHJxUuKm1
	xliYsYWOaqQ0envA=; b=TuDI+0XFE8t8180O3v+rB58RTJJ3y43gJzRwdtVSU+4
	Dv+4pTsoYrcWduUmrj/Mq618J6KdZTLc8PDFG74rWo2ihvZucwqc84MkrG/5KvUt
	TdQnDjb7DAg53CkG0VPLBN0HpnsprYu21jAeVjR8WYRopj7nAZ/fMptg1lJBkKj+
	zJiVHbZezd6qLHcYjEnpAui/B0IrLJnvMaX5XG5VO5Be9b++zeSTjBhzF4inNHJx
	F0MzY7cqduS+LJYYYWnOHu5oIu9o1qqUaOE+M6KGjy78WACFJQMNVwBJx7gmoWFm
	AgZiDmmCfKr7maEI201M4+xrJPHHVIqhkG67mrVT+xw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=He5ihO
	aVJM+Plo3d4jGHJxUuKm1xliYsYWOaqQ0envA=; b=4+Ynej1giCxUUBh4tXh420
	pk/bhKQc4kwIzH4pQ4qTOec7EDLUs35E4Y3dU326T+yZ6PPt4GoVyC1VWf41HWFp
	9lVblB6hWxeCuHaZxShsKlBsxjnebfk2akCSYYRMiqAt0/KBR0XBw/H4tWQ/Bw/7
	hkNzxbnD1tysh5l0sAXjwHvlVM5uHnEd0WtNLz6NarGNP+lB0yXk9uTEH4IgFjve
	RsOhLJm3Vz/n+8Zqh2kAnEoRvHUqb8P/Sq8edJyXZuyTS+XjmTseL8bBs8uwICA0
	mltj4yaACtRMn1C+6aoXTsdav5ejNAIVCYBbcQ9QnmY9Kr4X2nF8eWewKmOkWq2A
	==
X-ME-Sender: <xms:6RbdXDxElR21kae1GMvxGoXJi2kfqW86-h7-eLBPjszQ4owQS5elXg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrleelgdduvdehucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhepfffhvffukfhfgggtuggjfgesthdtredttdervdenucfhrhhomhepifhrvghg
    ucfmjfcuoehgrhgvgheskhhrohgrhhdrtghomheqnecukfhppeekfedrkeeirdekledrud
    dtjeenucfrrghrrghmpehmrghilhhfrhhomhepghhrvghgsehkrhhorghhrdgtohhmnecu
    vehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:6RbdXPjqUESiA4ZSSxnQHhhETt9GvPLPAY2D-qyJkgsURjtHOrPP4g>
    <xmx:6RbdXIXI2TcxkepwHpJIWqUltwr3l8uPCIuO861Yq5wTexXJBU-12g>
    <xmx:6RbdXB3ofLEidx_oWgxWqY7wQ3Rg5LARy5kc4BD4RMKweWx0JtRmdQ>
    <xmx:6xbdXKgpagGTezi2xrJu5uBe_HS7U8KmvpVZWjZ1ld_s4PKEPF3iGw>
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	by mail.messagingengine.com (Postfix) with ESMTPA id 4F31B103CC;
	Thu, 16 May 2019 03:53:13 -0400 (EDT)
Date: Thu, 16 May 2019 09:53:11 +0200
From: Greg KH <greg@kroah.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleksandr Natalenko <oleksandr@redhat.com>,
	linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190516075311.GA10467@kroah.com>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
 <20190514145122.GG4683@dhcp22.suse.cz>
 <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
 <20190515065311.GB16651@dhcp22.suse.cz>
 <20190515145151.GG16651@dhcp22.suse.cz>
 <20190515151557.GA23969@kroah.com>
 <20190516074713.GK16651@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190516074713.GK16651@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 09:47:13AM +0200, Michal Hocko wrote:
> On Wed 15-05-19 17:15:57, Greg KH wrote:
> > On Wed, May 15, 2019 at 04:51:51PM +0200, Michal Hocko wrote:
> > > [Cc Suren and Minchan - the email thread starts here 20190514131654.25463-1-oleksandr@redhat.com]
> > > 
> > > On Wed 15-05-19 08:53:11, Michal Hocko wrote:
> > > [...]
> > > > I will try to comment on the interface itself later. But I have to say
> > > > that I am not impressed. Abusing sysfs for per process features is quite
> > > > gross to be honest.
> > > 
> > > I have already commented on this in other email. I consider sysfs an
> > > unsuitable interface for per-process API.
> > 
> > Wait, what?  A new sysfs file/directory per process?  That's crazy, no
> > one must have benchmarked it :)
> 
> Just to clarify, that was not a per process file but rather per process API.
> Essentially echo $PID > $SYSFS_SPECIAL_FILE

Ick, no, that's not ok either.  sysfs files are not a replacement for
syscalls :)

thanks,

greg k-h

