Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1317BC10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4B9E20856
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="S9YZIJcE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4B9E20856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 255446B026D; Tue,  2 Apr 2019 19:06:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DCA36B0272; Tue,  2 Apr 2019 19:06:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F24796B0274; Tue,  2 Apr 2019 19:06:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD9916B026D
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:06:30 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n1so14925405qte.12
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:06:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WyIL3jAshSjdBFnKxRJVP8UxjvsL3RiIiqvjpUWI/P8=;
        b=dyOFNOYRn81wZkAAnOW1W+awapIAOifQgHjqUlvK3GCBCTXHlR1e4P/uMTJKoadrhY
         7CiIOCM+Sika4jL+GVaKm5s9kM6H45gkmD/+QkIMNsrplr+nH1g5g+Z/49jXK6Btu6yu
         HzkZP8vl9vRNOz9pivQl2PNcmq38M9j/bFIzb7KgsvSofJYLn63TMkXGVJyNvnvb9/2v
         zGAEFygVDjLkvgP2t3s7JestB/+vTEoHfUeZxYEw0C62nfinJRLRfHOiiEYOglEp36ja
         sOvlYLYu6MJZbET0sXtuVwrrCh0ZQ2f5geZl5wW4tkHbpzqhPHQQRt088eOiBorFb0Y4
         hNSA==
X-Gm-Message-State: APjAAAX5VuBNVuNrtt45PBJ0MpJfDc3N8cerKrgO2tczominBun0iLpD
	lr+OUle0LYDTP2v/m5HgoXDoT7bM4jzmna5aZtP/3ImRvIrBWTbojP7CriLJxReNy8ZuJDPUX4y
	fDapS52JpeVh7M8QPQYjw0dTyTQ1ikRPzKJzttZwCi9HLhbSM7ujMFh396PlgJUI=
X-Received: by 2002:a0c:947a:: with SMTP id i55mr60854009qvi.223.1554246390525;
        Tue, 02 Apr 2019 16:06:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUa1eS7Pxpj0hzVrKpIo0zCCv+tNQhnPwhVyu+TLitXjra3tlLLKQlI/hhgxaC8WmGLmec
X-Received: by 2002:a0c:947a:: with SMTP id i55mr60853964qvi.223.1554246389840;
        Tue, 02 Apr 2019 16:06:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554246389; cv=none;
        d=google.com; s=arc-20160816;
        b=jlX93HGI0oknuZr6iV64EDfnp0oUrhhxYnkX+8bCGADCprso9ZxNxcv/rK1G72Xzk3
         bVIQ3AUIeP9rrqQtvJSyEShuIbB/JPzwNw7Td1LyGpT+P4UdjVhKCAriZLnhoJ3wDPIB
         RDUac4btnZ8Fk3znfuc9Z0AuoRMK0QJW/NZIIEAf9Lgy5SgOnmt600Aa+O2X1COHsxCs
         N1wdFHbN/EmCizjiiPDsOEm9H8ig7X5Aho/xgiuFLVu6jTZXW0pIoKWjyCXfvxdbhanx
         jnlLbjXtWaVBs82bV2NOh6BE5KAulShn0MLNl5B0544OeQWRvMmU9ZT0FfU7ZKYpSmkg
         MbRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WyIL3jAshSjdBFnKxRJVP8UxjvsL3RiIiqvjpUWI/P8=;
        b=RLx1OrPqfGDaCK8/vvvy4TMP4XqKma75XGK778WFdanvFdPyQb6RmdnL3Mvcdc+IzA
         3Avesfg00pYW6vob2iOe1fUV3nO25eBiyaLqDjJpSKYruUfCfe6++ozj+o65UYvTEGvA
         Xr6GplxPpi9xY5tyUb/C9N5kXu+AMUHG7tMaSRUVie0hxBZH3K9DHMdxzhO3vxtQRci4
         m1tn5ePHcNQ5lt9Pn275mBZIJWrEMjeGfMq4saoDRHgi2RthftOmYIUSWXn2MrnccBrl
         8wZczWa9ioRQD+2+OZSjPscT9WZGgNqW/BiScxsMCpscEGVnQbPRFzyWwv6UYaw7IZb5
         BJLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=S9YZIJcE;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id g48si1464110qtk.57.2019.04.02.16.06.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 16:06:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=S9YZIJcE;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 606BB20B63;
	Tue,  2 Apr 2019 19:06:29 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Tue, 02 Apr 2019 19:06:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=WyIL3jAshSjdBFnKxRJVP8UxjvsL3RiIiqvjpUWI/P8=; b=S9YZIJcE
	ioLWYGHJy9xvw0Z+EIbMaGsCAADIx/5Nw2oDC/AowE5OE8MjNuQ+sqBwuY2qyDC8
	s9O9em3R9HRwWRLDyOjBCpdG7ol8zYFeYr1u8ckmdXRFOAWa6mJ4wjPTIIjn2dsx
	38slfK7mNrfaEJaEsOVBy/a16YkhWbK7oMk3K5dqkBSS1EL/wh/1bdrxaDV9vXIP
	WUvdHHuR+EuFQTpeCnFjNzBXZIIbJ+HTdIV8CIJsK1K+uvNSd63Z6UIsK6zzKXJl
	JT79i6i8j8eOx7Jm9xkNMreAop2jfoHI2ra8ZDE2S1ISpOqY/Dw3FAo6z+nqU0my
	Tk2caoQt3XN1mA==
