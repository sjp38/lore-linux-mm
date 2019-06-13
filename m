Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9CF3C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:26:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E27320644
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:26:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="KHbKhiCE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E27320644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07E7F8E0004; Thu, 13 Jun 2019 12:26:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 006E48E0001; Thu, 13 Jun 2019 12:26:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E105F8E0004; Thu, 13 Jun 2019 12:26:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B62938E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:26:07 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 71so9496752oti.2
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:26:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wjBnZv2pCLDEwG4yb+2F3joyqEyCgCcLuoiul4+lDtg=;
        b=rNA4PGyWDHUKASqIkmGPd3TvvyKphGzR/6rFoK56UsH8j/Z5nAo4uTlSDOeQdN6bP9
         hpiszy4PJ4StIhZfofTXpi+x3EwDWrlUpXQu5L5nHFlGkQbEhF6LeQxELmt8/Od3jWWZ
         JOvB4WISR3/+JE5UYuIijg/82CSQNV0VerShaJgHUV1Phb7Y6LLlfka3iX+p8A5R6a0p
         7e4TCRxZYqN2G4SMxZssao5to0ULwGOfE4iiesOwL22s7NxviNL+p9wIe/28MoZlYIpU
         iuAajoTtiMA9DsZrg2bDm4weQJznQVx8tOEjT5ipdhSRTslyTQoSkfz+tJd9GhMUNODQ
         blkA==
X-Gm-Message-State: APjAAAUhD0U/+4Za9PLv3BW8SA160SAdkp6GKOZ5cnJmrWHAV4oVPzUi
	fO9uC6xrgrmK3umHb6iWHt9wJRTLmxQie1WS8T4fWdI3NSNYLRMJaSZuETrZt9ltFLaekDCIOAI
	/f5Y+cXaZnr8eQtvpTHL8CO2ZDgaHPCosyxf6KAbUEEAEVtF6wypE3zT3U8/nTeDfGg==
X-Received: by 2002:a9d:634d:: with SMTP id y13mr41741453otk.291.1560443167325;
        Thu, 13 Jun 2019 09:26:07 -0700 (PDT)
X-Received: by 2002:a9d:634d:: with SMTP id y13mr41741361otk.291.1560443165703;
        Thu, 13 Jun 2019 09:26:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560443165; cv=none;
        d=google.com; s=arc-20160816;
        b=xdBn3xjdhF7P+yzGGWtHVQ1gW3N5LOJQuv+I0KaYZJyyVzw3urhK38gs7ACgLQ1mfZ
         bz5bYDzj7ldsRra6RZTGXsQ9N0vsXk/xso5Lpp+N2R28KuLSsJEvqpZcEUkr0j+fjHVa
         6/Ewgg4CZDQKukNSx/o69P2iHg3QilwethpQ+/c6yV+FUOHGHYMbF+1JE1v/gLfSAQlC
         fV9LMC5zU4vChzNhfCEk61qq4RpmpQzUAlK313n0RmShZQoD1PH1fhBPgP+4C+9KSEck
         wYZ7jkuiTTBwozV+bU/j2TP435MG0yDYpIAJAlmwjA5vS24GiOg3Mf2Bp3vkjVRmVRVa
         /84w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wjBnZv2pCLDEwG4yb+2F3joyqEyCgCcLuoiul4+lDtg=;
        b=ltSzTR0az0bVb1x2MDuxN6wFrCtyONRWjZE8mzogWjHaoZVNRuZ6k+LBMaf3N1B13B
         4YwJwLZnq4xLYCCwB4OwkSuLYwFDCbabPhPYYOr+Aa3AJZM5UPOYPojjoc0CX58uWzbm
         vmERpb7LbJ7nzk3iLkM0nZb2JzT8yis3p81xGhytpdknQO22r834eRl6jVh0GBAMCC/H
         DUpZGi/KNrWrBBLGYbsc7ZMkbe4dyxYL3XuFjCedxKXmKZo4iUeaCR2NT2jC6VAz88GM
         xz8pjr+q2mJHz0xYHXhIDQwhTRNrA7yc6KaPC+ayZRP418zPn1/cmpG6XsrYk/Y8dcn6
         kh9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=KHbKhiCE;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o188sor44206oih.142.2019.06.13.09.26.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 09:26:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=KHbKhiCE;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wjBnZv2pCLDEwG4yb+2F3joyqEyCgCcLuoiul4+lDtg=;
        b=KHbKhiCEqP27YRm90NCLuB4c2IplNhmcOcBL7/TKZlk3SiaZQfwA9S0uY/GsQv03Pr
         aBL2AWfi8XTIFaky9LKQqE+K/NfNYYNrlmFC/I9jOaxHcs4tAfHfjcUQbqcl3RnXxild
         Tu3HngJ2BWQbjHKSA518A7LMdZsRAI0y2xoRezHhz45e3uyBcpgMb0voTy98I6u2hRnp
         NYEu7LcFVoYX1llZ3PhX+HJY3OdLwk1vk8E00NF1S8iWedYKuEKJl7E8AOFKwK6O5TC3
         f4HIkh3G/dWUfgrFHj9h1Gd+qxz3edzqRbXtlNTkaPme0fjX3JDzh/8PrIf6qw6dZLSg
         gtaQ==
