Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEE7EC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:31:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 974DF214AF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:31:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="aaZrnCaY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 974DF214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32CC48E0003; Tue, 12 Mar 2019 15:31:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DDBD8E0002; Tue, 12 Mar 2019 15:31:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 182708E0003; Tue, 12 Mar 2019 15:31:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D49388E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:31:05 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id u24so1644360otk.13
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:31:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XCKuaXasInyZl5GiIGw6+ShoAqb+pDeTDo/258O+J+s=;
        b=Pa2CzqZNdT2H5Xd+HS0NnMEgd2GulThWU/WdveNSC35shejkvGAdUQhbjukt09N9+w
         eqKeU/+7IME/GHZUpV0noRwKPI2ZvptVpZeUyKn/UQCKzJ8WYzWIC86plEdSTZKtCXbR
         vLOMSq77zWwjuybYbhvyMBO7H6DnK3h5wCdPTz3IKVYTOav2nN8unnTvXpA7ilgR8FO3
         KG9Z44RQnqbxVwj8KaJ16roprWfi3QJUaZpNkR65LRajjPK/7h0RTWcjtmtLCYwuwiJY
         P2jGW8bLKARLYsQam6BVEJ0b7kLlAGSV2VE6KkQQWdbQTFkfa2COgqJKxPPgFmb6Q9cE
         PM4g==
X-Gm-Message-State: APjAAAVDjhXqL/KFjh2bifemRmcJzUNXNPLuLvO4l/z1G+vhX/sbNidA
	XLG33B226UJAlypwJgs9ixiTbQ1qzX1RJN0jyL9koCr4CuaMOBatUP39inNozdZPcZMh/XKsPON
	3vHpinLdRa1oI73AwY/BbXqo4EsBrIVMKgf7N4JCZKm+TfSyQrRFrs8cru2X71TaO43lbUL0f+X
	mzSimvEZauhnbrapSIbxhcQP/7LjuSLH2gariB2rpV5YCpbdGo7ltxYAGLX8SXQRxBqjsfkSgb9
	TjAb4pPz6euaRbgl0p3HxdhgSUueo5//s3yi8XTYfF6FPIZHRr6IIvAg68eXq8mUM7YOD33ybjm
	iOy3xH4vwiUSAzAr/R5E1tHaVyevXgIrJVBrQk7ydab8pVdivtl/8fWED4geByFZ7g+lUSKNjNl
	k
X-Received: by 2002:a9d:4e81:: with SMTP id v1mr3469418otk.134.1552419065318;
        Tue, 12 Mar 2019 12:31:05 -0700 (PDT)
