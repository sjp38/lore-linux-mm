Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2266C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 19:12:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B3FE2082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 19:12:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B3FE2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28B486B0273; Tue,  2 Apr 2019 15:12:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23B3E6B0274; Tue,  2 Apr 2019 15:12:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12A4D6B0275; Tue,  2 Apr 2019 15:12:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C64F06B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 15:12:42 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o61so10528829pld.21
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 12:12:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+muWnmDnL8oDPBA3wIcHek9GRIbdD/+2O0D6DSEsRhE=;
        b=sdYJmk/oaN2BTqP0U4u/8EIlJotPs8aeMxVNdBiBFgP3Gvn7XAg7wfIK8zFHTLt4aD
         yYURYfk/5Eiu+Hn6cod3OyG/NIvAsdNnwntobP2vyKQaMbKGNswlOO3F/9KDZQNg4rCz
         T7HlVo3aEL9qv1UmPsKUYbcHxXNAciOtKI/C2EbqkausnispsS6x0OWIcd15M7P5PxGQ
         FQ3LAYJOmIC8SHQYIaYgKwnvMrLzMmEKF2GhqAa0Cv2PpoppMhpuqRHcQcsESVHiEVn/
         FChDO7kp/YLMgh2l+C0x4Jox8iJS+XfPHUl0Bd1xb3EkJx2IdaIi1CAIssl+PWsS6JEu
         l0Ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAU3dkq47v0OCdw/TX+4A0eGH2gl5TsUODB85qM6tuZucljA4VnG
	oeO0jISTxmJULUslaW4XFccj6TIte7oVIrHlDLi10RsOJ59XpELCHztJkVCgGQKG3qrYw1ZZcW8
	N1cfAzNigUYY7zP40kyAl+i31DyOWKlJRHERgjgcDMJOAH1aRvv2BG6QO+zvEbaB6TQ==
X-Received: by 2002:a63:7808:: with SMTP id t8mr35246360pgc.127.1554232362415;
        Tue, 02 Apr 2019 12:12:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsK9+NeQpYOo/CWC9WMraT/Y9fcm8+luUp1XS/6BVPSWb37/3EuywxbJedioDJsQcyxO07
X-Received: by 2002:a63:7808:: with SMTP id t8mr35246293pgc.127.1554232361633;
        Tue, 02 Apr 2019 12:12:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554232361; cv=none;
        d=google.com; s=arc-20160816;
        b=WnecF9yYOlzbm2kAgp6lvzPZq9vF6z8eUUZHdWkYC/PRY+DUO+Q9QfJwWiVFKQPRAd
         t4vyruNkSkTbiVQ0e64BNZfRlCfKxyRjYSCYkPJqtUa0sTPKNsoCFf39nrL0XA73dujC
         LyoRmp1YS6HOOclBIL85H6jNZ2FD/xvlCBrwXm+tRm0D7JukhtSr1FYhiI14DR90y2sT
         iemWhEzT4XV9t5hewfT2zyj3pSbGAZV2fQt8VCGOCfQioR8ODxxH9h5u4TF8rjeYyFFq
         FoUkFF9BV2+pjnkgy6J+GSuF+PeKQ9y0qC+gIkhYxbQ1VF0+1Uz6hTrDPiou7e+nO3Sd
         G/tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=+muWnmDnL8oDPBA3wIcHek9GRIbdD/+2O0D6DSEsRhE=;
        b=Pl+G0W2wJzAqcbAySdMa4h6ZFoUVzaLrgWir0xXG4wna8Dcc70Vj9xcloxQjqkAGEt
         RVILQPQkF9a/B7X5veM1xjoVfHl+ZZ905ReiSqtYgb8uRn+vTYdnrzTxpQymi3NUmv5A
         BIv5O07/KV13A+vYT9KlFRYPNKmghj1NOJpxyr1NT+LDvThTbSd1N0zgDfXdIrxBrNgc
         j71lAs087SLTpuhOPPzO/tdk5pWzIJFIrPVSLx9l3sfKF7Bwx5GMUHmeBKY4aQPMW1pj
         hs3KzV4ejFWz+wHd3Hmj1NMgEsSULMQKh0nJTLNkj5fStccAHEpFiNFrLvWx2OBVksek
         hbdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h11si11549109pgp.391.2019.04.02.12.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 12:12:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id BA461E93;
	Tue,  2 Apr 2019 19:12:40 +0000 (UTC)
Date: Tue, 2 Apr 2019 12:12:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: "Tobin C. Harding" <tobin@kernel.org>, LKP <lkp@01.org>, Roman Gushchin
 <guro@fb.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
 <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
 <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel test robot
 <lkp@intel.com>
Subject: Re: [PATCH 1/1] slob: Only use list functions when safe to do so
Message-Id: <20190402121239.76d64e3c262dcb24ebcee058@linux-foundation.org>
In-Reply-To: <20190402190538.GA5084@eros.localdomain>
References: <20190402032957.26249-1-tobin@kernel.org>
	<20190402032957.26249-2-tobin@kernel.org>
	<20190401214128.c671d1126b14745a43937969@linux-foundation.org>
	<20190402190538.GA5084@eros.localdomain>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Apr 2019 06:05:38 +1100 "Tobin C. Harding" <me@tobin.cc> wrote:

> > It's regrettable that this fixes
> > slob-respect-list_head-abstraction-layer.patch but doesn't apply to
> > that patch - slob-use-slab_list-instead-of-lru.patch gets in the way. 
> > So we end up with a patch series which introduces a bug and later
> > fixes it.
> 
> Yes I thought that also.  Do you rebase the mm tree?  Did you apply this
> right after slob-use-slab_list-instead-of-lru or to the current tip?

After slob-use-slab_list-instead-of-lru.patch

>  If
> it is applied to the tip does this effect the ability to later bisect in
> between these two commits (if the need arises for some unrelated reason)?

There is a bisection hole but it is short and the bug is hardish to
hit.

> > I guess we can live with that but if the need comes to respin this
> > series, please do simply fix
> > slob-respect-list_head-abstraction-layer.patch so we get a clean
> > series.
> 
> If its not too much work for you to apply the new series I'll do another
> version just to get this right.

I guess that would be best, thanks.

