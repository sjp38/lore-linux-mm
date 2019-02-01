Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF02CC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:51:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8955F20870
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:51:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8955F20870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F361A8E0002; Fri,  1 Feb 2019 09:51:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE62F8E0001; Fri,  1 Feb 2019 09:51:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD52E8E0002; Fri,  1 Feb 2019 09:51:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 837CF8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 09:51:42 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so2961699edc.9
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 06:51:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cWWsySVqVJcS9DQ5I505uxTYUzB2XeZQfGnfzZLFOVM=;
        b=RAzlmtezcxy4zt6zmcI4ZIMZ1DnI7qgsPxKzlaEHblVBMEEAjmiKCO4lytqQeKy3dN
         qZxPRDwoAvs0oKjt7GFFdhko8MEDV9d0Rzzq+jTWSeHs6mRLuw2FTjZzGmy4Vx+3dVmN
         StBmBlv0UQmulrIwYmAjb2Q9hveGaxFZll8AWlKGkV/ap6MxcAq8AW3HCIvWg83553GR
         F1ziA/K7kdl7rCMgZooDTtBnGTthU5umkG/54eO2WcG+HlkHqOQhtlaeWZFSYzq+P6/0
         Ug/jHmcBQjcMyY17CBnmRnZn9QrIUZ6/Is5wXdLcj2MYmU7wSf+eAGdWV0pqQevAgJHS
         neFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.193 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AJcUukdPi4LW3gsUC4rLhlqdEnVpY82Ms87OJYIqwywtkizuwxYbW0B9
	W4LmuPkrYjBjjHtqH9yaZgs54pBxryFhDCQam2tqqbX4AdwPooaPyEIUknMPFW0dEYQXN1kCUgW
	LH9O2rHqehzX5FRZwSJwS9zGoqHbOgXGcaOKlRlg+OOr5UJvLlIRk+Idm/b+pCt6xUw==
X-Received: by 2002:a50:f098:: with SMTP id v24mr38998372edl.78.1549032701993;
        Fri, 01 Feb 2019 06:51:41 -0800 (PST)
X-Google-Smtp-Source: ALg8bN77isNKWWkZR+FLQsTZIrMnBUds1GJCaprY41dx3kYvVaIO5uB1K4JyDlMXhnSTLFUszKbi
X-Received: by 2002:a50:f098:: with SMTP id v24mr38998315edl.78.1549032701124;
        Fri, 01 Feb 2019 06:51:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549032701; cv=none;
        d=google.com; s=arc-20160816;
        b=buyYbNNp5nr29mmSHC17O8csItIyjnuPhkz9Jwy2InrGsbLA7dNsUxSMtL7a3UgjOy
         jKN4lq1RciOhkNmHN7LFtz9qnC4qXRrsvsLhV6s9BSQ3AlXSgiwrV9+tIfY7i8OcL7vs
         ckWbACdhs3CHBj/MgZ8tNxnvQDfP+4o4tXd2h/yt0GP+Z4fZUtERxihKMvDF9rW7Qgzj
         EQVe/QwJmio581CwHu+tItOdJncKy1UjTwrZuqlqvnLQ9T2p12h6dI8HafF65/ZDHyZC
         uOzudjzQ8U0fQm6QBM/dJhpxQes/A85quwobFE6KEnpSeAuYkvG9G4fQyvwI//NnQdEK
         kkcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cWWsySVqVJcS9DQ5I505uxTYUzB2XeZQfGnfzZLFOVM=;
        b=bZHuj8FbhKpHweZlK4BJkkRpI+ocIOuZI0FjgtkKoQaEQ//m6oMzXt4MTOTBEqx3yM
         qJYpudDp3cOND6Z0tkw1eIDaoqI4gbOO20bDVURVjoazFO2J+owJcX57XQgqJQOb/bKP
         TcQECuSyCs38eal127Q+F2TK/p18f/XzTj1V0bjiLYDrwkRTDFxqffFIH4DbiHJG4bgL
         PoofwCv38ng/6FebW4u6wuFksBoKMaf4yD6B/CqCCf+4OZkzX+2JrAHER8nWIZAbSqp5
         A3hziPAhWHNJ1Sp+EPDUgUXLGZyHdUoqRm7wcDo66QF79ruXMtOyIFetUzDag7xPRhpb
         +BEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.193 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id l6-v6si2111811ejg.6.2019.02.01.06.51.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 06:51:41 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.193 as permitted sender) client-ip=81.17.249.193;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.193 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 9D6D6B8736
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 14:51:40 +0000 (GMT)
Received: (qmail 4119 invoked from network); 1 Feb 2019 14:51:40 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 1 Feb 2019 14:51:40 -0000
Date: Fri, 1 Feb 2019 14:51:39 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH 11/22] mm, compaction: Use free lists to quickly locate a
 migration target
Message-ID: <20190201145139.GI9565@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-12-mgorman@techsingularity.net>
 <81e45dc0-c107-015b-e167-19d7ca4b6374@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <81e45dc0-c107-015b-e167-19d7ca4b6374@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 03:52:10PM +0100, Vlastimil Babka wrote:
> > -/* Reorder the free list to reduce repeated future searches */
> > +/*
> > + * Used when scanning for a suitable migration target which scans freelists
> > + * in reverse. Reorders the list such as the unscanned pages are scanned
> > + * first on the next iteration of the free scanner
> > + */
> > +static void
> > +move_freelist_head(struct list_head *freelist, struct page *freepage)
> > +{
> > +	LIST_HEAD(sublist);
> > +
> > +	if (!list_is_last(freelist, &freepage->lru)) {
> 
> Shouldn't there be list_is_first() for symmetry?
> 

I don't think it would help. We're reverse traversing the list when this is
called. If it's the last entry, it's moving just one page before breaking
off the search and a shuffle has minimal impact. If it's the first page
then list_cut_before moves the entire list to sublist before splicing it
back so it's a pointless operation.

-- 
Mel Gorman
SUSE Labs

