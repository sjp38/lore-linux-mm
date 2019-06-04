Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 812CDC28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:18:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 499EF2473C
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:18:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fi4odz0C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 499EF2473C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D321F6B0269; Tue,  4 Jun 2019 10:18:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE2FB6B026B; Tue,  4 Jun 2019 10:18:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD13B6B026C; Tue,  4 Jun 2019 10:18:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83FD96B0269
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 10:18:07 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s195so12496866pgs.13
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 07:18:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding:sender;
        bh=49OX8NmvmI055r/OXImGhv4c7c/FNWltAI84LJFVh/A=;
        b=KjS9DuPIlRuqRBONX1pDsWB14O5RVr9umIPs5o6qhYxkMIA1pjt0CqSUp+ZxjiQhHq
         vaqP5lglGwV4ZCgsWwELK8b0etkLWo1xzTclQcizgmjAXYxYCARQM5fNpg0l+h9bMUn7
         NfkLjyLeIgWsFUopGLZ0OGMdbjleOlCpKRhYlKWvYF0S7wRiuwf730WElveMHnNnkERX
         aQqG57cB8520yEEXdvonLKyL4LMHTD1mxzTQ/LKgEC85Qq0HEnHnyH3ZgJNIOm4TxZ+i
         n+vzbrrHviEXux2X14gjEjc1PiOXKJfHh8IOstID/Blya/NIGpnrHoBrqfyeuPyreBYp
         yB5Q==
X-Gm-Message-State: APjAAAW8QC9kgb8PS6wVGdwCFjVL8oDqj9OMP+BnTyTS8K/zKnNUexZV
	odLqegarsTAHzOz7YHjAfjlJN+UahE5ECuzexCDi7LxtF+DiGbUPaeH+v7wUPpap9NeXrIYImU2
	Mt3KB+3mnT/L1L2GpHqCu7kK86HZrjxWODX7VHePEOvYNtQaHpIyXPcFgSKQHFwQ=
X-Received: by 2002:a17:902:4a:: with SMTP id 68mr37174702pla.235.1559657886864;
        Tue, 04 Jun 2019 07:18:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgJAlQePsawHWaWcrkL6Fw4IzDpDHMVIPMqc3Se7DjVD5o70FW+EI2MJugVUzWACOXwt3k
X-Received: by 2002:a17:902:4a:: with SMTP id 68mr37174562pla.235.1559657885628;
        Tue, 04 Jun 2019 07:18:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559657885; cv=none;
        d=google.com; s=arc-20160816;
        b=czsNNr6/s1GeWkHvJ42kA0rb2zIHBzrcwOroyRJMMf7f85Xa7EVZq8t2AnAq2+nsgw
         o/BrNSvKymjiqBFaucUYe0dgb8ifnoqog+773ocVwVktK9T1W8otlwXrvHzQiX1wcV+z
         yyctPvypJjXHn/j+B9RLLctCT9j9UkVJYQ+VgReF1L2YEmFi5F4mB0Shqpv5pPyjyGIs
         6CLD5d4lJVLSp+T+A1pmXAm6uSRNk6/jfwWmuWoo/9tkFg85y02VyxoOJ7xGMFcZdvZT
         ONyxMn80YaI1T/DrUSwxSodbZ27u+OLc1bk4ouTvpo0dzro5pl+KCVVvpDt9uuvzOedt
         a8MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=49OX8NmvmI055r/OXImGhv4c7c/FNWltAI84LJFVh/A=;
        b=KTFVK3x7LCHbda7bfBFNMgkeCTrkkguNgfD+Y13WV29E0cg6wIG2qTcQbN20lKCcDH
         RMsHc1uMLF6sRY7WdUymQsETTWVvLq5q33fycW7KcuyiZIBS/3zyIPF8/D4pX/rP45mq
         kKxi54SXaws9Ue1VDdlizutMv2CJWLzBabFGP1TyQCiy/JM7rfEw2SN+GIEf8IX2dP64
         YP38uou3GHBDud3MWUZwLoQDS0mzlDePtSCPRq5VSSfVxw6jomD/z3/uChptJQoWP2lj
         y3CqJh2USjCAviiOpmZqxV494Wtf4sTMtUUasBWXULcgLz1s4tlX+tXggz8Ys5fTCto4
         itJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fi4odz0C;
       spf=pass (google.com: best guess record for domain of mchehab@bombadil.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=mchehab@bombadil.infradead.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r2si4271544pfh.85.2019.06.04.07.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 07:18:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of mchehab@bombadil.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fi4odz0C;
       spf=pass (google.com: best guess record for domain of mchehab@bombadil.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=mchehab@bombadil.infradead.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Sender:Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:
	Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=49OX8NmvmI055r/OXImGhv4c7c/FNWltAI84LJFVh/A=; b=fi4odz0CcZkQgAroB59pt3fkKR
	YOlYGx+2Khehitc5h84rSj9HrV2itUypVSSnL0uVn0lCrA38rF20ogqiYo0uFOahLKxVfV3SMmFay
	cekZdnv4H+I7N8o19U5SycWaX3OXQBpcGPcteYjhKgQ6GKDLkkOtNukpXOwZvh0akIww516rMyTFF
	MXbe0H8KPm9VyDKITothwl7CfjI0702MUTdANFBs5mZH/F36mrL0GVJbJOKBWSJV4y1Bdn3yMecQt
	9XlqQQUz8K2XWPm7ylvRXE0MAviOkDshVO2E9ntL35ZnSZK8sLKIrjEEJex2o+jKDpIDYSeT9wY4n
	iP/ANkTQ==;
Received: from [179.182.172.34] (helo=bombadil.infradead.org)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hYAGH-0001Ri-UA; Tue, 04 Jun 2019 14:18:01 +0000
Received: from mchehab by bombadil.infradead.org with local (Exim 4.92)
	(envelope-from <mchehab@bombadil.infradead.org>)
	id 1hYAGE-0002lF-OP; Tue, 04 Jun 2019 11:17:58 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
To: Linux Doc Mailing List <linux-doc@vger.kernel.org>
Cc: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org,
	Jonathan Corbet <corbet@lwn.net>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH v2 10/22] docs: vm: hmm.rst: fix some warnings
Date: Tue,  4 Jun 2019 11:17:44 -0300
Message-Id: <ee4ae1fd9119e1a69b80ccea8ed642b18e3d0eb2.1559656538.git.mchehab+samsung@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <cover.1559656538.git.mchehab+samsung@kernel.org>
References: <cover.1559656538.git.mchehab+samsung@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

    Documentation/vm/hmm.rst:292: WARNING: Unexpected indentation.
    Documentation/vm/hmm.rst:300: WARNING: Unexpected indentation.

Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
---
 Documentation/vm/hmm.rst | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index 7cdf7282e022..f22bb5fb5eec 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -283,7 +283,8 @@ The hmm_range struct has 2 fields default_flags and pfn_flags_mask that allows
 to set fault or snapshot policy for a whole range instead of having to set them
 for each entries in the range.
 
-For instance if the device flags for device entries are:
+For instance if the device flags for device entries are::
+
     VALID (1 << 63)
     WRITE (1 << 62)
 
-- 
2.21.0

