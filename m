Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2628CC10F05
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9B272086A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:03:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="n7HcCJVl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9B272086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28B746B0006; Sun, 17 Mar 2019 20:03:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23ABE6B0007; Sun, 17 Mar 2019 20:03:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 102626B0008; Sun, 17 Mar 2019 20:03:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E1BF86B0006
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 20:03:29 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o135so13293827qke.11
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 17:03:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=D6RBo2xA005T3vgh61b+8gQHpH8S5KLC0eS56YqC/3o=;
        b=BCuqYNZ5AyXzFwaxCpPbetv/pC95tHars0GhCreb0OT2BirZZQv1rBKtm6AC2m6bcY
         Mr1CXKKtdWC2A7QR6fJ+J7vNFDy3oCWS+MLyIZQiQAfJBMWo1qXDPiImnrBp93zPwDcM
         TPBiOW9kGRkwQOaZvigpHX44ds70iB4cc/OtwUzdjbEP3E8thEz1KbeN3hTGNHGq/x8V
         nJ8wkxkL15Hv82ayOk2l246VDPZgfgADvPz6Heg1sD0UWVnmMg+UiNEQ4DEx5ODj0oWd
         Wh/DR2ZkIddvYxW//kTRdY5i9ARkftG+i489reoUqCw80e4g12j/9YZvi/UhTThVBIQd
         ZaxQ==
X-Gm-Message-State: APjAAAW5xmNwPTb3PU/Dlj0v7rXrVAWklXMSBtn5akkKwht89NuwkVzU
	V4AU7nc2Xsnocq0dkN/Qw8fIGtBntSbf3P6vb/UMdEX5Z5Yv13xF02KI4mDHeBGNJeO41n5ne27
	FQjUHWyp0mpFIthAktddfXA2PeaUupjc4eZ2uzKYRkN4BnTzWnj81bu2OVWFTFC4=
X-Received: by 2002:a05:620a:1428:: with SMTP id k8mr10433998qkj.185.1552867409671;
        Sun, 17 Mar 2019 17:03:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRq0Nk4C1Oqx8oEHbLHcKNaG1j4mdIBpd4zPrBDTkkSMik2dB2czs0a4RsrH9EfnI1Ff/t
X-Received: by 2002:a05:620a:1428:: with SMTP id k8mr10433949qkj.185.1552867408474;
        Sun, 17 Mar 2019 17:03:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552867408; cv=none;
        d=google.com; s=arc-20160816;
        b=N2cG1oPeP9/eTmOhVup/jY3pUHqSAEXRAdfsplKJT9lYDaMZTHLl8rPhvStR++XTrg
         zEM0jzGluC+mwdxamxzL1xQFGioz8RMn7Y6MJBt4/NWorQnccfJ+eiQvDJc+T5nfnNAM
         NPu9JpBkon3BC/Mf+cAdJYZlPOFEIUMsHPsGv5iyaibvyfgebQmzrrofsSSA0TcYAOSe
         68SKaGe2LmeRMK44zAAcLfo8z0WImV8Lp30zJhx0T+bmkPVncE5tzMeCTp22tyW7XL6R
         cLDgXarpGZMafO+J8NiWQroVg/kpAZ9k1f+PCuQskx3srpPW2GeExVCE84GLV3F/Z9Ba
         n38g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=D6RBo2xA005T3vgh61b+8gQHpH8S5KLC0eS56YqC/3o=;
        b=pyBlZa/Tu+FGu54Ihe2pk2e0mzAaYYiKWbDaLo6+AGSgvWCwGa4Znf/DpFjl2EmYPX
         S0ac+PcIhs/EyS4IlSwJq2+l646z9imSxsG66nmxTTdoKyF2JOBx/insw4KCum/eHKEZ
         RC0ns3zzjFxRpluEi6SABRicJzf/R/oFpbUVJfQsPFJ78d6CdFqbB6pac41vv4Pp46PT
         KwT2YRnLRiucP9l5mm4f2Uk8LZbv5CHgBBw/czsFD78AP/gb8EI4lPPdId++TgX9JQR8
         xNAxxCjFBtevEHOxUnA5B+FeNx9i0ICTLHcQPHO3D9/8YXB4uQCTx9sKMnB5LDKoPIJm
         6MNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=n7HcCJVl;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id v7si3130300qvf.147.2019.03.17.17.03.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 17:03:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=n7HcCJVl;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 36FB1219FE;
	Sun, 17 Mar 2019 20:03:28 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Sun, 17 Mar 2019 20:03:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=D6RBo2xA005T3vgh61b+8gQHpH8S5KLC0eS56YqC/3o=; b=n7HcCJVl
	z+T1Vd7yrPsV+pLmEJ2EzKDt5uUqwV/vOS5GsWwjehaxoSolfo4W67dv9DOWQPgO
	tYCwPjAKv6oqC4PPRuDJuZbIgk55DuKtSar4a3BJv4s+BvqipULukbB4/6r8XXpp
	9dMxb3UlP3hnc3+PGQqhywF0q2+sNBJlMIfrLgTO/N0817TyyfU1ZylhMbtrdAdJ
	6C809TxyfrsoQVCeFwQfVuQPXbpz+6lZCIz2hOOzgYk9COv0ZmOgGwuhN30EBpF1
	7g9PAuYWVe8iOPfqW4Vx3zRwNeEQFw2bl8sScdDgyu48/YA2OVxhnXvPS+C6iTfG
	gplnsEBPzVMMMA==
X-ME-Sender: <xms:UOCOXCjsmaXUW-TTHz7bxsR-p4QjeQMAr5oRIJWUnOhuYm5d4U6S4g>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddriedtgddukecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddukedrvdduuddrudelledruddvieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:UOCOXHchi3mvfndjJfTD8MaXCpR9eVL68J4LK9sosgF96B7oACXoKw>
    <xmx:UOCOXG1h5JFMvJPgf8Ic6gLZW37LWWU9CR7bx83ZfDnxvdiOJRaLXg>
    <xmx:UOCOXNM8BTQgQNo4b24PSmoYDPIjVCYAmkFFO8RxJ9Yd2fmN9uvosw>
    <xmx:UOCOXDABzYfHbekKvRhnRId89jVsM9W99iPgNgO6eIQFQVQbS4iNqw>
Received: from eros.localdomain (ppp118-211-199-126.bras1.syd2.internode.on.net [118.211.199.126])
	by mail.messagingengine.com (Postfix) with ESMTPA id BEB2DE427B;
	Sun, 17 Mar 2019 20:03:24 -0400 (EDT)
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
Subject: [PATCH v4 1/7] list: Add function list_rotate_to_front()
Date: Mon, 18 Mar 2019 11:02:28 +1100
Message-Id: <20190318000234.22049-2-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190318000234.22049-1-tobin@kernel.org>
References: <20190318000234.22049-1-tobin@kernel.org>
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
index 79626b5ab36c..8ead813e7f1c 100644
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

