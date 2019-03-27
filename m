Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90021C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:53:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48E9B206C0
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:53:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eLOoBW5U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48E9B206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC8BC6B0005; Wed, 27 Mar 2019 13:53:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4D976B0006; Wed, 27 Mar 2019 13:53:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF1926B0007; Wed, 27 Mar 2019 13:53:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D68E6B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:53:06 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id t17so5073533ljt.21
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:53:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ks3fxtSZlKQBgoNpjVRc6wQA+v4+teq/lZyU60c9fgs=;
        b=knH+8oU7H3cCXGl+SCK+NZr45K/xk/ZI62JiirIaL40d7tgqkZDqMPosQPH1R/EnnK
         dwSEh7QfiaOp8WpENPe0c7L/k3TmLcjbx4zn8jKxXtG/nkgOdKc07KWARg6D6zCKs2Oh
         3GA/o5Z7ynOJk27tWnesYVsWt5w28RwJXA6CT13iH9DuKjmFAid4j70JCpnSwm7ceH3m
         Rpw5ggIIz30RigG2G58y50Ib7akkGsD1cqG1wB4Nn1jZai7lCcHbGkFPVS1hEewwLB7Q
         YgdROreUH0lLKuEJv/Qh4l/XGnOEp0Getg6Hymmzumkmr4oDaK+MtgRrDPfR5xR6H5Pp
         rSYQ==
X-Gm-Message-State: APjAAAWrvGvOdOIUgyeY7z6T7Y3j/zQbeCI0cROF/TcN2xOcDWHvT+Ze
	UTLdoMnj0keYdRfH9qlesRuBc2wARVZRw9nMkiqj2CjWRiBCjV1WKC/eNXsTibi6F1Bcn6ybkLO
	pGK4XlDAdm95OhFhzWesiie2ihwD0c2Dz313CWFUM+CzJOTGF4AZy51c3lkNOEcIZZw==
X-Received: by 2002:a2e:9655:: with SMTP id z21mr3523535ljh.60.1553709185529;
        Wed, 27 Mar 2019 10:53:05 -0700 (PDT)
X-Received: by 2002:a2e:9655:: with SMTP id z21mr3523502ljh.60.1553709184655;
        Wed, 27 Mar 2019 10:53:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709184; cv=none;
        d=google.com; s=arc-20160816;
        b=HUq6IALfhPqbnXysWhUusMISaiJ3PPAS65qShiwsEgKrhllBxNikbdjCxZJ/6IO8h2
         reXo5/L9PqK/ABwtr+k/B42gMMBhVmoBV3zIoIkQ243BvpU9vtP2V+1SOPOxw0DKKuMX
         tV3rUfutLftCSUgUpt99Afra5VlrTQ3v4b7eSsNstBauBC+AQKGkNRAnEuRWX/NKHuUR
         go07kFliFKFHDDdvS2JlMRsUxdwOqIavZ55dg0/RzsZYMCdy6J50rFUVyqgyPT8F6C/5
         bZK2v2IFqhxQDbW6nC3E/3Pvb8ED+bGjyXcQmlWRxNfAA6gbpKIELXepFXldmMhhilPr
         6BGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=Ks3fxtSZlKQBgoNpjVRc6wQA+v4+teq/lZyU60c9fgs=;
        b=g8ghdabbkl/6Ykg8wm0bLCqddjZVfkf6AsVeu87y56aRbKQJrG/6yV1vAwbmV2kkYq
         3lNABjomJ0Lbp38mhGI/y6GXJw6TK6VoibIfKKvAVl6wYwCKyXDuf5s8P4AG+bZumCyU
         ZmUMa9F6aphpyJgZJKqahbfhDADref35/UlCzgKd6wIGPlsqE+dBn0oUWUzymBwOGa+Y
         Eyj4RtM/bTViEzCmmw14GDeErbbeKQpQq06rdJy02xNo8bpl7S33GHKH3/0E958ybnvL
         o4TwgxxGv8EjleObwFGog6gBf4dXGaG/lU+9Qfce63hls9oaiJqygx3aCA7EKE/qIvvP
         1rbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eLOoBW5U;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y8sor8755150lji.33.2019.03.27.10.53.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 10:53:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eLOoBW5U;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Ks3fxtSZlKQBgoNpjVRc6wQA+v4+teq/lZyU60c9fgs=;
        b=eLOoBW5UMJhFDLnE2Ewwwpd7w0Rtp0wnCJjFCKo+vUMzMMSKHxY4cvi5p6d56CRiGa
         XKrPjhwovTqyEFre4dQKU5SU0lwypKMRKbjASXQPnyTFUB0yVPurpXPXVendAztwqYbV
         jzP1iM0kFugJB4/VILYoD40P3R7Kfmv4lN1twMnwqO0OGt7JG3mmujOW+vQy93iDTqZM
         BlZvAaWZqBlPoia8jtd8rkCxjC2aOemSuNAzByuXZ8kowtfsM3hol+p8nkoEtjanwSTf
         uCnm5FdfT6j/ZxeOZ/LPHbjaklYCQ0X/7+VNJK/r1l3OD+BHio+qyhk6uh3IEtaVU1za
         RRZQ==
X-Google-Smtp-Source: APXvYqy4ZHvhmz7Fjg7AKYQv+qcVHXUb1EiQdhUrRCZ1a8JBPr2TYyQmUddYr3/ObIP+g6KX3QxbQg==
X-Received: by 2002:a2e:810d:: with SMTP id d13mr11239277ljg.93.1553709184278;
        Wed, 27 Mar 2019 10:53:04 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id q2sm4627322lfj.58.2019.03.27.10.53.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 10:53:03 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Wed, 27 Mar 2019 18:52:56 +0100
To: Roman Gushchin <guro@fb.com>
Cc: Uladzislau Rezki <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 1/1] mm/vmap: keep track of free blocks for vmap
 allocation
Message-ID: <20190327175256.stktpllvub7s6lwx@pc636>
References: <20190321190327.11813-1-urezki@gmail.com>
 <20190321190327.11813-2-urezki@gmail.com>
 <20190322215413.GA15943@tower.DHCP.thefacebook.com>
 <20190325172010.q343626klaozjtg4@pc636>
 <20190326145153.r7y3llwtvqsg4r2s@pc636>
 <20190327004130.GA31035@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190327004130.GA31035@tower.DHCP.thefacebook.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Roman.

> 
> Hello, Uladzislau!
> 
> Yeah, the version above looks much simpler!
> Looking forward for the next version of the patchset.
> 
> Thanks!
Will upload it soon.

Thanks!

--
Vlad Rezki

