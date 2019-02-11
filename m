Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 072BBC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:09:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B56A92229E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:09:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B56A92229E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F2B08E013C; Mon, 11 Feb 2019 14:09:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49DF28E0134; Mon, 11 Feb 2019 14:09:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 340518E013C; Mon, 11 Feb 2019 14:09:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 022308E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:09:39 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id v4so13771867qtp.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:09:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=cRRrHsUNQPE5A4RF2o9y1h962QChq1f0l7oFXRjkcfc=;
        b=BgdAOd3XT+wMjluPvPvN0/Z5DG/V/aOxFkjbUK715WcPL27uG2AHbrG0tc9mW4IvGT
         TWttLcS8t2rK6RP6z9ov8FvPFbde3pqMUlaX0xA0IpyMzRFw7xXJ5ahklu4OCVWGXrhq
         ot2+1XUooMq+50tj4j9xfWqZRiZVLAMSp1oW7CyzBrX2wLT91WOvQjfomU7oG45Bxmym
         Hd732B1iQbFdr5wDujkv9r+QlhjxucGuFhBrGwolNFNX+SZ/e66OUHhSi3hkeXTXNmdo
         l6qWx7tSVkS48u3eVE0pSUI3SpFr2lz1gLOCWAARGIXonR7F0eG/e2mgQu0ovBY7MLVz
         NH9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubGOdkhP0MARVTFMfeD22su1/fQ7nTFQzOI4nmYPinBZK/rCl7X
	0bMclgDxsmWJMrrv6RXl+gOPPCyZ7sVrMpJiWbu/hJBgX02maViX6m+mhK52b5tId/DCOciTiOo
	AzXWPji3mJYUgqtx+Sk6IheEnkibtOY62yZeDhBP7dQbtyePBFCDer0hWZZGzdvy7gA==
X-Received: by 2002:ac8:2724:: with SMTP id g33mr7976899qtg.45.1549912178768;
        Mon, 11 Feb 2019 11:09:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYaWS8QwrB1y1JJmesVoTVGlOl45X7d6tGyf5kGADItGlJObikPNeJH6xHxfB4yXCozoPjr
X-Received: by 2002:ac8:2724:: with SMTP id g33mr7976866qtg.45.1549912178169;
        Mon, 11 Feb 2019 11:09:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912178; cv=none;
        d=google.com; s=arc-20160816;
        b=SxwP1LrFKnZBadX3Z9HZR1bNBW2rcfrpodxWFWsl45H1gouvGzqK///MaRhe6nW5Vg
         5IxxCnnfzoTUwYrRsiJU70f99kmlGbVLrs5h5Fk4ibIrPt3EXg8i3JCyi6tsfaVtI9l4
         ngiINBvwUGgjZKu3TXbwuhNsFb9WZ7nacrnocj1CxklFy8d+kpF5HWYULSHe+kHmeRq+
         pY+yfp29FQXsSma/hlFgViUHHWQxndHasQYAmiHtYOAFIxMYcjgcyiECZ81/NRLPhco4
         cq5dmmk2vqTYqRr2ZZg/v9NatOMkhqP/z01Mlp1zIz9nAsDzyVV1oFst8ibEp/anL0sP
         S3XA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=cRRrHsUNQPE5A4RF2o9y1h962QChq1f0l7oFXRjkcfc=;
        b=OT26QSe+Oi3eBh27r3upjEI19Z2YqlOP6ow+hpBgEQvX7HoGxr6DTXRWgNqOcW5pk1
         5zkzYYOWOlH1PKZAhtpdG9b08/wL9nvHx32ci1I7xYWrXRKsi3I0We4DUeff7+3JroCR
         sjKLBU60wineVWveftDUrI+O5DHL+7vDoYfVUTsG9VwjqOVwfwZo5a3hB7O5hU6wnY2L
         Qi6uSAGM+e4RR+Im+5tNFqEcvcWv3K2GEu7apQhAc9xshi9PB/VRJ5VCK5X4Ul3Xgl/+
         HXh/zweQv0AnmPnGip1PK7KqKeytmzvzq4L/MlxGhGjpS4otI/PSwK3rMlusgOcaji8c
         zGug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d197si2284354qkb.84.2019.02.11.11.09.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:09:38 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3E64F8831F;
	Mon, 11 Feb 2019 19:09:37 +0000 (UTC)
