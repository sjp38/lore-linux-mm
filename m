Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A552C28CC7
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 13:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13EDA2085A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 13:14:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13EDA2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A318B6B026B; Mon, 10 Jun 2019 09:14:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BB9A6B026C; Mon, 10 Jun 2019 09:14:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 883376B026D; Mon, 10 Jun 2019 09:14:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 617EB6B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:14:20 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q13so9019082qtj.15
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 06:14:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WkrNbw0hNxqJxWtogtrxEjSqBjUQ8QhzHDVythsl3xs=;
        b=Ri2O8J+zVvlAzYpOmGIX80cdVuhcQ0cHNxbLk3AUrhayFuDl7J2Lxd2eZS8o97xpIS
         pcKwaXjIkk1QB77Ky95Rmwpxj5TmheIjixUQfZjAC31trEJHbM48XEXiCw6l4DZg6/OP
         jDPXiDsQPfXlAyBjwYqeJrgZjZnLqdhGqck+RIThNokVS1zA48cyi0LGFIsDBBozIcHB
         fBWPOjwiMw3cxYnAVKwVq7A9aPLmtcqIRmzMsOoX3tc3ksVRHeEIoGNoQeIJ4KS7g6VZ
         zH08LAkXO9lCoMpxGUyAtNDS3HeeHNqGTO8q31F//D7Ql5uNfmHKA9jxi1FenSZxV7ii
         Ml9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAUMJe5he2cjCxTMaDgVT8o8lgPTsVSMRm7/W9Qzs6X/o8rOVWpP
	PZcHB4OKgK4S8wLgdbpspS/bVmLsr4xlzeSdLy33k3zAWOKfrbSsBZt0XbUOOStxa+hlk8XSGxY
	EVPrOxMnERoy2VCAZZ9989a+8PjXBYmyW9B0fMpdIYI6xlw2Pkt4a4tGB1sCRLMFumg==
X-Received: by 2002:a37:a648:: with SMTP id p69mr41991220qke.136.1560172460120;
        Mon, 10 Jun 2019 06:14:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy28K67I2LJj1pxSM99oyG/N1nY0hRmzACprZdh1FYnk3il705Qgac4wQEtwgQoIa8AOqaM
X-Received: by 2002:a37:a648:: with SMTP id p69mr41991186qke.136.1560172459637;
        Mon, 10 Jun 2019 06:14:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560172459; cv=none;
        d=google.com; s=arc-20160816;
        b=iPguQ1kIbjp5rgCrlU4/QHbIdrdp7xvfqQXQJnL92nTQijEf0Oq6o8WyZXHhbXvaME
         e1/Z9+w640MR/2cQsUdU++LB6OyypXHvYdX4e94UoXeybvnhVaufWuyQ5+dzpJSzlqaE
         PjqWonEf9DP3EfO5xtOfT0h228xV4moanEejlVCWojj26QIRnUlgIMYRZpd3edQ7+zmn
         g7bohdVZZNS3iM9qDNxNTlt00Sj/pcuZIhs1TT2ufeInmPkCBCRfDpTmaWLYsQhlsOkW
         A0GcChW7KeaMZ7PWZcUoxkuGfZ3B9JGTiGkCb2nHSWmV8lYG0V3i6cHSsQxKbBNfkLS0
         r2mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WkrNbw0hNxqJxWtogtrxEjSqBjUQ8QhzHDVythsl3xs=;
        b=kWM+ALUZVAAturA7oZomYjFd9sx3HH0nYecle7q9nn7Tmmy6zkuSMEScS68R/fko1c
         DTXotrZYd9TnMIkAltBegCuWoKa3sHf0INzS1AgwY3AKt0ZqgSoH3MsceUpGXwr1gGHd
         76Sfc9Sv/Osys0KSEXOzJdJ9Gf50AqKXgDihA5uZRP5O99MmF+eScdbnY8XO7rNmp0Wi
         DficVrofs3ytyO5WYlhDDFZT/eXbJpMG1aPp+nGCPoVdnk8zXL8X6NFQmwEe0qz/FmgL
         fP0aUO+sPGmlWPXPQ3QLyhJPNjqC0dU6RtGwDI5Ab2Wp9a7otIhlPUQrX2dvRZrvY0UO
         Y+QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id f57si2134949qtc.247.2019.06.10.06.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 06:14:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org ([66.31.38.53])
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x5ADEILt032203
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 10 Jun 2019 09:14:18 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id E4DDE420481; Mon, 10 Jun 2019 09:14:17 -0400 (EDT)
Date: Mon, 10 Jun 2019 09:14:17 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 1/8] mm/fs: don't allow writes to immutable files
Message-ID: <20190610131417.GD15963@mit.edu>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
 <155552787330.20411.11893581890744963309.stgit@magnolia>
 <20190610015145.GB3266@mit.edu>
 <20190610044144.GA1872750@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610044144.GA1872750@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 09, 2019 at 09:41:44PM -0700, Darrick J. Wong wrote:
> On Sun, Jun 09, 2019 at 09:51:45PM -0400, Theodore Ts'o wrote:
> > On Wed, Apr 17, 2019 at 12:04:33PM -0700, Darrick J. Wong wrote:
>
> > Shouldn't this check be moved before the modification of vmf->flags?
> > It looks like do_page_mkwrite() isn't supposed to be returning with
> > vmf->flags modified, lest "the caller gets surprised".
> 
> Yeah, I think that was a merge error during a rebase... :(
> 
> Er ... if you're still planning to take this patch through your tree,
> can you move it to above the "vmf->flags = FAULT_FLAG_WRITE..." ?

I was planning on only taking 8/8 through the ext4 tree.  I also added
a patch which filtered writes, truncates, and page_mkwrites (but not
mmap) for immutable files at the ext4 level.

I *could* take this patch through the mm/fs tree, but I wasn't sure
what your plans were for the rest of the patch series, and it seemed
like it hadn't gotten much review/attention from other fs or mm folks
(well, I guess Brian Foster weighed in).

What do you think?

						- Ted



