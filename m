Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C97DFC76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:13:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AD3721955
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:13:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AD3721955
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 250B68E0003; Mon, 22 Jul 2019 12:13:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 201E38E0001; Mon, 22 Jul 2019 12:13:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F23E8E0003; Mon, 22 Jul 2019 12:13:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E34F98E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:13:52 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k31so36084691qte.13
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 09:13:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=S2hK+h+EoI43cv30uqbj7+KxLPlCodqFcyazqEl7dso=;
        b=uBNHur0tXNkyv2/fppCu5IpalDW64CgLbXapq6YyII8H9N3tfWvd+bMYsbIE7ysvVs
         BZIxLG9OSn8OHZ+M8WSRyMSuTFFe+xB1OyGOKnJSFiQJFKAaBA6E84z4z7gCIZVK4uqB
         KuEiNem/luuAumCqABMfdqPcT9QMFtTNFKmx1I/XUbU9NAJ9GPb3zq/BiV+JL3r4+HM1
         nangba5IkyY6mjl0xU/rESuAKIOXeXxQv8gsZjUlYY3qeFcbEDVO+ToEcYAJMwqlUqf8
         AAFX9wemU3fQlm0lxz3zQA17MWUecXntNhhFr4g2MaOVEfyjhd5afzkxwQaWC/klveI7
         ATeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAViLqRAukzPYVIIbnF2moacLF9v4jji/ELp+MOrmQze59P72+ak
	eei9Z6r/6gi38gLh7Paeaikxz4XVKIN7TnLKfLuDDosD77OhPH6hrACNOc28LekTWx5P/59Lrhd
	dls4O0LKp0PUCUCJy+NID56+hU7TCM38geIhnkLc7TsXv5p7ECdKUarvMe5B6LgtYIA==
X-Received: by 2002:ac8:1848:: with SMTP id n8mr16146727qtk.147.1563812032628;
        Mon, 22 Jul 2019 09:13:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/TKw7vCf2LkpvROVKDFTDrvpAsdXP+mXA3wd209bYCy/1Dabk/yGZqfWXRh59Io+IaMbN
X-Received: by 2002:ac8:1848:: with SMTP id n8mr16146706qtk.147.1563812032066;
        Mon, 22 Jul 2019 09:13:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563812032; cv=none;
        d=google.com; s=arc-20160816;
        b=pvYsAQ2OQEgGvGRhslFVf88A9U3Imt1uuTP8fz9Kclk9VZrvfQz1erhLsJPsYSUqKI
         CWqO6ZJdm+Rw4ilWrk+oA0EnQthKZMFWczhmEAlCgoKQl2oBpJ81yZVdEaJe56AyrnXT
         dYBy+wkMAMfKFRBBhHFTT0fz/6KRmGGGmkMR5WXWexCe79gZ3tSbSXNPGGdP6633yhlJ
         ldeLilAY3enf06hoX8/5ER2FxqXy0qd9YBkRT3Sf9kyPqKacHuu1QZCK/ZzZKxO+ejIS
         89Or8Rwc8mavGusU73zHcgQsr8Qo1zNs8xFlbsm7b8fxk49RLlTALXeo30kjgICcPEED
         7O9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=S2hK+h+EoI43cv30uqbj7+KxLPlCodqFcyazqEl7dso=;
        b=0rmhxNV3bEZFsXkxCzpvspSfFRhcwrsfZB3peIzDMDC7lfJo0GBZf3aC6284K0uAM0
         ojlkn8JzewMlyYS637HAArff+dctoUzv9X1x20awhBmfj6WluByqGuPHdzROeW/tWBR0
         wm3PCuS1BmpVJlWLBFofjrqoDFSAD9LW1zvsO2tnaKkE07xBnJO1EPAUs4lcUJOxS0HL
         DSaawJl3Wq+IPtRV5BxNwKjVi33iKIXukE+G+guQ05uV8tOxGzvgLB6u45nSzIkc+GkG
         m80mcSjOQYQ69qJtm8EZcP06wcDof3LXElPAeajdOMtQ+Cou6C99ZD6CjCkiZPC95fB9
         rVjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f11si16710261vsm.81.2019.07.22.09.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 09:13:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BAFB030B8DE2;
	Mon, 22 Jul 2019 16:13:50 +0000 (UTC)
Received: from redhat.com (ovpn-124-54.rdu2.redhat.com [10.10.124.54])
	by smtp.corp.redhat.com (Postfix) with SMTP id AE2A260BEC;
	Mon, 22 Jul 2019 16:13:42 +0000 (UTC)
Date: Mon, 22 Jul 2019 12:13:40 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: Joel Fernandes <joel@joelfernandes.org>,
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
Message-ID: <20190722120011-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722151439.GA247639@google.com>
 <20190722114612-mutt-send-email-mst@kernel.org>
 <20190722155534.GG14271@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722155534.GG14271@linux.ibm.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 22 Jul 2019 16:13:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 08:55:34AM -0700, Paul E. McKenney wrote:
> On Mon, Jul 22, 2019 at 11:47:24AM -0400, Michael S. Tsirkin wrote:
> > On Mon, Jul 22, 2019 at 11:14:39AM -0400, Joel Fernandes wrote:
> > > [snip]
> > > > > Would it make sense to have call_rcu() check to see if there are many
> > > > > outstanding requests on this CPU and if so process them before returning?
> > > > > That would ensure that frequent callers usually ended up doing their
> > > > > own processing.
> > > 
> > > Other than what Paul already mentioned about deadlocks, I am not sure if this
> > > would even work for all cases since call_rcu() has to wait for a grace
> > > period.
> > > 
> > > So, if the number of outstanding requests are higher than a certain amount,
> > > then you *still* have to wait for some RCU configurations for the grace
> > > period duration and cannot just execute the callback in-line. Did I miss
> > > something?
> > > 
> > > Can waiting in-line for a grace period duration be tolerated in the vhost case?
> > > 
> > > thanks,
> > > 
> > >  - Joel
> > 
> > No, but it has many other ways to recover (try again later, drop a
> > packet, use a slower copy to/from user).
> 
> True enough!  And your idea of taking recovery action based on the number
> of callbacks seems like a good one while we are getting RCU's callback
> scheduling improved.
> 
> By the way, was this a real problem that you could make happen on real
> hardware?


>  If not, I would suggest just letting RCU get improved over
> the next couple of releases.


So basically use kfree_rcu but add a comment saying e.g. "WARNING:
in the future callers of kfree_rcu might need to check that
not too many callbacks get queued. In that case, we can
disable the optimization, or recover in some other way.
Watch this space."


> If it is something that you actually made happen, please let me know
> what (if anything) you need from me for your callback-counting EBUSY
> scheme.
> 
> 							Thanx, Paul

If you mean kfree_rcu causing OOM then no, it's all theoretical.
If you mean synchronize_rcu stalling to the point where guest will OOPs,
then yes, that's not too hard to trigger.

