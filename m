Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59D0EC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 08:01:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E0AC20B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 08:01:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E0AC20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA0BA6B0003; Tue, 18 Jun 2019 04:01:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A51748E0002; Tue, 18 Jun 2019 04:01:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93F3F8E0001; Tue, 18 Jun 2019 04:01:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 764D06B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 04:01:44 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id r40so11702267qtk.0
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:01:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=ELlMVonpbEABBkseUdTxSk6vYaA7MdUkuNEpzt+TAlo=;
        b=neQ034lImBbVGOrnhm+6FDb+OPLk7PaiPOjDAihzsjml9qtkqjLtMz2/St95/NvEYQ
         pgl4UauKw25km1/KVMQwup3XEULRQmSuRRkgO6eZPB/NdTDWJHwNdJpJNFeT/7h2PiIB
         WAN2KH1DyoIjKkfRj6nnZnh5fBrCi01fQ4G3ji/p6wxK9VV6Y1IZi4FxIKiE0QRkghai
         L7LGhDeWfPXmAledMHXavdAjZmzJVq0qSzbGzsMoSSyL2KGCKXeQI50yCYgpcE07fJwF
         30D2G32tGFm+i/qCny76lFLpyzPGSOaqnntNqV73va0X2wyIMpx37VnnEKioI8dbxiZ0
         jG2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAWjle182mPC4jbejrx3etaXXc2iAFNY5qfkUJwy+lC+x2yKPU7X
	01AdiaWdtcKWV1SMC/EBOm/oogAuhYOHYY46uW6MQQ4Ytrj8sd7+H8vei3cHGNcVzKj/07XbVfO
	6KEnlKFDSfk5pewbNwb2TmhLVpYFD0QXK822KXemLgWHqwyo6TN3NvXvWMlNGgLA=
X-Received: by 2002:a37:b7c6:: with SMTP id h189mr92654542qkf.347.1560844904249;
        Tue, 18 Jun 2019 01:01:44 -0700 (PDT)
X-Received: by 2002:a37:b7c6:: with SMTP id h189mr92654503qkf.347.1560844903643;
        Tue, 18 Jun 2019 01:01:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560844903; cv=none;
        d=google.com; s=arc-20160816;
        b=QPio0FkvUeMx7lLGAloOQq6s8OASA0/1YHx0vOeNCR2houK5/QuvaqDAie0iNTpslh
         cpJ80P7kk275hFj9ogpojVlx8W5UYI2CyzBlqHWTcQBkTtkMf4vZiLCnVz2xnr9RrZFj
         oJNvMySFDZUX3K9WsDKd78FdOEPL7xmwNxqZUAOChqfcGnHk9UpBmmaPruyl1BXSAlfV
         sq0ckkO9JWviVeTXMOWfZIq20qP6AXG0JoP0AE+XnwvoJXHKPXyW4gmfejkLpTIEOeHu
         jB56iU4Fq7+ZWn87SiFa0NV3EYcYzukeOyth9+cAwrHEIMh0gLnBGw1yWGV+reLO4r/n
         SMng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=ELlMVonpbEABBkseUdTxSk6vYaA7MdUkuNEpzt+TAlo=;
        b=vqDzOTxIU2/vo3Xc6xRSN4vNXDJesRsKAtxub0BUyvO6lC3A/uFNQFhbzzOzrUpFsA
         zw54O9xVFr4ocJS9telL6FOzau6iH/IrHBuucusDQovt4sTcHC6RSFFEE0kRl4glCCZp
         mgpd/voOVZc6UDdb5IjpU0JmagbVeFxrGYqT11aVgA/lz646097O68aGQkctjAuNdX9o
         KwBEza5YWWEc3ySAY3K13Ok8S84IYKszCqOtBY2aBzgrJPmbFFWjLZhbbxwhZqHegFIj
         SdQaBqTm08D9Tx9Os6bWxAqRtTAwUeeSMaxjUzUyjYnVo56Ww7oA4a2L7Hb6i46SmRqq
         7Tfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j28sor19526331qta.53.2019.06.18.01.01.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 01:01:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqynQ5w36BP/oae5cSk/XmTmxDHjsYOb6nmmK9VfbUuACv+qzschtpJZO5zjFMzBPDMzYItF9huO7MOjqr8Yc28=
X-Received: by 2002:aed:3e7c:: with SMTP id m57mr93398121qtf.204.1560844903063;
 Tue, 18 Jun 2019 01:01:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190617121427.77565-1-arnd@arndb.de> <20190617141244.5x22nrylw7hodafp@pc636>
 <CAK8P3a3sjuyeQBUprGFGCXUSDAJN_+c+2z=pCR5J05rByBVByQ@mail.gmail.com>
 <CAK8P3a0pnEnzfMkCi7Nb97-nG4vnAj7fOepfOaW0OtywP8TLpw@mail.gmail.com>
 <20190617165730.5l7z47n3vg73q7mp@pc636> <CAK8P3a1Ab2MVVgSh4EW0Yef_BsxcRbkxarknMzV7tOA+s79qsA@mail.gmail.com>
In-Reply-To: <CAK8P3a1Ab2MVVgSh4EW0Yef_BsxcRbkxarknMzV7tOA+s79qsA@mail.gmail.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Jun 2019 10:01:26 +0200
Message-ID: <CAK8P3a0965MhQfpygCqxqnocLt9f4L80-mF-UgoP5OdAoLCCqw@mail.gmail.com>
Subject: Re: [BUG]: mm/vmalloc: uninitialized variable access in pcpu_get_vm_areas
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, 
	Thomas Garnier <thgarnie@google.com>, 
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, 
	Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Roman Penyaev <rpenyaev@suse.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 9:29 PM Arnd Bergmann <arnd@arndb.de> wrote:
> On Mon, Jun 17, 2019 at 6:57 PM Uladzislau Rezki <urezki@gmail.com> wrote:

> Using switch/case makes it easier for the compiler because it
> seems to turn this into a single conditional instead of a set of
> conditions. It also seems to be the much more common style
> in the kernel.

Nevermind, the warning came back after all. It's now down to
one out of 2000 randconfig builds I tested, but that's not good
enough. I'll send a patch the way you suggested.

      Arnd

