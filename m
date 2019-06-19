Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEC3BC31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:34:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9184B2080C
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:34:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="FKAUonMZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9184B2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7B946B0003; Wed, 19 Jun 2019 07:34:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2C8F8E0002; Wed, 19 Jun 2019 07:34:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1A8F8E0001; Wed, 19 Jun 2019 07:34:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1A8D6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:34:54 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id i196so15225452qke.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:34:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Lo9X66uznaZ6SGYkNk0Sx1BYJ1CIYwurC70zh2R4uz8=;
        b=lNhY7WWc3PP43c9k+je67/whNISocGgPjyNOnLcY9CzPMlqIdW/oVpm28Lw/KUP5uu
         rEGbtgss2Y4w7A7asJ2Nos2CthK0dtLczKvbu33vn/7CiydsQAal3NufZmoLL/LV7VZu
         zyrXl6UNuaI808ZX73zg4Ah/l71Is8CcaqWhtRAwRxZXAX+ZxDZ/ZEcSzPkanjpDeOqM
         G+lD+5a3/hw+aeRvhPsJFAjeCYnHnHB2V+txsNj56fVv5LtVMrmnTguJ8za3T+m76+ep
         pFMezYmXRdWwKMdAibTRa0oUT+nEuxBGUEFgRUirVXP5KnC1t5bqce0D4d392WjjOe7s
         OmAA==
X-Gm-Message-State: APjAAAUB1Sj1OWv+q1J4RIFftDYindZpltuSa1BIqituDuOZonVeMNEy
	sADTZJ5+doR8/ukJ+YYnGbLXAJnHzYOu7m44/FN1cyvyKhC0nnLrq7JpGNNAwHsX3p8Pr2rCwcv
	opESApOJs5rqMtWTaThrBsuiqkMtsVhpLrAaooltAj0vVRl8Nt0XXceIhm2QGViNZXA==
X-Received: by 2002:a37:634f:: with SMTP id x76mr96931920qkb.205.1560944094495;
        Wed, 19 Jun 2019 04:34:54 -0700 (PDT)
X-Received: by 2002:a37:634f:: with SMTP id x76mr96931877qkb.205.1560944093750;
        Wed, 19 Jun 2019 04:34:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560944093; cv=none;
        d=google.com; s=arc-20160816;
        b=SGXXxfU7IZxqBJVpaRfwmOsCdzAWMGYjN/l1vzam9cb5dShwBuTMSIuYzESoBvSkEu
         Ssng71HSt659BzMhkksUhBXJBNB6wR3XcBsfnvP1WvT2U9GCE9Sqq8Ed/wHij2pTKTmx
         ZDaHtbjPI8MzFMK+8hdY1LSrLzlIhRf1FyGNsqkdjEVPZ0CqTvLrxKREWE0IVLoUKZZo
         soR040Ug1ySXxDVloXosWP7tq7yeCc0bo5/DnHR5Hf8EB3lnvtQIb5sEMOR5JC9v0bkq
         Ey9IotE0yfqGtaGM4mLZH18QOlpRMT2xXHhet92SQJHYd0SKDuCL0wscY4Pfh4gl2zbx
         2PuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=Lo9X66uznaZ6SGYkNk0Sx1BYJ1CIYwurC70zh2R4uz8=;
        b=zc9uTzjHfVku3TQO2FKUrZmbuieQMPpgpmWN2jgvKfxhZd+2CHbhdbI7VRG4FqR1oY
         XErJ2zzCqkRcIFHHmvD1dULOXultraypc2idquRHaf6lQ2N4LrvUKICD6a4L/UdwDt43
         XJLw/dsBhb/x5xgRcYZ66Adz+ITq8U6cwde7Ahl8SvBKz8wDlr2aRzN7iWBWjA42yaTh
         By5RgV/VGW94p62Tr57ILfogF8NRDKfL88GgbDfZAN/TRfu5J+k8PF5+nq6iR8L+JaW4
         eU2G/lvZL4vKUfKCkNe+1AxYcWg95kIyuJOsASiOl6DnXFeHcTHeZtdijMZ+wZZ57guS
         ovAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=FKAUonMZ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a14sor15583949qvb.23.2019.06.19.04.34.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 04:34:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=FKAUonMZ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=Lo9X66uznaZ6SGYkNk0Sx1BYJ1CIYwurC70zh2R4uz8=;
        b=FKAUonMZk1gq68qWyHk5hxQwjYagl4YsmsAJviMRujON6p/cymKi6K/YRCSBGj83zJ
         JkfE/8aIyLUhGGY3g43VYw3XN/P1XonbUFKtelLRQiEwpnDabiu0XyHp4MTd4BxXnjq0
         V7oSMVDQ0B9LhdM9XamUqUYQ5FEAD5RlNAb4/W6UMjxMBMs9JgY42UFu4GcvX+n/zWDK
         MfPOy1Eqv9vEhMluQPKsGeBikLCd90E0ip1ORNx/X6O84GweOuD7mvfqOcigbyXMEBZB
         NoPogRjRvgMiG+lHlke1ShBBcwTOJQM51QTvE9P4WYq9zRxtb4rz854nmVnQvJZtVMtb
         Qb+A==
X-Google-Smtp-Source: APXvYqysE5jQwu5IGvItnPtoqMfHXLCakREbAz5IbbNkflU7Xd2VYz5hjEn1/wSvLEs0Ks3ehAZ0LQ==
X-Received: by 2002:ad4:5388:: with SMTP id i8mr6987929qvv.166.1560944093328;
        Wed, 19 Jun 2019 04:34:53 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i22sm10799810qti.30.2019.06.19.04.34.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 04:34:52 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdYrc-0002xP-6l; Wed, 19 Jun 2019 08:34:52 -0300
Date: Wed, 19 Jun 2019 08:34:52 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 06/12] mm/hmm: Hold on to the mmget for the
 lifetime of the range
Message-ID: <20190619113452.GB9360@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-7-jgg@ziepe.ca>
 <20190615141435.GF17724@infradead.org>
 <20190618151100.GI6961@ziepe.ca>
 <20190619081858.GB24900@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190619081858.GB24900@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 01:18:58AM -0700, Christoph Hellwig wrote:
> >  	mutex_lock(&hmm->lock);
> > -	list_del(&range->list);
> > +	list_del_init(&range->list);
> >  	mutex_unlock(&hmm->lock);
> 
> I don't see the point why this is a list_del_init - that just
> reinitializeѕ range->list, but doesn't change anything for the list
> head it was removed from.  (and if the list_del_init was intended
> a later patch in your branch reverts it to plain list_del..)

Just following the instructions:

/**
 * list_empty_careful - tests whether a list is empty and not being modified
 * @head: the list to test
 *
 * Description:
 * tests whether a list is empty _and_ checks that no other CPU might be
 * in the process of modifying either member (next or prev)
 *
 * NOTE: using list_empty_careful() without synchronization
 * can only be safe if the only activity that can happen
 * to the list entry is list_del_init(). Eg. it cannot be used
 * if another CPU could re-list_add() it.
 */

Agree it doesn't seem obvious why this is relevant when checking the
list head..

Maybe the comment is a bit misleading?

Jason