X-ME-Sender: <xms:9eqjXFs9Bv-IY4LgPpq7YJm064ggklAjDR0xPtkV3_3rVftztl44tg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdduieculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpedt
X-ME-Proxy: <xmx:9eqjXCvX0Esioe3qfH7H7YsIIsaaVXXReE23wdARAieZPlAXwM43Ng>
    <xmx:9eqjXDwsi1D-8VESjhnFE3QulC_3so36wdnpmKJP6BTJbiTSn5LQOA>
    <xmx:9eqjXAjHTjMnuvrv3gh_fjEdYLl88hbEfNq_khdewDzPs5XgGwb4rg>
    <xmx:9eqjXEoFxBJ621naImkvkzugKGYfwbpkpIEnoJC_v8o7j89AAYr3rw>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id CDCFC10310;
	Tue,  2 Apr 2019 19:06:25 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v5 1/7] list: Add function list_rotate_to_front()
Date: Wed,  3 Apr 2019 10:05:39 +1100
Message-Id: <20190402230545.2929-2-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402230545.2929-1-tobin@kernel.org>
References: <20190402230545.2929-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently if we wish to rotate a list until a specific item is at the
front of the list we can call list_move_tail(head, list).  Note that the
arguments are the reverse way to the usual use of list_move_tail(list,
head).  This is a hack, it depends on the developer knowing how the
list_head operates internally which violates the layer of abstraction
offered by the list_head.  Also, it is not intuitive so the next
developer to come along must study list.h in order to fully understand
what is meant by the call, while this is 'good for' the developer it
makes reading the code harder.  We should have an function appropriately
named that does this if there are users for it intree.

By grep'ing the tree for list_move_tail() and list_tail() and attempting
to guess the argument order from the names it seems there is only one
place currently in the tree that does this - the slob allocatator.

Add function list_rotate_to_front() to rotate a list until the specified
item is at the front of the list.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/list.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/linux/list.h b/include/linux/list.h
index 58aa3adf94e6..9e9a6403dbe4 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -270,6 +270,24 @@ static inline void list_rotate_left(struct list_head *head)
 	}
 }
 
+/**
+ * list_rotate_to_front() - Rotate list to specific item.
+ * @list: The desired new front of the list.
+ * @head: The head of the list.
+ *
+ * Rotates list so that @list becomes the new front of the list.
+ */
+static inline void list_rotate_to_front(struct list_head *list,
+					struct list_head *head)
+{
+	/*
+	 * Deletes the list head from the list denoted by @head and
+	 * places it as the tail of @list, this effectively rotates the
+	 * list so that @list is at the front.
+	 */
+	list_move_tail(head, list);
+}
+
 /**
  * list_is_singular - tests whether a list has just one entry.
  * @head: the list to test.
-- 
2.21.0