X-Received: by 2002:a9d:4e81:: with SMTP id v1mr3469370otk.134.1552419064470;
        Tue, 12 Mar 2019 12:31:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552419064; cv=none;
        d=google.com; s=arc-20160816;
        b=BLrAkKnRzsIIrdw5gMI9pNnplkb6dCnrKiLA9RiOCvDn411BQ/eC7kSj7G5r0RDtYa
         hrgZAY3O96NJ7Ku0HTWMZAZCQMIve0ocf79xVOcO6g5fRLLhmzo1J1OLmt+UQODWhGZy
         LvQ0C2Osgp8aHTsMBPWr1Nk+taL4bCafhqvKmqyaduJtnz4X0i/XxvJy8mYq3GMXqdZ2
         HhDxTgybYpa0sOTYW1nOTPeTLoHq8Rh8NkIw3VdzhB4vi/qOEMpjC/gMZ8uUq/qUsgX/
         lUfRsJ7E3Wq4inZrAq9sQCGtkL5ECyHN9HoC7UBQ7ozHT+WWPLZaJHa8XljdMVhaIXe7
         A+Xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XCKuaXasInyZl5GiIGw6+ShoAqb+pDeTDo/258O+J+s=;
        b=VLv3O5VM+REulGXy8IJW9DiCLeT4gIJfMvTGM6PXAtRFFMC0ZVPHJWbqGg95f3MBUB
         Tg+7KJ/6IM5c/8qGWPW2+KIxdbcFq7czik9Wl5cmiiqpem4He0u0GKeLu//rS4CL5Ok7
         4cx3r0uAiNLj/h9uSZndqQbznrscabP7AjQmx3k+5DL/R/agetrriM92SekmG/R1aIh0
         LVht9DlWcoqJ2QDvLNp1bI3mTt7Xk6XN6pSLwxy/qXcoH+wmYGlS3S3r0YRlR4dpCzBz
         TYMg6KW4gZU/fyhgZxXcZUAIU5k1OCaMSwtuoFrFU4J6+iRhvzNDn9DlaRacaVVwX6wk
         bwpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aaZrnCaY;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor5683350otm.137.2019.03.12.12.31.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 12:31:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aaZrnCaY;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XCKuaXasInyZl5GiIGw6+ShoAqb+pDeTDo/258O+J+s=;
        b=aaZrnCaYTLt0RYKeA1mT2jq147TnGieDsKfSmCOabF+ag/V9zZu3Z9rjPtFQMkyL3m
         vGIPOx57IKwa+mguf5PHR07VjGyGKP7v/3U50kc4lLbWIZTosS27nPntElu5mQS1nd/0
         RXfjGLJXEDOPudFPjRs8Dv8mhDYZGeGOl9jhwfqSJ4QWvCMAkBu4/mSu24ke4TLlSSyj
         Yvz69kUbofBql3NvNhgV4mYDA6PsaZGC3ZNK+VVinqKd2nBuMFtV2xSqU94sbksdIHRA
         OYbBzWZbAJDsUA4kQ9iQtE8uWmVSEj+7pemmLPq33j2Ryd7j8ewfgurW+6L12BJWIeXe
         YVLw==
X-Google-Smtp-Source: APXvYqzaZ0pn7vQLeSVVuC+Fghss0kQfa8oYKwGYgI34ZBSi0MNQyvFY/HbJN2QTk5CdoNqtXzHYu2TUgGa5wlhBDQA=
X-Received: by 2002:a9d:760a:: with SMTP id k10mr918574otl.367.1552419063760;
 Tue, 12 Mar 2019 12:31:03 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com> <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
 <20190307094654.35391e0066396b204d133927@linux-foundation.org>
 <20190307185623.GD3835@redhat.com> <CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
 <20190312152551.GA3233@redhat.com> <CAPcyv4iYzTVpP+4iezH1BekawwPwJYiMvk2GZDzfzFLUnO+RgA@mail.gmail.com>
 <20190312190606.GA15675@redhat.com>
In-Reply-To: <20190312190606.GA15675@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 12 Mar 2019 12:30:52 -0700
Message-ID: <CAPcyv4g-z8nkM1B65oR-3PT_RFQbmQMsM-J-P0-nzyvvJ8gVog@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 12:06 PM Jerome Glisse <jglisse@redhat.com> wrote:
> On Tue, Mar 12, 2019 at 09:06:12AM -0700, Dan Williams wrote:
> > On Tue, Mar 12, 2019 at 8:26 AM Jerome Glisse <jglisse@redhat.com> wrote:
[..]
> > > Spirit of the rule is better than blind application of rule.
> >
> > Again, I fail to see why HMM is suddenly unable to make forward
> > progress when the infrastructure that came before it was merged with
> > consumers in the same development cycle.
> >
> > A gate to upstream merge is about the only lever a reviewer has to
> > push for change, and these requests to uncouple the consumer only
> > serve to weaken that review tool in my mind.
>
> Well let just agree to disagree and leave it at that and stop
> wasting each other time

I'm fine to continue this discussion if you are. Please be specific
about where we disagree and what aspect of the proposed rules about
merge staging are either acceptable, painful-but-doable, or
show-stoppers. Do you agree that HMM is doing something novel with
merge staging, am I off base there? I expect I can find folks that
would balk with even a one cycle deferment of consumers, but can we
start with that concession and see how it goes? I'm missing where I've
proposed something that is untenable for the future of HMM which is
addressing some real needs in gaps in the kernel's support for new
hardware.

