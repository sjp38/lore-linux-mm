Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5A85C49ED9
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 14:47:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BAA221D82
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 14:47:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bctqj0dI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BAA221D82
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47C836B0007; Tue, 10 Sep 2019 10:47:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4553C6B0008; Tue, 10 Sep 2019 10:47:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 343986B000A; Tue, 10 Sep 2019 10:47:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0173.hostedemail.com [216.40.44.173])
	by kanga.kvack.org (Postfix) with ESMTP id 14BFF6B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:47:03 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 90F06180AD801
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:47:02 +0000 (UTC)
X-FDA: 75919288284.22.hole29_77a510dbb5816
X-HE-Tag: hole29_77a510dbb5816
X-Filterd-Recvd-Size: 5096
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:47:02 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id d25so38126786iob.6
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:47:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=83TThgQAjkQ0ae/WfN2rozL6NZ6sFqo/tzTJieGwWhY=;
        b=bctqj0dIEQG02DidTblEEKKmlRq95iuCrJbWTEZEFy6f4ldmknD9AC82Hjp7WtIcUL
         wdtgqANYPFpfuqN9RWFoV81S+TL4TZWcW/eRB1zbwCnI4axFiqpnKB/4F9Vb1ASsBmwM
         MoGeD5V7oPXNrI0TLfR8qwBLS/a5rmpBqaVS40yQVLdcqID59aFUJKp3thzSPP4Ym5fo
         oUxnlGZ+RikUHkghsxU4t9MUOUJM1V923cataTV37iHuaUS8taTW2ilbXf8zuGBL2rrr
         GFcYtmHJkRVPpjaQYbMNqFd6Z6x57kRfzb33fCPJ6liqZh8sZLRJMVMsx0Mc0ssKXqB7
         m1dA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=83TThgQAjkQ0ae/WfN2rozL6NZ6sFqo/tzTJieGwWhY=;
        b=muXPGjJ2ch8Xfq4IxBZxCe5mKqD0agod+tKVvIW4Icla+D0qO6p6xVVyx6wkw7zEf7
         TtnQ0b+GO71P0Yzbp1urUsuY6+dCBtsyJboCft9pOEy64pfsCeMwZiL+4AXzxJ0V8lPC
         6wb/tNaD6D6eWOJKnK7FqYfG45BlP/M6jg6WG6hhriRd23eBpZr9EseGkMqFMZV9zaDG
         aVGVQO+DJVlL7SGI0PceZdkupHDuHN9UL9x0iI3FBG3vY/8S5ZHTjq7dxF8LaxSaFbHv
         JgRWBYN8WJaY9Kk1EN3N8fk6FEc74y8IpXGYpLBcOovKx31zFGPWqF+uVJi3v8DQMdpG
         VObg==
X-Gm-Message-State: APjAAAWFVFvW/1KVPXQR+/af4JsZAUBLkJtdebhRcHpMWMulvaY324lu
	zxGb9A9tIhI/zp2Ep3+4GSFI/4bWTT4wDhQ/cpo=
X-Google-Smtp-Source: APXvYqxrAgxnAGDouzK82zOnS/FEXuQVFFiHhPiHvEJcvMSKDH7nqj7q9uv+1GUDlOR7M4uUZTjdaBK0SNIGv69duNM=
X-Received: by 2002:a5d:8f86:: with SMTP id l6mr20769278iol.270.1568126821359;
 Tue, 10 Sep 2019 07:47:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172528.10910.37051.stgit@localhost.localdomain> <20190910122313.GW2063@dhcp22.suse.cz>
In-Reply-To: <20190910122313.GW2063@dhcp22.suse.cz>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 10 Sep 2019 07:46:50 -0700
Message-ID: <CAKgT0Ud1xqhEy_LL4AfMgreP0uXrkF-fSDn=6uDXfn7Pvj5AAw@mail.gmail.com>
Subject: Re: [PATCH v9 3/8] mm: Move set/get_pcppage_migratetype to mmzone.h
To: Michal Hocko <mhocko@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, kvm list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, will@kernel.org, 
	linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Pankaj Gupta <pagupta@redhat.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitesh Narayan Lal <nitesh@redhat.com>, 
	Rik van Riel <riel@surriel.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, 
	Paolo Bonzini <pbonzini@redhat.com>, Dan Williams <dan.j.williams@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 5:23 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sat 07-09-19 10:25:28, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >
> > In order to support page reporting it will be necessary to store and
> > retrieve the migratetype of a page. To enable that I am moving the set and
> > get operations for pcppage_migratetype into the mm/internal.h header so
> > that they can be used outside of the page_alloc.c file.
>
> Please describe who is the user and why does it needs this interface.
> This is really important because migratetype is an MM internal thing and
> external users shouldn't really care about it at all. We really do not
> want a random code to call those, especially the set_pcppage_migratetype.

I was using it to store the migratetype of the page so that I could
find the boundary list that contained the reported page as the array
is indexed based on page order and migratetype. However on further
discussion I am thinking I may just use page->index directly to index
into the boundary array. Doing that I should be able to get a very
slight improvement in lookup time since I am not having to pull order
and migratetype and then compute the index based on that. In addition
it becomes much more clear as to what is going on, and if needed I
could add debug checks to verify the page is "Reported" and that the
"Buddy" page type is set.

