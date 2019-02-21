Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EC82C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:16:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC8C12089F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:16:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC8C12089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EB728E004C; Wed, 20 Feb 2019 19:16:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19A338E0002; Wed, 20 Feb 2019 19:16:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08AD18E004C; Wed, 20 Feb 2019 19:16:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D228B8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 19:16:02 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id r24so25001439qtj.13
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 16:16:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ZLL1n403Rasb5zF0daZZEyDJvNxP46Um6LbxkczYVNU=;
        b=Eer4XFFtfvVnMSkD67+uWg1Bndcb867dltFztG69YU5lSFXwO7OK3A9Pv7oADjqIi8
         bGsiQx885g188q1EsMYd5YeaOxX5yoaioQDc785UhmAcPr340XMWtSsGAAtMS1Dzl5vQ
         Wei9lqxNc0m91pZwHSxywgmLJK1vAjAyLJlYy3k0WyRLaxfBo5CHazbEQAi0LrP5WPpk
         hlgNrKqFHvs6uYdn6ezJDe4qv9osTWgpQnF5Ahce8j5OYY6T30laPB39DstnJ6uyM00Y
         UpPD9t7rz6z5l7SzPO4rPajQgGn3+dGhM08uX1E6mVi4uS8VxR2U1OLhEKSxEFUPmYgF
         pzSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZ/wVWoPpjIPz7dBlGYkTKryWP5+Bs1hu5EuS6jlHL/gL3yTfHX
	VMhF6rtBR7iorQ92SWjxDCZhTeHC5znFt5n3gNIwvQlAdFU1uHCc/sgmGeFlWMmCibDeutsfl/b
	/tcE04uxuPAZczy8VYcRKaLYHG40tjjTRWoHEpcV3hwh31dUS001AXo6+ixqhIZqIOg==
X-Received: by 2002:a0c:e74c:: with SMTP id g12mr27733956qvn.10.1550708162542;
        Wed, 20 Feb 2019 16:16:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibbsm/3DMcRAIWbLZm0D7r49DIbl82OiQa2qm6Q69Ry0F4qYycTSpWBFkyn/7YuqAFp4eCo
X-Received: by 2002:a0c:e74c:: with SMTP id g12mr27733937qvn.10.1550708161995;
        Wed, 20 Feb 2019 16:16:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550708161; cv=none;
        d=google.com; s=arc-20160816;
        b=PPEk1+VPUmGl1cn1jFRemgdQmzzFd1oiAAoNGo/PFqwLnTZ3+UjxxNr60auwUYBMVe
         ZsJTFzEMME9k1ELnx4uN1VgbNDeliTc2iTaqOe6S4E/m4GI1+p/CiA9Up36ZvHQ7DhHf
         dd/bzhCke5w1Ku43EN4NlFMOe2cgJop6K8sEdENcDLWBpalKewAwQGnfsCL3xFO2HrCP
         nt5fQGIkHENHXpyBbdTmlIqiPy5HiCG2WCIhNGzZGW3Ory1xpuCgorAVPuSDqKp9vVYC
         N1f6PjSObryMbV0kpdpty+1SfDsGmWyFhNw6k9kSDD6cj5vl8qmyc4ZSnhL47Ed3Eg11
         7YKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ZLL1n403Rasb5zF0daZZEyDJvNxP46Um6LbxkczYVNU=;
        b=KfOr/lMC9PmBaw3HgoV+0LX3hahICPbVVo8hOhGVC8i7pi1AFoHw/ZT44tmR4pMFKk
         2pAdWCROAS8UAQoSTWkt50psF5ky3a+BznDNDqPDXTP6sBsVhEabqZCYZdICmRwIxJrL
         6B0Pd2QXRAutVWAh09wMZ3BgtWwxYNl7RtLyGzaQxwdpml0TIAbNiak38Ze2vDw0Aazt
         Iw7K2gh8rR+Ue6DeunKfU3ylT/LIeiqfzxX8VvacZPipiAtbBY2NtIGkfvyodIG0C0X+
         hBOZXF8kk8otxjL+BOo5cdan6Of6Su1NZ3VWJF72B0Nevf5WgDkpdEFGJgN4bwqXLc4p
         1YWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r4si2628995qtp.159.2019.02.20.16.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 16:16:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 066AAC03BD4B;
	Thu, 21 Feb 2019 00:16:01 +0000 (UTC)
Received: from redhat.com (ovpn-120-249.rdu2.redhat.com [10.10.120.249])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E41B65D9D4;
	Thu, 21 Feb 2019 00:15:59 +0000 (UTC)
Date: Wed, 20 Feb 2019 19:15:57 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/10] mm/hmm: use reference counting for HMM struct
Message-ID: <20190221001557.GA24489@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-2-jglisse@redhat.com>
 <1373673d-721e-a7a2-166f-244c16f236a3@nvidia.com>
 <20190220235933.GD11325@redhat.com>
 <dd448c6f-5ed7-ceb4-ca5e-c7650473a47c@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <dd448c6f-5ed7-ceb4-ca5e-c7650473a47c@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 21 Feb 2019 00:16:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 04:06:50PM -0800, John Hubbard wrote:
> On 2/20/19 3:59 PM, Jerome Glisse wrote:
> > On Wed, Feb 20, 2019 at 03:47:50PM -0800, John Hubbard wrote:
> > > On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > 
> > > > Every time i read the code to check that the HMM structure does not
> > > > vanish before it should thanks to the many lock protecting its removal
> > > > i get a headache. Switch to reference counting instead it is much
> > > > easier to follow and harder to break. This also remove some code that
> > > > is no longer needed with refcounting.
> > > 
> > > Hi Jerome,
> > > 
> > > That is an excellent idea. Some review comments below:
> > > 
> > > [snip]
> > > 
> > > >    static int hmm_invalidate_range_start(struct mmu_notifier *mn,
> > > >    			const struct mmu_notifier_range *range)
> > > >    {
> > > >    	struct hmm_update update;
> > > > -	struct hmm *hmm = range->mm->hmm;
> > > > +	struct hmm *hmm = hmm_get(range->mm);
> > > > +	int ret;
> > > >    	VM_BUG_ON(!hmm);
> > > > +	/* Check if hmm_mm_destroy() was call. */
> > > > +	if (hmm->mm == NULL)
> > > > +		return 0;
> > > 
> > > Let's delete that NULL check. It can't provide true protection. If there
> > > is a way for that to race, we need to take another look at refcounting.
> > 
> > I will do a patch to delete the NULL check so that it is easier for
> > Andrew. No need to respin.
> 
> (Did you miss my request to make hmm_get/hmm_put symmetric, though?)

Went over my mail i do not see anything about symmetric, what do you
mean ?

Cheers,
Jérôme

