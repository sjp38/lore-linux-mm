Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FB76C76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:04:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC021218EA
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:04:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="eCJDQVgp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC021218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 676958E0003; Mon, 22 Jul 2019 12:04:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64D908E0001; Mon, 22 Jul 2019 12:04:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 563808E0003; Mon, 22 Jul 2019 12:04:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 364DD8E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:04:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l16so29290330qtq.16
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 09:04:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vwvk1p704PvrHoU3x+syVrBIr03+GtruOtffq5nOmqI=;
        b=WFxHGfow/nPqkZNdBXn4qM0UKN379Ns5uWt8ZlzvMT8LIakbLWPuE+6i4vvw/+IT7a
         aInXFF+HZ+ojclMdmAygNJSLbPxJojIDTQGctAjR/XYW/cSCvAxQ8RYbNkmW/rL/wN8z
         uP3IrgsawihO4XiOWLmS8RQo5tn6Rw+9GNpBA/bTji/zVOaNwiKXS19bH/UeRsVgYLFR
         VHgKPG6oB5LE6Rk10JBLmhByjH7QK48sAV7aKrtV/jGrpkRAtrFrdeECO/TUdowkrFnF
         CFgcJ2Z0fK/b6L1+0rqoKJRhc1C2UQDgiRjLZMLZ3a/2CSm2GbxUBxnAcSjU3j6XGAic
         9TMg==
X-Gm-Message-State: APjAAAWeHKUtnyBEbRM1xen0hf3yMBOxbNTj8W8bnnokaHEB1UfVX/oB
	y1LExf7Ga3NXNgxuMYuB4iWwBZ/3Om38qJoPq3O8AsDyvZk1of3J+agnU5b7dvmc2FzQrxYgCu7
	CfNvKhO03ZWWKUaIyFUAWsWFqqcro4b6xD5wA7h6vpl0CC1fbklX6g6TYxGMcyNcVuw==
X-Received: by 2002:a37:a58f:: with SMTP id o137mr48055276qke.84.1563811490906;
        Mon, 22 Jul 2019 09:04:50 -0700 (PDT)
X-Received: by 2002:a37:a58f:: with SMTP id o137mr48055256qke.84.1563811490417;
        Mon, 22 Jul 2019 09:04:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563811490; cv=none;
        d=google.com; s=arc-20160816;
        b=C7O2IfS9C4bjGLbIIA6Tz15okuT/2UCFqK3jlsXOh7pZtKZW52ZQ0tiLnMnMRyu+vq
         430BOOsP7LEvqBaQVUMqEq9GVt3mNhKTP1UnZvuv+Rpx2pF/Q0+/3pbVejiGqMyyMM9V
         BHSNX/OhuBmrkH3BFPDEA1ATKxrqOW6nP+YOcfw80Xbeg4829W9z/QKNOWYmAM0w1RpV
         ryUGMcGfWPBzpUk5iM/4eh1bpdXmxNUjvdpOC0xD62/ACTebDoo3MNTUkWhAKEVyl7z7
         NA5gwG2yvfjT3igLNo4USda5POyNtjlOnkYzhvu8PaJ/+jGBw5laKieWDfr2x1FketyW
         vQjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vwvk1p704PvrHoU3x+syVrBIr03+GtruOtffq5nOmqI=;
        b=z/XOMo4aQQrIJOScMj0NwxRkS+9i1+1/J6n6EhRi/Z8p6LKY5Hy2sSxoof3c9DNdq8
         kok3u2nUBIASNsU9Fr21Y7gPQBEHSc/+q4wkooWNxkgnAJS6UckeWcIjhLhMKcbrFT3P
         cW9huX9CtMOrfftuVAdsUud4HSTOJoJCR72WFGJFbKrM7OgGBkJX1X0Zv+HfMeTKAIfw
         TtpZt6p2Gp1tekAf5WY4oXFx/G1+T/p5bcwsSScz3oi2EJ9+LoM7JH7GLDn+SXOp25nK
         T8kIY7YRSlt2kwmcajbPkDUa6lLtnB94xca3A0bKr8WucfVWtLF2usDJKhnhILwQ5PK+
         kIfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eCJDQVgp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19sor53739664qtq.45.2019.07.22.09.04.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 09:04:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eCJDQVgp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vwvk1p704PvrHoU3x+syVrBIr03+GtruOtffq5nOmqI=;
        b=eCJDQVgp/TUa3SJDw5YNpJdxoRLDUf0uKWF8HiEN2E6tOilw6te7IXdJ74mZFUYqp/
         9cs4iQsc0KiVAOncyf/4OEnDeZsuNdAdxwUKQmiZzySVbAR5OjTuhXiGRkV1rgBYswjM
         IQx0Ulu4NMDBwDAviDS9g4pKXJW+xpv+Iy8d6aVLlz84ufr1JzYd1aeEamQT0VorPgKU
         QT1i21qMa2c8H2+8UBfm4o25QcGgTYS7VKw/3eTMHAe7UkpWzGXLekAdlCSWusHGhsa8
         cEkwa4My8xWUN30i19bWw4qGMFPnC91vuvyuUJqr/Slt5ziIHR7WpgLw+5d/ULuZjsfk
         lFPA==
X-Google-Smtp-Source: APXvYqwAqmiUCOGD8gRTdb/gKf382wokrezGvhSEToPpHN31WEGoX97JjGxgPReHba9ZDH0CrbO+rw==
X-Received: by 2002:ac8:431e:: with SMTP id z30mr50035442qtm.291.1563811490053;
        Mon, 22 Jul 2019 09:04:50 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id y3sm20100502qtj.46.2019.07.22.09.04.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Jul 2019 09:04:49 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hpanw-00059A-U7; Mon, 22 Jul 2019 13:04:48 -0300
Date: Mon, 22 Jul 2019 13:04:48 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Matthew Wilcox <willy@infradead.org>, aarcange@redhat.com,
	akpm@linux-foundation.org, christian@brauner.io,
	davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jasowang@redhat.com,
	jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: RFC: call_rcu_outstanding (was Re: WARNING in __mmdrop)
Message-ID: <20190722160448.GH7607@ziepe.ca>
References: <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722035042-mutt-send-email-mst@kernel.org>
 <20190722115149.GY14271@linux.ibm.com>
 <20190722134152.GA13013@ziepe.ca>
 <20190722155235.GF14271@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722155235.GF14271@linux.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 08:52:35AM -0700, Paul E. McKenney wrote:
> So why then is there a problem?

I'm not sure there is a real problem, I thought Michael was just
asking how to design with RCU in the case where the user controls the
kfree_rcu??

Sounds like the answer is "don't worry about it" ?

Thanks,
Jason

