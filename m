Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B187EC43444
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:21:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B22F218FE
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:21:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="TfSWvzq+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B22F218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E13BC8E000D; Thu, 20 Dec 2018 14:21:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEC688E0001; Thu, 20 Dec 2018 14:21:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C64EE8E000D; Thu, 20 Dec 2018 14:21:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4CB8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:21:57 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id t18so2992152qtj.3
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:21:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject:references:mime-version
         :content-disposition:feedback-id;
        bh=WG4AB0pljQcpBmeuz1B8F5G9pA0mj9v/xq+gyFWGAVI=;
        b=U/pcIHomXB+TEO0956aXHnspCAUD4ZJ/7xOVwagLAyDJMif0BtB3LCLKTfWWu+AQZu
         lgw4fy/AP8WuyhZRRYayKSB7P4YdH/yrfiQxSEHIyPwitTHpz7h4G/uuAcFblT9EjLMK
         xu8vmtK7oerHnhPgjPRdrlbB6mBf2ie2fbYF11za2Fz01JdQgEFeqZCKURBEePdV7DiQ
         Yg6CYQFdTbJOsm9a5anER+Nriq2MHa9CRNEYohMZohbA0GaJJ+VCUeoZihSwGyt0TQ6l
         OYxYerLhmnFlPNS9/LZN469it9bNUGXOOJmQUxRdF9juRKH6FA+5nEUlBGBS//PBL5UU
         wsWQ==
X-Gm-Message-State: AA+aEWbu2aFFNF1GMjYjnkToakkGl1lYthiqA8jHXb3Bj6Y5Rp+YKdeJ
	+0RHIhH1cXEyppUTIZwt8+byJckcJId+5NbReQf54h7kNn+FIFN6K0T2yjEEwlkcN96frEE3s8i
	OMVYteLv6A7BQs8NXWbaKc+yJzMCq6lQUbIS60j7RrqaTt4cZYYe2yMxVrJW/NAc=
X-Received: by 2002:ac8:6898:: with SMTP id m24mr28227557qtq.57.1545333717431;
        Thu, 20 Dec 2018 11:21:57 -0800 (PST)
