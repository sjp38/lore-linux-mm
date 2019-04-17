Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A580EC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:27:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FA9320645
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:27:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="bZjJwk3b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FA9320645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 102856B0005; Wed, 17 Apr 2019 09:27:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AFED6B0006; Wed, 17 Apr 2019 09:27:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB9DC6B0007; Wed, 17 Apr 2019 09:27:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C77626B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:27:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id a15so20651373qkl.23
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:27:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=YqX4IqwhOKtdQgwoSSH2ORlPh0JlcO87zSizgsZDkE0=;
        b=kg6zdPgsrDq8JzkTnzGnvUY1t5sIvXF86szyV54g6tvVFzMS2MqZzNJdy5LB+phVd8
         k5vws2CW3ccd3p9H9MSUORPaJ2Pl+iSrMLgFYnHzQDhy+eJpIOfxQK/nRnHIHX08FSPn
         SMnLYEtYi0v60QIG8kX8FFOr3saSC4bg/u454o+Uw6S31SSorcCdFwF1bGnKnCGlOMz/
         26aQnup/RqHrV1zd1FegCMY+qhtsI8wP5uRqiu11hfSV245I/VgNpvYwCYn0X1aZ5b+A
         gBZSL9rM95Hu4g8TN5Qd2dwH7P36xtMvHSQf//OkaohpqALmSLeKRO6wRWsooZgw+u5Z
         ZSNg==
X-Gm-Message-State: APjAAAXUdtNh4sFKUpwN1JLcLuFkbEKn4xIZGxfeZYil+H4UV7TgPRkc
	S4le8NEWI9WQPJ/Ajls4nFeuS8y9IYsoDw9zCRnCwg5dDNi2Bz3jIYNDd+5zYWS98AWeWfViuTM
	/bncGiwQDplIGK047Ok6x04UQU1Inkqgiyz8hz6mv/wTADCCaDmZU3CB0rnZDzi4=
X-Received: by 2002:a37:4897:: with SMTP id v145mr67427803qka.268.1555507664446;
        Wed, 17 Apr 2019 06:27:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAAHTQAobc4Zc5ny1ndP6YvEe7jlcJQ3K+DmeBN0l7mY5IwPhWJZOQy23+oSdbaVN7hnFd
