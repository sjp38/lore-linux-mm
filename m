Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C75AC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:46:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19F25214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:46:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="Hta5ADB6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19F25214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADD828E0003; Tue, 12 Mar 2019 11:46:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8B348E0002; Tue, 12 Mar 2019 11:46:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 963D48E0003; Tue, 12 Mar 2019 11:46:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 668DA8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:46:55 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id r8so3929052ywh.10
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:46:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=KAk4IsDkb3zX1TlvrC20u0WnLUP+Dd54wGHpONRxxAo=;
        b=feAooy73KmrzE9Z3V8ke2fnvVZuU2knXhRJ8yBSeqEhPfTgVtvP3POZ0v3O2S7U3Bx
         bQYeBA1mMXrIQVCK7OXzindsG6ECDBG1aW12WjIgCv5M4j8SXCH8l42ENMqC143eNgdL
         05L5R55XYSrkHhDRC9L1/FHT3rY9wqC0PjhVUlvGgh0owv4NlqdDYEicx+1x8MYyDvRl
         U9v36ViGkJFTBomEosUNdRHMRZAZNE6U0zUGBsTsX2royoBg800bu1uRwIR8DuBrcfdb
         bkRA5fJdt6dbtwcUucZe7EYUdRhKI+e/cVlzRC6tbSpw64P8qU9pr3z31lIxDrxrZGaW
         t3MA==
X-Gm-Message-State: APjAAAWsvpepD7eN0PF0PV4hAhFWOSskFUK+0dZjUUvIN1DdoKqIcHYh
	U7oyCp0fdNL2NOhwRm9F3zc0jniqLztkan+G/YLVW8Wxuhgvok/MLdPe0rlybQhd8DhjWiln5CT
	/EIVDNoNKM8hBYt6r4NbN80ymyNUjQAZgAcbW4gJm/FlD5tLfZJRMeJLY5kReMxOMYQ==
X-Received: by 2002:a81:24c2:: with SMTP id k185mr30836598ywk.179.1552405615108;
        Tue, 12 Mar 2019 08:46:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzf4pUBu1gQ5qVLT833CmiM+rKL6qKOhfgz6RSG/FTbeBh3MhUDgPAyrmIG9hwtglWhK7hr
X-Received: by 2002:a81:24c2:: with SMTP id k185mr30836547ywk.179.1552405614284;
        Tue, 12 Mar 2019 08:46:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552405614; cv=none;
        d=google.com; s=arc-20160816;
        b=PBhdxcYAbKrr+wZuvmM35/jdutnyziXM6w+g01RWHZ68GcZjnBhGFmga6kRsp2LmAh
         gWGKD8i/LsQhMOWNIRMjiMdwiWTrBkxUyzujoi6v5S+5X6tLXG0TL/x3Dwjd3+09UjdC
         umUnTcPP9Knb56E0ZOsA16P/I2eItsg1zWvb6ScehYKCAMHACzDjKVAKdpYdaMqbxG3W
         VqTWPIHiWti+KGQ7TDI0f8r3HRme5V06Kg0n1HD0DNWWyayFERgwo8pckqOutv+opxV3
         v2k5p0jYjxRny0pbLLGaul/SrDrCa8dCkf6CVahz8R4MUbSVqAUbBrJfKBYW9IGJw9V9
         9/SA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=KAk4IsDkb3zX1TlvrC20u0WnLUP+Dd54wGHpONRxxAo=;
        b=TvlS7k5z26w8r6nOjAKO6XQFFcsMYRvB9sGlPZO98q+exS/nsrZQE9unIVhRkK5m4A
         jZObzEptGI1UA1mfexaru1IzRBZOwzojKfdFE57EylqhIVtDfcO+/4SI6dXx5J16lKEY
         JotmTfRQYYJFbl/T4thwqg+rbOJiqSYk8vi/NSOypcrc4VpFHc10/fjLiUym1iH36l6u
         Bcbk8lnDq0YpB9UC0FHcF6Z97kURIJ2siWAVyrpmBYv4bQND7G1YpOOfRLgAGlpfwXf5
         WYQvgJEe5wDX8DitmstgWU5enUe1oaVPwcQb+VXNHbzwkdmxUALh3SaYJXIYdzsW4PRE
         3L0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=Hta5ADB6;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id b18si5167947ywh.298.2019.03.12.08.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 08:46:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=Hta5ADB6;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 6B8298EE1ED;
	Tue, 12 Mar 2019 08:46:52 -0700 (PDT)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xRUipMi-5v4r; Tue, 12 Mar 2019 08:46:52 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id ACA718EE0F5;
	Tue, 12 Mar 2019 08:46:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1552405612;
	bh=rtBt5DLADL8t5XJ0aWEYYr4qVgiTJN0Y03AmnFBmALQ=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=Hta5ADB6diO123b+O9GGsaD3lTLmZxm0/SklZjxqjxFxREBbKMqH2pQq9KC9TpqUY
	 FtBLt58elI9vQLiHqAfSyBBJn+aScF4ecBuiM54tPSDYp7m2jwOVqEwLyHHPM9lpUr
	 kiGaEaRYtHEEndxKTdxFwSggNcuYAAt4p59ArUEw=
Message-ID: <1552405610.3083.17.camel@HansenPartnership.com>
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>
Cc: David Miller <davem@davemloft.net>, hch@infradead.org,
 kvm@vger.kernel.org,  virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org,  linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org,  aarcange@redhat.com,
 linux-arm-kernel@lists.infradead.org,  linux-parisc@vger.kernel.org
Date: Tue, 12 Mar 2019 08:46:50 -0700
In-Reply-To: <20190312075033-mutt-send-email-mst@kernel.org>
References: <20190308141220.GA21082@infradead.org>
	 <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
	 <20190311095405-mutt-send-email-mst@kernel.org>
	 <20190311.111413.1140896328197448401.davem@davemloft.net>
	 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
	 <20190311235140-mutt-send-email-mst@kernel.org>
	 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
	 <20190312075033-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-03-12 at 07:54 -0400, Michael S. Tsirkin wrote:
> On Tue, Mar 12, 2019 at 03:17:00PM +0800, Jason Wang wrote:
> > 
> > On 2019/3/12 上午11:52, Michael S. Tsirkin wrote:
> > > On Tue, Mar 12, 2019 at 10:59:09AM +0800, Jason Wang wrote:
[...]
> > At least for -stable, we need the flush?
> > 
> > 
> > > Three atomic ops per bit is way to expensive.
> > 
> > 
> > Yes.
> > 
> > Thanks
> 
> See James's reply - I stand corrected we do kunmap so no need to
> flush.

Well, I said that's what we do on Parisc.  The cachetlb document
definitely says if you alter the data between kmap and kunmap you are
responsible for the flush.  It's just that flush_dcache_page() is a no-
op on x86 so they never remember to add it and since it will crash
parisc if you get it wrong we finally gave up trying to make them.

But that's the point: it is a no-op on your favourite architecture so
it costs you nothing to add it.

James