X-Google-Smtp-Source: AFSGD/XfXJmiNZGtlSKtxLyBpfhQWuaUTnGIsWzGVzL8xT1FZajbex5IbmYvPsd+aATC5YJjDqLK
X-Received: by 2002:ac8:6898:: with SMTP id m24mr28227525qtq.57.1545333716797;
        Thu, 20 Dec 2018 11:21:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545333716; cv=none;
        d=google.com; s=arc-20160816;
        b=dkforKuo6JVFwCdbfubDgI1av/Sl8a4txo11YoExFFa4Adbra6boZcDQrdImXPK6b+
         c46XBKNRTtffW5ELVThGDwLKvtXuLr1mqwACPt5OQG886HqCoMNJ5+f/qkidKga1MmMU
         XvZLXqTXXrBvgmVFMJitk1moJYkU3lVjoSoJhvqT+49oxx22CZlOAmj/qtteR5XDR662
         iPSEvmxwrTmxuSrcGcO0Akqsn1yIarXKY6oEDRWMt2EGliUSf/b74qxG8h3l6MDNO5Gd
         ZougGsuO5AtGj4dPQ4Tk1sldYlZX+/nPTG8EP6EE1NYiUXb1fnIDhy4wB+x5OCOf/8uQ
         p3ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:content-disposition:mime-version:references:subject:cc
         :cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id
         :dkim-signature;
        bh=WG4AB0pljQcpBmeuz1B8F5G9pA0mj9v/xq+gyFWGAVI=;
        b=krRIRXH7PWvW5sAQvsa1dfzenjjG2i2EvoX1VRwU7KxYYzFtt3nprgwvIE/vrxWNJp
         HkTeuZ7T8Ozm9H5UuIa6pPAudk0KDsk47PSY964oDi6k2umdIlA9aV1RgSN/4gjh+lTy
         YgaY5S+dYvpO4/nntXEFFTGSxstzMMfvMyDpC8qAoNHmDrZeeijtMMEUuPRb01RxqrH8
         c5PTFfLfT9ANOEb6Z3p9oe2594oAY8dJngiGipK0ovn0UgyNc56Bb7vAFRtebEcm3aIU
         Y12yNlvulehjqyD0lyrLEd6iZnfrmBfG/pjoiIInyDv+rMFJSFXk6rRqnQyX4owODevO
         Wc1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=TfSWvzq+;
       spf=pass (google.com: domain of 01000167cd113509-2c85d8a3-8e0e-4cb6-a745-88733e448471-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=01000167cd113509-2c85d8a3-8e0e-4cb6-a745-88733e448471-000000@amazonses.com
Received: from a9-30.smtp-out.amazonses.com (a9-30.smtp-out.amazonses.com. [54.240.9.30])
        by mx.google.com with ESMTPS id o5si1091733qkc.148.2018.12.20.11.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 11:21:56 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000167cd113509-2c85d8a3-8e0e-4cb6-a745-88733e448471-000000@amazonses.com designates 54.240.9.30 as permitted sender) client-ip=54.240.9.30;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=TfSWvzq+;
       spf=pass (google.com: domain of 01000167cd113509-2c85d8a3-8e0e-4cb6-a745-88733e448471-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=01000167cd113509-2c85d8a3-8e0e-4cb6-a745-88733e448471-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1545333716;
	h=Message-Id:Date:From:To:Cc:Cc:Cc:CC:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:References:MIME-Version:Content-Type:Feedback-ID;
	bh=VdAFswNkZMzX1QnleI6nNoe36Hgyo5dlWLZMARfK7f8=;
	b=TfSWvzq+iWaub44mB9Mn8ltb+L1g6QW1S5kgNN/HUVsnK258K9k740hUbuDhEOMG
	bYTUyXxdL0Y3gmb2B+0S4/pIEqgRxEs5Qta6XL+73oW3WxvfSEyEN9EAbgWYzKYXFMv
	5dYhndZ2/byo4T9TMaGK71a7AaJMFgPyIpndY2ts=
Message-ID:
 <01000167cd113509-2c85d8a3-8e0e-4cb6-a745-88733e448471-000000@email.amazonses.com>
User-Agent: quilt/0.65
Date: Thu, 20 Dec 2018 19:21:56 +0000
From: Christoph Lameter <cl@linux.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
CC: akpm@linux-foundation.org
Cc: Mel Gorman <mel@skynet.ie>
Cc: andi@firstfloor.org
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC 1/7] slub: Replace ctor field with ops field in /sys/slab/*
References: <20181220192145.023162076@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=ctor_to_ops
X-SES-Outgoing: 2018.12.20-54.240.9.30
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220192156.8wYilYpa21PIOyXjO4sOxH5wYgpBuiCyOHOyE0G2FIg@z>

Create an ops field in /sys/slab/*/ops to contain all the callback
operations defined for a slab cache. This will be used to display
the additional callbacks that will be defined soon to enable
defragmentation.

Display the existing ctor callback in the ops fields contents.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -4994,13 +4994,18 @@ static ssize_t cpu_partial_store(struct
 }
 SLAB_ATTR(cpu_partial);
 
-static ssize_t ctor_show(struct kmem_cache *s, char *buf)
+static ssize_t ops_show(struct kmem_cache *s, char *buf)
 {
+	int x = 0;
+
 	if (!s->ctor)
 		return 0;
-	return sprintf(buf, "%pS\n", s->ctor);
+
+	if (s->ctor)
+		x += sprintf(buf + x, "ctor : %pS\n", s->ctor);
+	return x;
 }
-SLAB_ATTR_RO(ctor);
+SLAB_ATTR_RO(ops);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
@@ -5413,7 +5418,7 @@ static struct attribute *slab_attrs[] =
 	&objects_partial_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
+	&ops_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&hwcache_align_attr.attr,

