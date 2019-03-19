Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BC66C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:13:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7C9C2082F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:13:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="A46Bnkdt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7C9C2082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99FCE6B0007; Tue, 19 Mar 2019 14:13:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94E446B000C; Tue, 19 Mar 2019 14:13:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83C136B000D; Tue, 19 Mar 2019 14:13:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 585B56B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:13:01 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id z123so18512944qka.20
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:13:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=DxlNuZ7/tO+3WRXUygFzfItTwCwspPcK4riHH/qCBnA=;
        b=AkPArLEZVOss3UG6grlGSOrm/fJc+T6d8ZYwmyrklojao/nNYESMKhz/iT9WSQLbd6
         UZowFc8z5B3MZKOpS1n8VMmUEjLnT2kj8WiiZVDpUU36rM6xjZb4vnu0jyquIXNpwkWe
         d1qfhJ98s9pj0sSKBuVdEFjciVjCXHHh5zQyGdqzRUTyriQPS/OOh3vZ2TAiBKjH0bZ0
         eH8ozZZwgDBlGJgP8zuoawLjKyqkYLbzyRIFOIuUJht1b5U1WAPCFADftOn/6fymAux4
         QdZ3W17/Vv2qFsDUyk/Uyd9pOn9vxOpP2G7VlttT50eOBh+whPpQ/XvK/b/mIANhIuS8
         sgjA==
X-Gm-Message-State: APjAAAWjpcy1q2rKiF72gAaRqZS+OCF/KngGj8/WLK8/tfp1rl7aoeq9
	c1yC19VTauDoZFOV0uQcB8sbXxI+q0niC2xqKOVZOlv3HupBH3l9p5HgI06mfE9ZGCOlvJIRXA5
	rflYifaazccoQ0B9NhP+Qru2F7Af/uNJ26CCDOex5ykAkznisXeh0wXYeFSWGlGY=
X-Received: by 2002:aed:3f51:: with SMTP id q17mr2063974qtf.346.1553019181013;
        Tue, 19 Mar 2019 11:13:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyftW72Edg/vzcqZ0ZSdeBzpN+Pwy8pgefRGvvLsABMq3cq/K9OOYxHhoXip2pCrLFnTjxr
X-Received: by 2002:aed:3f51:: with SMTP id q17mr2063888qtf.346.1553019179936;
        Tue, 19 Mar 2019 11:12:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553019179; cv=none;
        d=google.com; s=arc-20160816;
        b=lwD2WFgHAiYzHtSjTHO6mFo0IF0eGaqjxZ3oC8yvm0uLJpwDVPj8m42oWZ698amRIG
         Co8pmd4eKSdJc56CJ7nSWPw9AV10g16o/jEPTPtTRoSRCUDPAkSga2Pcw60r+0Z0vZIY
         HCMoOpjkdhRJ8T/+oTVRU/6HB3GiAitxOCrnJqrXsTA1mPNqcwnk+jUTYEXDeXmaLeiE
         Iguq8f/aYxxva/WqDp7M255oE1RpvVoon7iOKI1IJMZjNHg3SUFBXyDiI1BthvkRlFsw
         xk1HsLZ7xjnqb8D1TS5d6c+/0Y4sZlyKF34mIcZCTibz14WDY4msC6AZYCx0Rw2ZQXZ+
         ywoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=DxlNuZ7/tO+3WRXUygFzfItTwCwspPcK4riHH/qCBnA=;
        b=ErETprzcznDYhocP8iENp3SBSvhn2Lh2tBnEKsnJDG0lB9Bv4/dBjPl2mmZHGTuXjw
         X/25YNC3kYMFxTHl2/EAxrdV4/odOIeYk79J2PIPf7WysSr9SgD+qIQX5GE+YJ/QbiFw
         InndL6x4M2yj4pjD8wH1lEvfozQ3SBs//qruDYHCxPJ3erQ7l+2OBcLC9s9CJkJr5rAD
         tgRT2NExweftvRf/BG703YdrKtPHvUrE72coTxubdgwvRPd4Asuwb5V14Pc3/FOzeGXf
         d3kQBK4paO2i4dMq4MzWRmLJ6roi2nQ6+eVBIr5XCjvXG5MoJW3pmVwKfqEXrkFqPZEI
         FACQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=A46Bnkdt;
       spf=pass (google.com: domain of 01000169972802f7-2d72ffed-b3a6-4829-8d50-cd92cda6d267-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=01000169972802f7-2d72ffed-b3a6-4829-8d50-cd92cda6d267-000000@amazonses.com
Received: from a9-33.smtp-out.amazonses.com (a9-33.smtp-out.amazonses.com. [54.240.9.33])
        by mx.google.com with ESMTPS id h20si1077159qtb.135.2019.03.19.11.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 11:12:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169972802f7-2d72ffed-b3a6-4829-8d50-cd92cda6d267-000000@amazonses.com designates 54.240.9.33 as permitted sender) client-ip=54.240.9.33;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=A46Bnkdt;
       spf=pass (google.com: domain of 01000169972802f7-2d72ffed-b3a6-4829-8d50-cd92cda6d267-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=01000169972802f7-2d72ffed-b3a6-4829-8d50-cd92cda6d267-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553019179;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=DxlNuZ7/tO+3WRXUygFzfItTwCwspPcK4riHH/qCBnA=;
	b=A46Bnkdtdmw1ltMn1xLWyOXdgUOYb46BJPcX5+Lnzpmzl+iw9iK/mKzOHnS8xekb
	qBAEqY11UPz3FmTGgPlmBnorObUj0CYngAdR9vWBQXlH8VXWmrWwAeWnVOeVTghalEr
	9vsI/0OE7Avr1S5KOrpOHx1UWnZ43Cx2VxgtmDxI=
Date: Tue, 19 Mar 2019 18:12:59 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: john.hubbard@gmail.com
cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, 
    Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, 
    Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v4 0/1] mm: introduce put_user_page*(), placeholder
 versions
In-Reply-To: <20190308213633.28978-1-jhubbard@nvidia.com>
Message-ID: <01000169972802f7-2d72ffed-b3a6-4829-8d50-cd92cda6d267-000000@email.amazonses.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.19-54.240.9.33
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Mar 2019, john.hubbard@gmail.com wrote:

> We seem to have pretty solid consensus on the concept and details of the
> put_user_pages() approach. Or at least, if we don't, someone please speak
> up now. Christopher Lameter, especially, since you had some concerns
> recently.

My concerns do not affect this patchset which just marks the get/put for
the pagecache. The problem was that the description was making claims that
were a bit misleading and seemed to prescribe a solution.

So lets get this merged. Whatever the solution will be, we will need this
markup.