Received: from redhat.com (ovpn-123-21.rdu2.redhat.com [10.10.123.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 74BD819C7D;
	Mon, 11 Feb 2019 19:09:33 +0000 (UTC)
Date: Mon, 11 Feb 2019 14:09:31 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Peter Xu <peterx@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, kvm@vger.kernel.org
Subject: Re: [RFC PATCH 0/4] Restore change_pte optimization to its former
 glory
Message-ID: <20190211190931.GA3908@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190201235738.GA12463@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190201235738.GA12463@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 11 Feb 2019 19:09:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 06:57:38PM -0500, Andrea Arcangeli wrote:
> Hello everyone,
> 
> On Thu, Jan 31, 2019 at 01:37:02PM -0500, Jerome Glisse wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > This patchset is on top of my patchset to add context information to
> > mmu notifier [1] you can find a branch with everything [2]. I have not
> > tested it but i wanted to get the discussion started. I believe it is
> > correct but i am not sure what kind of kvm test i can run to exercise
> > this.
> > 
> > The idea is that since kvm will invalidate the secondary MMUs within
> > invalidate_range callback then the change_pte() optimization is lost.
> > With this patchset everytime core mm is using set_pte_at_notify() and
> > thus change_pte() get calls then we can ignore the invalidate_range
> > callback altogether and only rely on change_pte callback.
> > 
> > Note that this is only valid when either going from a read and write
> > pte to a read only pte with same pfn, or from a read only pte to a
> > read and write pte with different pfn. The other side of the story
> > is that the primary mmu pte is clear with ptep_clear_flush_notify
> > before the call to change_pte.
> 
> If it's cleared with ptep_clear_flush_notify, change_pte still won't
> work. The above text needs updating with
> "ptep_clear_flush". set_pte_at_notify is all about having
> ptep_clear_flush only before it or it's the same as having a range
> invalidate preceding it.
> 
> With regard to the code, wp_page_copy() needs
> s/ptep_clear_flush_notify/ptep_clear_flush/ before set_pte_at_notify.
> 
> change_pte relies on the ptep_clear_flush preceding the
> set_pte_at_notify that will make sure if the secondary MMU mapping
> randomly disappears between ptep_clear_flush and set_pte_at_notify,
> gup_fast will wait and block on the PT lock until after
> set_pte_at_notify is completed before trying to re-establish a
> secondary MMU mapping.
> 
> So then we've only to worry about what happens because we left the
> secondary MMU mapping potentially intact despite we flushed the
> primary MMU mapping with ptep_clear_flush (as opposed to
> ptep_clear_flush_notify which would teardown the secondary MMU mapping
> too).

So all the above is moot since as you pointed out in the other email
ptep_clear_flush_notify does not invalidate kvm secondary mmu hence.


> 
> In you wording above at least the "with a different pfn" is
> superflous. I think it's ok if the protection changes from read-only
> to read-write and the pfn remains the same. Like when we takeover a
> page because it's not shared anymore (fork child quit).
> 
> It's also ok to change pfn if the mapping is read-only and remains
> read-only, this is what KSM does in replace_page.

Yes i thought this was obvious i will reword and probably just do a
list of every case that is fine.

> 
> The read-write to read-only case must not change pfn to avoid losing
> coherency from the secondary MMU point of view. This isn't so much
> about change_pte itself, but the fact that the page-copy generally
> happens well before the pte mangling starts. This case never presents
> itself in the code because KSM is first write protecting the page and
> only later merging it, regardless of change_pte or not.
> 
> The important thing is that the secondary MMU must be updated first
> (unlike the invalidates) to be sure the secondary MMU already points
> to the new page when the pfn changes and the protection changes from
> read-only to read-write (COW fault). The primary MMU cannot read/write
> to the page anyway while we update the secondary MMU because we did
> ptep_clear_flush() before calling set_pte_at_notify(). So this
> ordering of "ptep_clear_flush; change_pte; set_pte_at" ensures
> whenever the CPU can access the memory, the access is synchronous
> with the secondary MMUs because they've all been updated already.
> 
> If (in set_pte_at_notify) we were to call change_pte() after
> set_pte_at() what would happen is that the CPU could write to the page
> through a TLB fill without page fault while the secondary MMUs still
> read the old memory in the old readonly page.

Yeah, between do you have any good workload for me to test this ? I
was thinking of running few same VM and having KSM work on them. Is
there some way to trigger KVM to fork ? As the other case is breaking
COW after fork.

Cheers,
Jérôme

