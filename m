Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC622C10F0E
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 08:00:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E37120B1F
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 08:00:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E37120B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C2066B0007; Sun,  7 Apr 2019 04:00:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 170836B0008; Sun,  7 Apr 2019 04:00:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0601D6B000A; Sun,  7 Apr 2019 04:00:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF0946B0007
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 04:00:34 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id f11so2596478wmc.8
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 01:00:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=csV0JTqzeAjwcMrmBTtPwMmBajuE/7/DOgkBiGrP9h0=;
        b=iJJD40g5L9vF8P8191bT2/IxKhiJiE+XBxqdoDAdvJXwbSzpCv9WDne2/1RrE3+ZhF
         WU6A/K9F9HR5wB6yssFfGoLAZLGNoTDDccAqN/atqHUV1vAjyysTfgp4Q7MFmtjJmQ36
         CmN9fChar+PyYv+EtL7B3gGbHA7le71Bu3N/wNtffiRA16SoCPeawho9yQGDyKNxjtQe
         BQOysNB6HzMT5UOH05c1hX2ViAtI3uQevJQtqY9RJk/bfwU0yi4HhFobiKj2Q6bHz2UL
         AYovmmpt1ETVff7998DcgjOeYPaSI0wSkr5bpn1oxMuX3ayyDELyIZhI99jH/6Hb3bqK
         +O2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAX4z197wgzAMuXOBGjozOKE72A7HAwBIzXt40GcuPdAjkuj4Nlz
	dm32VJl9N7YM5k2KZnd+6PrSqtBZ3SYl4bSh+RyTfs7MJUKAnacYpmQri4OUAPMfEHIfbdce5Ye
	r99X0Be9xCeUbtxwo8yN7eDRhQZ0X3MqXkWXt1BHKuGctXFtgqWZjrfWb2rksjUNmHA==
X-Received: by 2002:a1c:f504:: with SMTP id t4mr12665121wmh.121.1554624034226;
        Sun, 07 Apr 2019 01:00:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTrCNOC0dCXxkuxfJCVNK+R6eRTrj1mjp0YRX4g+tg35VDLN8FJRXk2NXgYAn33Fl5sbzP
X-Received: by 2002:a1c:f504:: with SMTP id t4mr12665076wmh.121.1554624033278;
        Sun, 07 Apr 2019 01:00:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554624033; cv=none;
        d=google.com; s=arc-20160816;
        b=jvKBAS08ar/5O4+0xLPKrxju1DbiThZI2AS7qreEYPznqwNNmRXRn3U4kW/C0cVP8T
         etuthKeZWA2hDZuZpEMLPUlDAlAx4quemRksrUyGtlCOqagC5zjMdN9o6Q/UoItoVvSD
         tVK2o67oGNl2hTP1I6QRKAvxpUL53D38h+feWHk5/ogd539iPiiq5jxgUaTwtuK9o/Ml
         MlxzCQhQWOEK/dhO6OtdDUZhIzIy21mTjLKFMHpbFOG6Oi6vmKig9zG2lJIiPITEQRUS
         n65JBrpJBh5P/waKzD0zIrRY3QP6aCGOoXnGNTjq3386chSVHgPp/dd0IqhyT52CCVjZ
         jEBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=csV0JTqzeAjwcMrmBTtPwMmBajuE/7/DOgkBiGrP9h0=;
        b=ugAmVxK8Zdr2oKZ7ZyamDOkPGjdrinX1THiofCDRqxY5xnfprBDkhkpzBB5FFVKTV7
         wbSchE4yh+Cq+x8htxGXaeuCibet4Hzv9KMFIbcAB+oDFf3IaMvPYN/Ehszfv7IxT3uo
         fLxw2/OsXeEtFlUHexOF295BcNek8HaMwSloJvIW6RrZFjd0Pw8kk277T726x2bXI12J
         B7/cd0mMQ3GYxPxChV8cn36NY4ZRM9CURaDBfXKnyd02pT84/sk4ghsQpyHB8TrQxzJg
         KPLR0Zhi/ITToUa/JdvwMvHYQe8Y14ZPAxh6/j2ft59mDPIASUO/+eJx6TrfnKQYImux
         mBgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o16si16909649wrj.30.2019.04.07.01.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 01:00:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id D0B1E68B02; Sun,  7 Apr 2019 10:00:20 +0200 (CEST)
Date: Sun, 7 Apr 2019 10:00:20 +0200
From: Christoph Hellwig <hch@lst.de>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@kernel.org>,
	linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
Message-ID: <20190407080020.GA9949@lst.de>
References: <20190319211108.15495-1-vbabka@suse.cz> <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com> <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz> <010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@email.amazonses.com> <4d2a55dc-b29f-1309-0a8e-83b057e186e6@suse.cz> <01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@email.amazonses.com> <2b129aec-f9a5-7ab8-ca4a-0a325621d111@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2b129aec-f9a5-7ab8-ca4a-0a325621d111@suse.cz>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 05, 2019 at 07:11:17PM +0200, Vlastimil Babka wrote:
> On 3/22/19 6:52 PM, Christopher Lameter wrote:
> > On Thu, 21 Mar 2019, Vlastimil Babka wrote:
> > 
> >> That however doesn't work well for the xfs/IO case where block sizes are
> >> not known in advance:
> >>
> >> https://lore.kernel.org/linux-fsdevel/20190225040904.5557-1-ming.lei@redhat.com/T/#ec3a292c358d05a6b29cc4a9ce3ae6b2faf31a23f
> > 
> > I thought we agreed to use custom slab caches for that?
> 
> Hm maybe I missed something but my impression was that xfs/IO folks would have
> to create lots of them for various sizes not known in advance, and that it
> wasn't practical and would welcome if kmalloc just guaranteed the alignment.
> But so far they haven't chimed in here in this thread, so I guess I'm wrong.

Yes, in XFS we might have quite a few.  Never mind all the other
block level consumers that might have similar reasonable expectations
but haven't triggered the problematic drivers yet.

