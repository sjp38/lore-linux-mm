Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53F88C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:16:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 060ED2148D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:16:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VKsly5J8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 060ED2148D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A45508E0003; Mon, 11 Mar 2019 19:16:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CF368E0002; Mon, 11 Mar 2019 19:16:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86D978E0003; Mon, 11 Mar 2019 19:16:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42D498E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:16:41 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id o67so784002pfa.20
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:16:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VRk8dTonCC66f9q4pJTMkfYABO9GvpgzSFGe1HmkjIQ=;
        b=MHBQ4yvij1T/PtyF/gqILw58XwQZMjAN2P3/kQjGr6eMsemigYk8I+1uhvQCSQA3Sa
         iOjgGHIsOD83KYwTvRyOenQDDZlNqtB6zBlrl1Y5i1rhFgSsk2/or/qzZFOjbePCkiFh
         ihGo1wPqFKuOtFTn95fUhgumK1C1BH7Up1JNWVmu4yMPnZqGcM0ToxRLhnCOXj9YhCTJ
         vNo3B5V9Q9KqO5zroGUm3jeL/HcIGxZiEU0oAO0GwKEg59DwLVkHac7fOK91v6ZOq+Qn
         ojKToZ7FyZ3R9xsLmmSOCnyprn89kxpY8FvejQZg2EsbGGi+Am5rEZb1SwM58japhEV1
         caEA==
X-Gm-Message-State: APjAAAU9lvH0qqMeUHOMFVbA27PKnCTC7diUm/1Iofhe1YdlnfS1RBsf
	jXQmA5n6Kw4aDt1nEeYa4LaC+mFUJq7NCkU5AxMJcFnHgVtCFhprWmcGDoSbOvYyh5FxH9YIQPp
	muKC/ZpKgP9902NguN4oRSwRNaHM0SWDrFHSIVouYoMeGQ1ULurKoTQ6JInJg/xv1xw==
X-Received: by 2002:a63:1a12:: with SMTP id a18mr11969602pga.200.1552346200911;
        Mon, 11 Mar 2019 16:16:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMb5kpwG70cJuRmvIqTx38XAwX7jOgEbnjatNePJTpRtXG7YSLozkl7OwrZyI9gXZxKfRo
X-Received: by 2002:a63:1a12:: with SMTP id a18mr11969530pga.200.1552346199856;
        Mon, 11 Mar 2019 16:16:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552346199; cv=none;
        d=google.com; s=arc-20160816;
        b=wjS0klDvvm8kAAiAISH40+sjIbB6cPE6BwFe5e7rbsMj4DGLNs83VJpriRIaY48iOd
         sYNfJ3llOpXNaP8AnUZbklx+i3utit6o7XFKuOH2bMFI6z/ZkfehvjzqD/L3EQlAI/CM
         bbcwYGyOdhSGajApYOYz8nZDwCsT9AKOPaDumWAnIuzdiWwtBAHfwK7jslh8n6/77hwg
         Mt6FGaffuW+H9ZrlWstbMdagjl0EXIbet8iYDIxepz7kBmwIus1UAjZbXnlvqlJeQt0h
         wVhoAat1Da5lcquhi4pZmNxmigZOsuQrpX6icXXvWKjOrnRtFUWHTB0YCmT+Mv3eqCVg
         Nl0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VRk8dTonCC66f9q4pJTMkfYABO9GvpgzSFGe1HmkjIQ=;
        b=pSlAu7VFmywMWED9GvV0EVSel/bqimHNLjpM8xO0BD+aYxj5AhKwVATBuk/w/tSKxH
         Qgj+RTrs6C6TtbK6TRyQz5IK/UI/zzrWGEYCIUUW5NP9cKi6gf/jXgoh4gM9NFIelI1f
         BtEn9hN1OW+FRo/evm4qZubSy4enRxx9VsG9t1MqcqzAsGKqjUnjWyAOM17TNIjXbxax
         Z1sWCUnonqmEG2Wd+Ad1wBMFH6zV7EQU2OWJglugfyD48qjN7jcitwcIQdc6Cb/q0VnH
         40FarRuwVyMXgtMP7TbLreOK2u6u9LDTgeb5758aWCif+WP3meiISHC4uJbv8dT+lY2G
         ypJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VKsly5J8;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g9si6284252pfd.234.2019.03.11.16.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 16:16:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VKsly5J8;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=VRk8dTonCC66f9q4pJTMkfYABO9GvpgzSFGe1HmkjIQ=; b=VKsly5J8ERsC1H7zgSrPBqf0Y
	g4bn3XesRKnq1azJLVGInGQHZuQClN2MazwVuR1kCkrfyXDjQIQsEPtIkjFx90+YVNWSTerbMjiKw
	X9rQztt44nwZXr3dEhYLRP1dnWacDtJdbxoZvxT/LfColfM4Vhgf7UgXdKqLC+tL+5V97jDPSe7uD
	N+AlyC8wsyWUt0DtbBHSvWpGiQ+v7Gpl06LuWiApmLPHDp2UCoobbRAL+2kw+FfcmSmXvxDWXAAJU
	USkzG7rhaT6QVfZyOB/2n+CQnoEnDQtcqQd1ppP370AwiGaNqjnFCeofgTmhxySfXd0YtUk0qOkg/
	6FdPXQ0HQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h3U9q-0005zC-0K; Mon, 11 Mar 2019 23:16:34 +0000
Date: Mon, 11 Mar 2019 16:16:33 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/4] mm: Use slab_list list_head instead of lru
Message-ID: <20190311231633.GF19508@bombadil.infradead.org>
References: <20190311010744.5862-1-tobin@kernel.org>
 <20190311204919.GA20002@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311204919.GA20002@tower.DHCP.thefacebook.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 08:49:23PM +0000, Roman Gushchin wrote:
> The patchset looks good to me, however I'd add some clarifications
> why switching from lru to slab_list is safe.
> 
> My understanding is that the slab_list fields isn't currently in use,
> but it's not that obvious that putting slab_list and next/pages/pobjects
> fields into a union is safe (for the slub case).

It's already in a union.

struct page {
        union {
                struct {        /* Page cache and anonymous pages */
                        struct list_head lru;
...
                struct {        /* slab, slob and slub */
                        union {
                                struct list_head slab_list;     /* uses lru */
                                struct {        /* Partial pages */
                                        struct page *next;

slab_list and lru are in the same bits.  Once this patch set is in,
we can remove the enigmatic 'uses lru' comment that I added.

