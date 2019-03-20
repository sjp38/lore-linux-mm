Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5D08C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:43:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 813F92183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:43:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="VBwKJkug"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 813F92183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C56F6B0003; Tue, 19 Mar 2019 20:43:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14C836B0006; Tue, 19 Mar 2019 20:43:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F338B6B0007; Tue, 19 Mar 2019 20:43:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C4F096B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:43:12 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t13so19503400qkm.2
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:43:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=B9sioxXwJ8rVpdbilI7Fnpz1yz5RdR7tc4Xt5PO+emc=;
        b=XNfmLJi+Z05PNDoZgk83YrgcPxjBFtw1xfzgbCXB0oA+j7kS6bIOI/+HRqP0gsfg3W
         eegb2pvhBSRE+9ZgodzrTiesgVng3KxqBqeZD3vTSeVW7dIHC9TywlPZV/t5IBOmZ3rn
         5MM4zIgVC/IUuxh4u2h6lsFwH00npzkArMFXfMlk3Vl3C6Mx+orvCDI2WUVjW1P4u29k
         C5/HdTsLs6OKNHimNA3kidSPRc8gfx+hvDDa3x7raen348SWEJoYDILv8zQY8EHt0nR4
         EPBwFb8/hZ8ry6HYAJLSTm8j1MbhbO07xLwAOvGdCHZbWCWj8NF84Efgk0Aak8RmTle+
         CfyQ==
X-Gm-Message-State: APjAAAUzj41ypWF/1dxXEPm6PlqqE60WfQn7DMiTgRXRljqjJdUrKblM
	MK9uMkeSdrA8CTgydGdOOcjzCzFstvwln7a31nKVyCNXYwi4fAH26TaoFvH0Ew2obLzQMqylym1
	spI4uPAkxa4m21xmDyn1KdbAGJhwnE8MI6In9LtCQXO7xVYnFOfrTc8qKk3UTdt4=
X-Received: by 2002:ac8:3821:: with SMTP id q30mr4494636qtb.73.1553042592542;
        Tue, 19 Mar 2019 17:43:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3vcYgUU4HhILRX1l+9N8K5L8iCYpMwhFaCxY42g0Q2/G3AmTbPH9thb++kfhoT+yFEyc+
X-Received: by 2002:ac8:3821:: with SMTP id q30mr4494607qtb.73.1553042591915;
        Tue, 19 Mar 2019 17:43:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553042591; cv=none;
        d=google.com; s=arc-20160816;
        b=v3OVILiXk6l5EIlJOhKnKY5qqhjdG9fSsweIfsbgr7B3HpY706CXNwHnR+YK42BMvN
         CmLWf1ABBstu9cIz6kFi5w/XD0NMnndb5BFjlXaWb0REJM4odssbnlu6wc564mhUIZlq
         ULFSLPaxXgrAT6FfndxxFdqbQp0TzPxIY+bbdwZVMaW6z5kADh9sRQXN0T30k+c38HVi
         D5lkcUe64ahFuQLhVEt+IseYklxm6ONkv81MMxCoe/d9R4Cpo9CnOXP/3KCXXKjWviAb
         ab5mX2EZqIzDXevbVyXGCB74oypilvApTZzi9CqRaDU+lREPfD0xyRgx7C2n45QkB+1H
         XS6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=B9sioxXwJ8rVpdbilI7Fnpz1yz5RdR7tc4Xt5PO+emc=;
        b=CYt+tyReMxCcc+uDYsB10mEj3cxD8T8WAMejqAo7fZc0Q9YCGpQlQDN8ZCPZXJYzTV
         bxlckQ8BgOjwTZmB0nthnpFRlswi9eesgX/jjtJIOOcQKdXPhWBKXmQGuRlR2M2vkUPh
         Xer73ed5uOsSWkUfLJ3y7n4Hh3+BK5WXm3tVxz6cqET4AU6BJ7pPTCG35EieLpMGcMaC
         UZrVRJapgPwdzVSSa4Zj0dpn9jU4MbS1PJDvsW7TVsKRJPXXh4mRh/xTqSopYqg18BH/
         K9QchnPiehJW1yH0U5EZyx7QYJMv78Lt7xr/RvbVI25QNbQbPOGmDuaI10lQadeITO+Z
         dHJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=VBwKJkug;
       spf=pass (google.com: domain of 01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@amazonses.com
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id m65si307362qte.177.2019.03.19.17.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 17:43:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@amazonses.com designates 54.240.9.35 as permitted sender) client-ip=54.240.9.35;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=VBwKJkug;
       spf=pass (google.com: domain of 01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553042591;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=B9sioxXwJ8rVpdbilI7Fnpz1yz5RdR7tc4Xt5PO+emc=;
	b=VBwKJkug3HTMEURo5qyOD/z9okFI4YVhcpxmD0DrF5468WQ+ew8H9nnZbSc3g7aC
	73YNYCesh3CpjPthWstPYZD59v0KRTJ8bhUvP+WmW+teVrsGiQTJDhYOAccKtv58/WN
	ama1QEg4t9G6OAHEP7NJs8i+YtezrZ212eZIzZ8g=
Date: Wed, 20 Mar 2019 00:43:11 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Vlastimil Babka <vbabka@suse.cz>
cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>, 
    Matthew Wilcox <willy@infradead.org>, 
    "Darrick J . Wong" <darrick.wong@oracle.com>, 
    Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@kernel.org>, 
    linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, 
    linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
In-Reply-To: <20190319211108.15495-1-vbabka@suse.cz>
Message-ID: <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com>
References: <20190319211108.15495-1-vbabka@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.20-54.240.9.35
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Mar 2019, Vlastimil Babka wrote:

> The recent thread [1] inspired me to look into guaranteeing alignment for
> kmalloc() for power-of-two sizes. Turns out it's not difficult and in most
> configuration nothing really changes as it happens implicitly. More details in
> the first patch. If we agree we want to do this, I will see where to update
> documentation and perhaps if there are any workarounds in the tree that can be
> converted to plain kmalloc() afterwards.

This means that the alignments are no longer uniform for all kmalloc
caches and we get back to code making all sorts of assumptions about
kmalloc alignments.

Currently all kmalloc objects are aligned to KMALLOC_MIN_ALIGN. That will
no longer be the case and alignments will become inconsistent.

I think its valuable that alignment requirements need to be explicitly
requested.

Lets add an array of power of two aligned kmalloc caches if that is really
necessary. Add some GFP_XXX flag to kmalloc to make it ^2 aligned maybe?