X-Google-Smtp-Source: APXvYqyIpO3hOidIsXLbc4Y7aCrEkKlPPSiQhXNkmA/XJwYbaL526BswBcBQAMtK33IEuzEN5c+1wA+6c6zViqiveWY=
X-Received: by 2002:aca:7c5:: with SMTP id 188mr3423005oih.70.1560443165189;
 Thu, 13 Jun 2019 09:26:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190607121729.GA14802@ziepe.ca> <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz> <20190612114721.GB3876@ziepe.ca>
 <20190612120907.GC14578@quack2.suse.cz> <20190612191421.GM3876@ziepe.ca>
 <20190612221336.GA27080@iweiny-DESK2.sc.intel.com> <CAPcyv4gkksnceCV-p70hkxAyEPJWFvpMezJA1rEj6TEhKAJ7qQ@mail.gmail.com>
 <20190612233324.GE14336@iweiny-DESK2.sc.intel.com> <CAPcyv4jf19CJbtXTp=ag7Ns=ZQtqeQd3C0XhV9FcFCwd9JCNtQ@mail.gmail.com>
 <20190613151354.GC22901@ziepe.ca>
In-Reply-To: <20190613151354.GC22901@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 13 Jun 2019 09:25:54 -0700
Message-ID: <CAPcyv4hZsxd+eUrVCQmm-O8Zcu16O5R1d0reTM+JBBn7oP7Uhw@mail.gmail.com>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, "Theodore Ts'o" <tytso@mit.edu>, 
	Jeff Layton <jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, linux-xfs <linux-xfs@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-ext4 <linux-ext4@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 8:14 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Wed, Jun 12, 2019 at 06:14:46PM -0700, Dan Williams wrote:
> > > Effectively, we would need a way for an admin to close a specific file
> > > descriptor (or set of fds) which point to that file.  AFAIK there is no way to
> > > do that at all, is there?
> >
> > Even if there were that gets back to my other question, does RDMA
> > teardown happen at close(fd), or at final fput() of the 'struct
> > file'?
>
> AFAIK there is no kernel side driver hook for close(fd).
>
> rdma uses a normal chardev so it's lifetime is linked to the file_ops
> release, which is called on last fput. So all the mmaps, all the dups,
> everything must go before it releases its resources.

Oh, I must have missed where this conversation started talking about
the driver-device fd. I thought we were talking about the close /
release of the target file that is MAP_SHARED for the memory
registration. A release of the driver fd is orthogonal to coordinating
/ signalling actions relative to the leased file.

