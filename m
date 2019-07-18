Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FFD8C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:05:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 009E22173E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:05:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 009E22173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E9418E0001; Thu, 18 Jul 2019 05:05:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99A186B0010; Thu, 18 Jul 2019 05:05:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 860BB8E0001; Thu, 18 Jul 2019 05:05:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35C1D6B000E
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:05:12 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s18so13351127wru.16
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:05:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=k+iuQXTM3Ms9dMehSKPgpVcBJ9cVSbI1kChrt30Wg10=;
        b=txPAdhKslQ3fm/N6fvLIx5p9UQ1k1m5i2CEzmziN6UZOc1ey1YntPVGlTp8Gnfrrzi
         5//9ZXSL0zbmTS368BcAJpaT3NI9VVyXO8PGyZeHgm38NAFpiRNCadJsgMibGaVt7RII
         ahb1Ap1YJEtG/uzs1PxKEzAmDLgobjmNhvvUO7I2+oXYdN4dEWvu46XTjVdhNrxi4NwO
         gbXOF8pyUGh+MOVYMkdtlod6QIErO51sUv+IK/pfcXv/pqiBbjFg8FzU2ALriTx6mGjP
         PLCXgE3IsPO1sqOV3pxP6G1m+37CZXh58kEqUx5Tk7/Wa3YWwOeox4QKwnDD4cuQzcla
         nUjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVNJ5bvdCY9nD3GC19C/FPQG1sTPtKIB2wDIt7T6HyCY8/aTCk0
	GFv7Wjzx+bggtjt0qu+Aitz/M4kcUJwf79mQspfBUK77CVSZjDzjtrj1RrNUJOzT+zWwsIQVVvT
	Ff9NoU5Twn1w59wJ8aVc7o/5VjVmS3YmkHR8rcKgyZENNcA82dPQnKb/SLT/jaDpFgA==
X-Received: by 2002:a1c:6454:: with SMTP id y81mr16181571wmb.105.1563440711799;
        Thu, 18 Jul 2019 02:05:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxV3T3VN7rTvjCvsxJp5el6A+9D2NYA05b4fwYxqrRzxGvJA55cJkGBiOeATpIk67MaVsao
X-Received: by 2002:a1c:6454:: with SMTP id y81mr16181408wmb.105.1563440710089;
        Thu, 18 Jul 2019 02:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563440710; cv=none;
        d=google.com; s=arc-20160816;
        b=it6QDH2tVY0Ox0YTl6f1JNsAuCc0reRl1SpILfgtmpYtNbRLg1RXV93IH9vXszPfqE
         L6W0uiEVx01ZlKSzQILRDUxDiAFP/BDJE8emoCghmxBLF8f+Y6OrSFJkjZ5xhP5dlEov
         7l9k1HGBqNp1R1JIPrk55Kmw9Ks/9pBh7BE3PzogTZe/Nw+2M3ryweNVT8XWBAVD/cdb
         l5yyy1EMnxhWdMIruBe26xi+TSyEoechz3V5qZ1Z+4JAKaA7f1O1fqkY36bCSsuaeMGF
         vEgTCiQwV6ux9yqUkuFUARz1JYocZSpwSj/Bq7HtxFCLb38Sz+B7EM/3DQ3Xmj3YiK1i
         ECAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=k+iuQXTM3Ms9dMehSKPgpVcBJ9cVSbI1kChrt30Wg10=;
        b=TQ6OeaepJ5vUeIi1dh0wEyFYcWjNsafco1UodqOsPZBgbnikRBKvN3vgy4b/3pXuYN
         HChYLry3a2YT38ioWFad2hRor09T0yp17RWm8SZmgw9VMYuybp22TmVEDH0MElzTXlrF
         Ec8ZZzQynf5U6X6nVssr45MCEz108N3SsRO1JFWFAaXMh9hBx3HVUcHKaI0yFvwzkFE2
         X+MJb/yovBo+ZWpEl4AKWC/hiyDu4XjR4oMlx5fD297sv/cOyc3SqlIdZSsEtEPAX1K1
         9LMO69EOa/F+OeFuNcaO3gkeDwUwkMHdpQYnUWBe8lj8TV9vZ56Vi/iyBZMAjtBQkbyq
         bwIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id d16si27746081wrj.387.2019.07.18.02.05.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Jul 2019 02:05:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1ho2LR-00058c-Iy; Thu, 18 Jul 2019 11:04:57 +0200
Date: Thu, 18 Jul 2019 11:04:57 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Joerg Roedel <jroedel@suse.de>
cc: Joerg Roedel <joro@8bytes.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
In-Reply-To: <20190718084654.GF13091@suse.de>
Message-ID: <alpine.DEB.2.21.1907181103120.1984@nanos.tec.linutronix.de>
References: <20190717071439.14261-1-joro@8bytes.org> <20190717071439.14261-3-joro@8bytes.org> <alpine.DEB.2.21.1907172337590.1778@nanos.tec.linutronix.de> <20190718084654.GF13091@suse.de>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Joerg,

On Thu, 18 Jul 2019, Joerg Roedel wrote:
> On Wed, Jul 17, 2019 at 11:43:43PM +0200, Thomas Gleixner wrote:
> > On Wed, 17 Jul 2019, Joerg Roedel wrote:
> > > +
> > > +	if (!pmd_present(*pmd_k))
> > > +		return NULL;
> > >  	else
> > >  		BUG_ON(pmd_pfn(*pmd) != pmd_pfn(*pmd_k));
> > 
> > So in case of unmap, this updates only the first entry in the pgd_list
> > because vmalloc_sync_all() will break out of the iteration over pgd_list
> > when NULL is returned from vmalloc_sync_one().
> > 
> > I'm surely missing something, but how is that supposed to sync _all_ page
> > tables on unmap as the changelog claims?
> 
> No, you are right, I missed that. It is a bug in this patch, the code
> that breaks out of the loop in vmalloc_sync_all() needs to be removed as
> well. Will do that in the next version.

I assume that p4d/pud do not need the pmd treatment, but a comment
explaining why would be appreciated.

Thanks,

	tglx

