Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C511CC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 10:26:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A54520651
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 10:26:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i7Nt6xRk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A54520651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 263CC8E0005; Tue, 30 Jul 2019 06:26:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 213218E0001; Tue, 30 Jul 2019 06:26:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12A4B8E0005; Tue, 30 Jul 2019 06:26:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D56E98E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 06:26:21 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22so35065311plp.5
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 03:26:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=B41dOFAL1OVXzo32k2PddSinndYgRrLzOceWuj2dYcs=;
        b=c54jFSPGKi7Q5+BjLvqLKYRf7mHh20RU3rtE1dkgqZ+f+gR4e9tKX5G2LB3ltP4ODO
         PkKp+F7N4Iy3u3vCquPVLg39/z8R1QFVTkpxHG4ajn5OsgQE12FSzJwx0KNL0MZSDLDh
         fkcwhTij4TfxwRfSw7qbJZUCfRtGgo36Yq5gOE0zd4KGPsJ+QaNWQpxGtHVEtiCDbZSL
         raU8r1ut+/Yr+euz2znB9wPgYP64IFRLmDx2lRB1VQLp0xiSXyhIGOE2Xdwz+7wLgfiI
         F7b15HgMH5TspI4xyj00WzZ02cTsTowccQUiL0pP+olUxyxbOzTg0Xc4XCHqMWeDz9DP
         tfLw==
X-Gm-Message-State: APjAAAVtY5fKE0OH1uy/kJEjWjhk25qNbJY2Eu90LbRuXx2jejIxta3n
	VNd7ExMZbOOkjWI9GIjd1Ps8hrKvwTOEFBM1Bce3f1H/dwN+SnNAdHU9CKoHD4lju9phjOeM1mO
	gITsrdtyOV7W0GqIv9uMYOTAM5Aw7xaYygSLDVWcsRzDzhqdaXBwqwfm6a6Ksmssn/w==
X-Received: by 2002:a62:38c6:: with SMTP id f189mr41256023pfa.157.1564482381464;
        Tue, 30 Jul 2019 03:26:21 -0700 (PDT)
X-Received: by 2002:a62:38c6:: with SMTP id f189mr41255985pfa.157.1564482380873;
        Tue, 30 Jul 2019 03:26:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564482380; cv=none;
        d=google.com; s=arc-20160816;
        b=YxvsCWU9yu+41zGyL+OtmmPaGjmMWm5BT9aba/79oUb9xNIM2z/ot9rUQ4Kvd3+jlF
         g5EHzgttZ2e1FfRS4SJ4yu0nK4Qw7M/Al3pBDHJ9iFuXs4k9fJ1o2Qrf/lbD7dEhMxul
         dmV1L5AG/RVR1ZCzaz8QOUAGP7w73N4pKDDhl75DjyLEQv27z70C3PyXRSH9eeW0OIpq
         +Mzf3hSorwhAjhLLp96fq614DqDgf7XSyBjZzbhQrrdXF6jZIhp5OvTCwpEBmdbovwE3
         IeIRIy9UwltkXo2rqgZAO1fcu0dlB12D1gWWINCgwP9YZ9mrewgKxOm/eLsMbzLAM7EE
         G+3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=B41dOFAL1OVXzo32k2PddSinndYgRrLzOceWuj2dYcs=;
        b=AK8EJdRhPvL5hR7EwOlm8ozUmpoFzA+Y5Y0dKGUdiEs5RjHODIqTWkEkiGZDXjceI8
         2nLTcaTulpZvkC3eBgrSs7Ium5sI2N9E//lGp3pmkwj8Kpv87QpRslP+JDDrsbtdxKoJ
         7yJhvVYwKa23E49+PTDN5nbDhTCu5OEOUB3e8sIsOMBlMPTn7oEHeqkS3ThQTjQABEEX
         e+KEs5e7f/yHnTyFjIRXZrDOhlevRW+AkPfxkWJ7szinoIZy75fqVD6amK7BwRSs9JLk
         7ruo68Xu5gGA/2TdSG2iV0XZ8FSiyqLgTv62UYOdq3AqVbw/uvLPZryyk6JzoyIBCyrz
         dsjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i7Nt6xRk;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n2sor7386423pgh.45.2019.07.30.03.26.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 03:26:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i7Nt6xRk;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=B41dOFAL1OVXzo32k2PddSinndYgRrLzOceWuj2dYcs=;
        b=i7Nt6xRkRfvFCCVipqPhPmUZyVmjuAdk9XvMcLtySbCYdYJr0vMsYhkTiIE9qVDOHK
         SYduOpEPzNTNU5fL7XIet0nzi6Hb0+Y3MRI3ycdjx2r32drhNk7ebQNjBQGTP9L3tAY3
         xKPu4OsR0YLH3RZC2tU5A2nV/QJ67w+i5ahlw1mXgS6rsDAYqvvDJLJJNvBcXv3GIew9
         y79fPpsjqTXZT9WvjGuTCjzDuG1NsHjVuLpPyPCoLsV/cBeumt/X/6hYWs1CZ10UZnb3
         wzAqKqygyn9ZasPXv3I83Lsa1RI3RpJFi48CFo98NxQjSZfnpYYDmXF1k5mbARh5QCQk
         TFew==
X-Google-Smtp-Source: APXvYqxOncBM7FFqx4lditTRj2caSLMJ9IX+bFXJ4D8j7fqT/1w8OoqWf5bcpF3t2GTiYtSsQvUPSQ==
X-Received: by 2002:a63:3281:: with SMTP id y123mr105781516pgy.72.1564482380523;
        Tue, 30 Jul 2019 03:26:20 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.31])
        by smtp.gmail.com with ESMTPSA id k6sm74255606pfi.12.2019.07.30.03.26.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 03:26:20 -0700 (PDT)
Date: Tue, 30 Jul 2019 15:56:13 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Christoph Hellwig <hch@lst.de>
Cc: sivanich@sgi.com, arnd@arndb.de, ira.weiny@intel.com,
	jhubbard@nvidia.com, jglisse@redhat.com, gregkh@linuxfoundation.org,
	william.kucharski@oracle.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v3 1/1] sgi-gru: Remove *pte_lookup functions
Message-ID: <20190730102613.GB6825@bharath12345-Inspiron-5559>
References: <1564170120-11882-1-git-send-email-linux.bhar@gmail.com>
 <1564170120-11882-2-git-send-email-linux.bhar@gmail.com>
 <20190729064842.GA3853@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729064842.GA3853@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 08:48:42AM +0200, Christoph Hellwig wrote:
> On Sat, Jul 27, 2019 at 01:12:00AM +0530, Bharath Vedartham wrote:
> > +		ret = get_user_pages_fast(vaddr, 1, write, &page);
> 
> I think you want to pass "write ? FOLL_WRITE : 0" here, as
> get_user_pages_fast takes a gup_flags argument, not a boolean
> write flag.

You are right there! I ll send another version correcting this.

Thank you
Bharath

