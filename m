Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E80D8C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 11:50:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B45532173B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 11:50:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B45532173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4803D6B027D; Fri, 10 May 2019 07:50:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 431426B027E; Fri, 10 May 2019 07:50:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31FD76B027F; Fri, 10 May 2019 07:50:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12A8B6B027D
	for <linux-mm@kvack.org>; Fri, 10 May 2019 07:50:39 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id b46so5962079qte.6
        for <linux-mm@kvack.org>; Fri, 10 May 2019 04:50:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fc/TVDDLEszvtGhrFBXYt1Ypt3KUsSWRb+mZWKhfqro=;
        b=m4LnHeY8Jg+A/jNQYvlyqRZWQ518oXoGwLbYxiwr/UQo82tlFQ59HtImzhAN+QOjBN
         K/7/DG8HoCvQGZxyT47TxuYOqi5X/olpK1A1l9NlO2zIBLBYy04OosuvqAm5UO0qBBxS
         xIZi3eBh5vPn8nB6TytBT3fS180j65kj+BvEivpGTLP8WcSnap4r5boENjTzhD6BxONz
         bL+m7zEH/y7uOFd1NDcPlAYNxRGhhoA76b76aEpNzj4y2ANYyFEPobIGnkcIKzgfpgGn
         dMzJj1Ygg0k5GWEO62qAK/LyI2K3PMFNBqwj99xo+gP04aSiKK1CASiZyUm/H5erLDkv
         bwUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUYKYGa2ZMeXaDXIWOwDx1non01132HmGjGaU+v5+Hxe46R4BzI
	v/LaXfCoMfb/OMufKMYlHUqqaujubxd2mhTIPfVGJankMGuQHYYQSyvDwo7Dx/epjt37wVbXS2O
	ZKOOhCZ8HMuEeXn96flfnMfLQvFHMZ58P2uuR545ZnxY93oRHUMto+4krpjHsnn7h+w==
X-Received: by 2002:ac8:17b1:: with SMTP id o46mr8872743qtj.71.1557489038849;
        Fri, 10 May 2019 04:50:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzp0PMIvPARUdVFSRe8vpWRir+3mbW1xsw5hFZaL71Ogs8rgrVnfSVZvGlCrTaQaIjc3zog
X-Received: by 2002:ac8:17b1:: with SMTP id o46mr8872710qtj.71.1557489038199;
        Fri, 10 May 2019 04:50:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557489038; cv=none;
        d=google.com; s=arc-20160816;
        b=J+yMxoRapKksNZEebgOkIJVVfagCJ3mMiROwgDFyERwiejSbjyAL4IJNAeL/Fg8rM8
         jdSciYaDQm7amzdKWYueTAM9c30lyROloGlK0gOgtIdsmTzO4zw5rE7KZM+hgIQPZvyd
         ddYgiiOc6oxmm5HgewZfNxQYjf6CGRv/erkxRe3j/rheergmxaYrdeDO1/gZxMhF8IGJ
         kXhN7ZLlxyfT3PU9wCp/tuVfaCKVY7kwN2hcvTLdScsgfAFngPVWLxtIqqHkhO+UNevU
         KqyoMbFeu4DsW0GoRqHfJpO7/MTEs3wxcORTWDFB1jVpCZJDeQRpiyXrmGna3WAskUdG
         ienA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=fc/TVDDLEszvtGhrFBXYt1Ypt3KUsSWRb+mZWKhfqro=;
        b=MYbmOTSpuiZ+wmJyChKmHcp/NqF8FJDiIyrlgYxUY8cguOjrY3vIQxZMMIJKaQGmKM
         VD603gBV+zzZOXUh4W30FZqHslgSZtRnw9dEHj3a6bVTPnZNhI+ErUx+t3aTJm0VpBJi
         6Y2f/e6Yu8eoYQaXOHYy8Ag1xu8+XzJT3Qn1WrjMkBVobgR2Z9run4tDXvNVjKX7KMaA
         oebWYTSIgiu73KMMufzC8h047jgn8jM69R5u2YgEFSm4GKAiujk7LlbbA+v8KEdQ+fAh
         zMLgs7p3ANByqQj0A8x+4HTnm+W3kxaDhRQLWQOixNY+ct5rp6j4F1CeEhiXAUTMpcDl
         gOUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e18si370296qkg.90.2019.05.10.04.50.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 04:50:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 786A030821B5;
	Fri, 10 May 2019 11:50:37 +0000 (UTC)
Received: from carbon (ovpn-200-50.brq.redhat.com [10.40.200.50])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 49EA660CD7;
	Fri, 10 May 2019 11:50:32 +0000 (UTC)
Date: Fri, 10 May 2019 13:50:31 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton
 <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>,
 brouer@redhat.com
Subject: Re: Bulk kmalloc
Message-ID: <20190510135031.1e8908fd@carbon>
In-Reply-To: <14647.1557415738@warthog.procyon.org.uk>
References: <14647.1557415738@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Fri, 10 May 2019 11:50:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 09 May 2019 16:28:58 +0100 David Howells <dhowells@redhat.com> wrote:

> Is it possible to use kmem_cache_alloc_bulk() with kmalloc slabs to
> effect a bulk kmalloc?

Well, we have kfree_bulk() which is a simple wrapper around
kmem_cache_free_bulk() (as Christoph make me handle that case).

We/I didn't code the kmalloc_bulk() variant.

What is you use case?

(p.s. fixed the MM-email address)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer


static __always_inline void kfree_bulk(size_t size, void **p)
{
	kmem_cache_free_bulk(NULL, size, p);
}


Handling code for kfree_bulk case:

	page = virt_to_head_page(object);
	if (!s) {
		/* Handle kalloc'ed objects */
		if (unlikely(!PageSlab(page))) {
			BUG_ON(!PageCompound(page));
			kfree_hook(object);
			__free_pages(page, compound_order(page));
			p[size] = NULL; /* mark object processed */
			return size;
		}
		/* Derive kmem_cache from object */
		df->s = page->slab_cache;
	} else {
		df->s = cache_from_obj(s, object); /* Support for memcg */
	}