X-Received: by 2002:a37:4897:: with SMTP id v145mr67427764qka.268.1555507663894;
        Wed, 17 Apr 2019 06:27:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555507663; cv=none;
        d=google.com; s=arc-20160816;
        b=CiT6YrB0DH47qS17zd9otctPRku259FrNMEVJ/Ph1IeAhZI41ectzLPxpwe1cOHhEu
         z/Aqao+pc2glLTtYWXrYUf+v2j4txPIIVdsCnw+Zpcngms/PDSJpUw2v4HthXaRLHbjf
         ou+S67+lqvTLACqcJR61TylqR+NpcnV5e5v7UYbCU0G7Spjwy+eP1WBxS8LUxBO/OHjF
         x2tcuixhRK24/EMni0xKoLJ5UwpmZRcFAn/4SXsPHBCS0dH924cQ13Ddr8F8SIi956xo
         idq+vPyhu7nVg8wKNkedsDDkHWbDXyak8LNorgmF5NhcbzuBqZkNYFj9lRxA9d/ejhYt
         zQbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=YqX4IqwhOKtdQgwoSSH2ORlPh0JlcO87zSizgsZDkE0=;
        b=fuiHrUQr8f6NqkOl3KnXDqzpQBE36utvRYfgTYIH82NK6eNcvyDDi+Y4RL6qL+G8dQ
         W3EilC3WkaCfS/FdjjvzKlfCCq8/htE6NHvmYF4RT8PVGprSY7ecYESpKYL52gXD3RiZ
         xlgN0xbnx382ie9GPv26XDMHk4c01P/2f3fbw8oCXuaCrPf4XgIqZriPYJy2lxi1TEMR
         +ZGmccbFPy+1pV8VRwvvt9w1CP9RbW7DLqD693joZ+867iC5DLfJwoubE5Avrc313L96
         vJzhOemoUQW8mR32JU5X9HfxKMTugyeWKgASvxYM5MlL7/fzCehY5FdJjtMHKwFDKXsI
         u0bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=bZjJwk3b;
       spf=pass (google.com: domain of 0100016a2b7b515b-2a0a4fab-6c9d-4eeb-a0c8-d3fffbf64e55-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=0100016a2b7b515b-2a0a4fab-6c9d-4eeb-a0c8-d3fffbf64e55-000000@amazonses.com
Received: from a9-33.smtp-out.amazonses.com (a9-33.smtp-out.amazonses.com. [54.240.9.33])
        by mx.google.com with ESMTPS id h12si3066951qth.5.2019.04.17.06.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Apr 2019 06:27:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a2b7b515b-2a0a4fab-6c9d-4eeb-a0c8-d3fffbf64e55-000000@amazonses.com designates 54.240.9.33 as permitted sender) client-ip=54.240.9.33;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=bZjJwk3b;
       spf=pass (google.com: domain of 0100016a2b7b515b-2a0a4fab-6c9d-4eeb-a0c8-d3fffbf64e55-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=0100016a2b7b515b-2a0a4fab-6c9d-4eeb-a0c8-d3fffbf64e55-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1555507663;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=9pePXe16Pm2sxz5+PY34bI9W90zEIcb20PpoSEOxJTI=;
	b=bZjJwk3bVTXsr1+Ka6SqEQZ7tpn+LdSlTg8zXZXM2NSPN/ix4m4ImO+nk8wNWLgb
	f/EueiAV+rbhBF2JrWPmqKMZlIqnt44dbCE+dTsKw0nBaY9UbpaRrDCN/LPrmaRXtsb
	GaUIudJugC+DttqYbbZvPaU9Vj1fQfjqcOT/JJY0=
Date: Wed, 17 Apr 2019 13:27:43 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Jesper Dangaard Brouer <netdev@brouer.com>
cc: Pekka Enberg <penberg@iki.fi>, Michal Hocko <mhocko@kernel.org>, 
    "Tobin C. Harding" <me@tobin.cc>, Vlastimil Babka <vbabka@suse.cz>, 
    "Tobin C. Harding" <tobin@kernel.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, 
    Qian Cai <cai@lca.pw>, Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Mel Gorman <mgorman@techsingularity.net>, 
    "netdev@vger.kernel.org" <netdev@vger.kernel.org>, 
    Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
In-Reply-To: <20190417105018.78604ad8@carbon>
Message-ID: <0100016a2b7b515b-2a0a4fab-6c9d-4eeb-a0c8-d3fffbf64e55-000000@email.amazonses.com>
References: <20190410024714.26607-1-tobin@kernel.org> <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz> <20190410081618.GA25494@eros.localdomain> <20190411075556.GO10383@dhcp22.suse.cz> <262df687-c934-b3e2-1d5f-548e8a8acb74@iki.fi>
 <20190417105018.78604ad8@carbon>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.17-54.240.9.33
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Apr 2019, Jesper Dangaard Brouer wrote:

> I do think SLUB have a number of pathological cases where SLAB is
> faster.  If was significantly more difficult to get good bulk-free
> performance for SLUB.  SLUB is only fast as long as objects belong to
> the same page.  To get good bulk-free performance if objects are
> "mixed", I coded this[1] way-too-complex fast-path code to counter
> act this (joined work with Alex Duyck).

Right. SLUB usually compensates for that with superior allocation
performance.

> > It's, of course, worth thinking about other pathological cases too.
> > Workloads that cause large allocations is one. Workloads that cause lots
> > of slab cache shrinking is another.
>
> I also worry about long uptimes when SLUB objects/pages gets too
> fragmented... as I said SLUB is only efficient when objects are
> returned to the same page, while SLAB is not.

??? Why would SLUB pages get more fragmented? SLUB has fragmentation
prevention methods that SLAB does not have.

