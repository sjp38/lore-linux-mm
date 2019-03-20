Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4A54C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:53:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8997721850
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:53:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8997721850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 045C56B0007; Wed, 20 Mar 2019 07:53:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F101D6B0008; Wed, 20 Mar 2019 07:53:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB3B16B000A; Wed, 20 Mar 2019 07:53:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4F306B0007
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:53:38 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n13so2107721qtn.6
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:53:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BjRVWAY7Yzmi3WdvkMtCHL9KfX1Ez4HAedyVKzdyNF8=;
        b=kGe50SBe5BynBpxyVY2GJqhU9bdKT2b2gJEuvp+Jpt3gkFlcQ7FOMYi/t+UFkJy2QN
         mt/unLSLKBHjEpyhfJTe7bKjacKudCkNk1jxEp0CrOtuBVFWVTUhv/O7NPDfnHD6c5sb
         bKPLKLiMYhB6ieQ0Wvy4wRxPA9ig7mRouGUIQcZZvM+RpdadaU4WdUYLH/17UAP39wH4
         HCJuPUzZ3Iu7xdCm/U2b9a0kaMoaJYnd49Q1EVwPbeH9QsAkX0AgGu4A4VovhtnGucUF
         aiGtaqCbwoPdIEzKYBiXpvyvrnW7264IdmI4kOokR/jAMja3YNHVdo0/0PlYZqmBTLw5
         Gg4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW2banzeSKc4LwkPaB9zrlxUnTO8ThUN7NVUZQe1pO/a6SeReYT
	Thd0wpNdmdZr0qlLwReJlV2PTkAHtH/obvjhsT4KSqQpznVvQmcZ2MsoPDG6JI2ATgLPQHy7Kfx
	1UrlwMM3WUu8djENzu0b7FF70uShBaIoMj76Wsr0oDj0DFLQdVXCTpNmI8J76uEtKgw==
X-Received: by 2002:ac8:28f4:: with SMTP id j49mr6446118qtj.310.1553082818509;
        Wed, 20 Mar 2019 04:53:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGcV8bawRTz3p6yXfvdL+XLJOIEmx+Llw9XENcktqMJegWDX5p6Ri5DUCu+FWiLObjcb4g
X-Received: by 2002:ac8:28f4:: with SMTP id j49mr6446073qtj.310.1553082817783;
        Wed, 20 Mar 2019 04:53:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553082817; cv=none;
        d=google.com; s=arc-20160816;
        b=nhr4x7QP924zlpG0WBgoVSnEafd33XqQZX75Dt9YowE3B0G0smMqEdlljZYXVQUND/
         GQnuHzt7GSgCc2vZ4vAhl42TyuE4J5Ki7d/3FDj5KNMcbAETllLAPWc/Oo3kvb9JTFKq
         4oDC4DiZjoteyPF67CZPC1ZcQoF5cz3J+F243ijxQp/z5VagblNcYZSHTJ3DyIhDohkE
         D85YK9swkQWhCsGm081GTGM9jIZ9rhuwpyOhLq2hHq29bysBnJ6U/blG6eFp/tcjqZan
         aESwvO9KWIWRuoh/6KejVqU1aKqx9xRSeQTSpzmShMGGcUTOuonjeVqasmSukWD8GrOD
         iEtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BjRVWAY7Yzmi3WdvkMtCHL9KfX1Ez4HAedyVKzdyNF8=;
        b=wA0e4c9hj+Z7V00tmZMD6oyT2Ve8mY9t0duDJe8IImyNr2tioo99iu2+rmy2ySXWej
         WI3UAQC1enD5Yqp98x8MXD7YnCwU+KAUA8aijesOtWFJ8lachIrl6XScqjXZLnmuViKU
         9dvt0AoJ1WQP8kBZQp4SS/l88puVut1nX4QX/4a3CtLTDsMgI6T1TeSNLy28MG8xeLHl
         DzqsXkUpr8LSU+xSc2dmFxf3IM4wf9km65AVArfVeEc4GqJsS8kRiC5DSNl3hnC0gS+r
         6GZB2hV0yM/taZ/JnM8J9AoaQ2iIu0hVWHYAgG7LOZD+IoCy5Fxbv8pWxJgfCYlZ5NlC
         XPzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h65si970604qkc.258.2019.03.20.04.53.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 04:53:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D47D03084259;
	Wed, 20 Mar 2019 11:53:36 +0000 (UTC)
Received: from localhost (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1BE516014E;
	Wed, 20 Mar 2019 11:53:35 +0000 (UTC)
Date: Wed, 20 Mar 2019 19:53:33 +0800
From: Baoquan He <bhe@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190320115333.GR18740@MiWiFi-R3L-srv>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320111959.GV19508@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 20 Mar 2019 11:53:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/20/19 at 04:19am, Matthew Wilcox wrote:
> On Wed, Mar 20, 2019 at 03:35:38PM +0800, Baoquan He wrote:
> >  /*
> > - * returns the number of sections whose mem_maps were properly
> > - * set.  If this is <=0, then that means that the passed-in
> > - * map was not consumed and must be freed.
> > + * sparse_add_one_section - add a memory section
> > + * @nid:	The node to add section on
> > + * @start_pfn:	start pfn of the memory range
> > + * @altmap:	device page map
> > + *
> > + * Return 0 on success and an appropriate error code otherwise.
> >   */
> 
> I think it's worth documenting what those error codes are.  Seems to be
> just -ENOMEM and -EEXIST, but it'd be nice for users to know what they
> can expect under which circumstances.
> 
> Also, -EEXIST is a bad errno to return here:
> 
> $ errno EEXIST
> EEXIST 17 File exists
> 
> What file?  I think we should be using -EBUSY instead in case this errno
> makes it back to userspace:
> 
> $ errno EBUSY
> EBUSY 16 Device or resource busy

OK, will update per your comments. Thanks.
> 

