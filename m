Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A2FFC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:14:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1815B2087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:14:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1815B2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A76266B0008; Fri,  2 Aug 2019 15:14:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A268B6B000A; Fri,  2 Aug 2019 15:14:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C7486B000C; Fri,  2 Aug 2019 15:14:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63DAD6B0008
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 15:14:38 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w12so5735650pgo.2
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 12:14:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ttt49H+qVexSPsEjt1MCpwnq9RyVsJ2S7Pzzm/qEK7I=;
        b=GKNYUlNqCrGyeu5tpWVztZYlDpEuI84NPrruBUpvHUJG4nNEa8cFNWjNW2nKTeTWti
         XAJcTn9cA8MakT2SStDF8IHniBjJqcWmS3WLkDd7LX9x6SKNRkUFHl6R0JGbr7ykOtp1
         Bj0TDlOMBnNjmfUsqwDY1mTphlzq8tUOSjMVJkaCxkzjXNVdSmK92Ayxpd9XR+qhtWQ6
         jdU2lpjw8/F0ZON90oab6irls6CqLjTm7QFjYTVf/jumK51UINJ8//LJZy6WWpO0JtMJ
         Pjnru8FKyi2I9KEVk7iVJVhLT6kV7H08NvtJGHdtFLM4ceBIrLzMaM+CPRweJrqljZSw
         5u5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUx3NvDOg4n4arINYXqDiWWhnu3wljbaGlnGZ9xxpjZXjoOaeP1
	MB7ModHJod1OVTdiAWXEVMlurodb2R7U4p+caGd8qwP7KfOEcQL445/sEOyG5owH29o4dg6kqd3
	D8rVfY5Kai9R7JHeQ9+x6ootkIgCtSUVkkhPl5ki+A92FefUIBrXeuNyvEJN6GmZdng==
X-Received: by 2002:a62:5344:: with SMTP id h65mr62007685pfb.32.1564773278102;
        Fri, 02 Aug 2019 12:14:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfZZ3rKwSkzoyOt6Pz70dRJDxn1hmrym50hbriQsR+5Eq5A/fKzp1NL2rplC+CzT0TPr5L
X-Received: by 2002:a62:5344:: with SMTP id h65mr62007653pfb.32.1564773277473;
        Fri, 02 Aug 2019 12:14:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564773277; cv=none;
        d=google.com; s=arc-20160816;
        b=nXxLMdJuWI6oWfp2ROkzGv2SRPYndfNZ/09X4ScnEY80VI7Z1yosxy/FtfBe5WgvP+
         ymstLQ9ByHaSXhTBbR/Ws/vVKWde5x0E80kMMlA2n0pnrheCHaR/M8vK+YbOJTCy5Css
         v+h6QzWbAVFYUo5YNJNvpcRYbasQkCtynlxmrMavDZqy+G10DB5awV3XJgJFdUCuNH3Z
         PzrwuB8cOLOftj0aTaTU117KmBsOU+KawYn6HS71XG8pE64XZjMxrr4PQbJKMnsnt+qP
         Q9D5P0QrQBmm8BvPM6rMm1o+RLwD+73KB/mwFHRJlE/3/MpMuHZyk+us8H+RKQQ7b11c
         Vhzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=ttt49H+qVexSPsEjt1MCpwnq9RyVsJ2S7Pzzm/qEK7I=;
        b=fwMRwYB8hlvjomHW6eINLZH1ObvKUUWvddbNoyxv1aiY6JVtnxTECNYTqvZFRYyWf0
         ciwGapyc4YNeWrdXMWNaWeBAmaHwkuJY8GAWiZlrUoOmT8tg48g2gg737h0MCrYi762n
         qODjGZXOgdNXP2wFJXXnaUbHSbpDYaMIbmXZ+K3/odWEBloqWYluQJTeamaUgJeaIXet
         1rwK8xW6QlWaZwz0m3wx91nAN21Mo43o1dhxM0PUZnDKD1gyje6LQOt5MHaV/BK+Qwli
         /eHRd1NmWfRrpjuEtQw8mEsT5BhXx9koT1bWgJslLvFMNgK7c+s/AEMMbrtinp+S5b9L
         yRWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g7si37514603plt.244.2019.08.02.12.14.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 12:14:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (unknown [76.191.170.112])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 973AE174C;
	Fri,  2 Aug 2019 19:14:34 +0000 (UTC)
Date: Fri, 2 Aug 2019 12:14:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Hellwig <hch@lst.de>
Cc: dan.j.williams@intel.com, linux-mm@kvack.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] memremap: move from kernel/ to mm/
Message-Id: <20190802121431.3ef9d271c40703b4145d364e@linux-foundation.org>
In-Reply-To: <20190802083230.GB11000@lst.de>
References: <20190722094143.18387-1-hch@lst.de>
	<20190802083230.GB11000@lst.de>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Aug 2019 10:32:30 +0200 Christoph Hellwig <hch@lst.de> wrote:

> Andrew,
> 
> I've seen you've queued this up in -mm, but the explicit intent here was
> to quickly merge this after -rc1 so that the move doesn't conflict with
> further development for 5.3.

Didn't know that.

>  Any chance you could send this patch on to Linus?

Sure, I'll add it to today's batch.

