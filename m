Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6858BC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21B6020693
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:44:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21B6020693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8232C6B0005; Thu, 18 Apr 2019 18:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A9B76B0006; Thu, 18 Apr 2019 18:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64AAD6B0007; Thu, 18 Apr 2019 18:44:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11FCA6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:44:30 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id k81so2983887wmf.1
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:44:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=zbj2V1kbui8OviJyTIP/gMUiZz5nKj8EIYrL3TtHiBE=;
        b=fJlpt/ExlVF3a2oAEZvPea1z1en2ET/4dPpxJG2zq+1goYqfKsNfKJtm/0mFa6OgW4
         /fjcnetQZiGHrshQY5eQHt7Oeii40KHE9w6DA33NXGY773jC6mXKToM7A51/7f+sbh9s
         mYueR/lwqMeokj5s+TlHzYE2KDB52u1w1c0ePnUTBZKGuHTPXxotJlCDY/J5gijPlkbz
         e44XTnuDVxK9d5CbLVLWOEdvH+4yh859Hnj0KP6ap/gNktWPJE+ZYrRdsf4PdZbwLAgT
         7qZERHSUK3ljf6vwJ5dG0G2SX00co62JaYqJMVUYIurX648aLC7riG/Vr60o7mTWDMrX
         4SXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWz0YoEeHgdKFEvY+reJEmfn/pXFfOVeaen8x/1L9qpkDH38c1c
	EvC5gWzivE3CvnJK5q/mKAm0i/O3Zao4QgRlTA621aoxX1qxhzEM6qVayh3V/0sPOPjbRfw9qHq
	//RiwcwZkvEJSbg7WC6CiRQc27C+nO3R1sULE075ni/Sp++wzcpy5yaN2o5kMBdriMg==
X-Received: by 2002:adf:c788:: with SMTP id l8mr395803wrg.143.1555627469577;
        Thu, 18 Apr 2019 15:44:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLrbbbNlhyR36WmjQErkf7FZwomMTjls65/Y7yeteUv4Q020zqLvwTF54CEcj73afkCYAB
X-Received: by 2002:adf:c788:: with SMTP id l8mr395763wrg.143.1555627468577;
        Thu, 18 Apr 2019 15:44:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555627468; cv=none;
        d=google.com; s=arc-20160816;
        b=zuDKmdq88fsMi3aalb/FRrKBenQhMyCbcmoR1ceD5NluOwtdGQCvXvTyyiyEhQF3ul
         9/TbE7zfYkPhCV8NQFc7y1wsRsO+ZA5dCH3K794BCjToZKqKP6nggR22UdtCqCj0y8PM
         ryC/Wx+gOOjTxEz/PWSM9TzGvjqOPbGKeZYPYdw27AHc92xvuTQGQmt1/kLafTp/KvVM
         VQWzCkyGS/eMK+HSqoUh5F9BxDPBBk+m9UXGbYWC2VGtdsjed9AFoh1ijaanztIBCcHh
         kYeDlvgQ4ahmOFV23rLbbyiAWLbcexpAd42vkx2ekC57fX+lDY2sfW6Q9r0mhdE5BPxa
         VV0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=zbj2V1kbui8OviJyTIP/gMUiZz5nKj8EIYrL3TtHiBE=;
        b=t14daAcbXf7D99J2VJ4DKwsB8+qe6wD53OcYdTDVCfjZq0fD9ixw474ilRmzlRQe/0
         7n62vu0jdj3UtI0ZIAcFSzfz8XHZxTrE7uCmxMJm/WOQjVkz2h7Z9ZAGOZvutZ94qCqR
         XCdMOZ2MqaUoCoP/jnZEPVGnz7qlFOI0qfdfC9dYmXVz9V0ZFXnoXutG4pQUrPDSIhJi
         e8Mb7xmauWy64lDxeyyzPf75mESdcbFA+IpYU0rL1IyFe/4QfGk6jNiiA+M9S2AR/mQ1
         TBcROXce2C92oooT1CCD7b2bnQdwcZHG4LtOqRGTO0iiwTAQ0YtOPZzSZgtCaKxD0e8K
         /WxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l7si2431504wmi.168.2019.04.18.15.44.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 15:44:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hHFlT-0000Hv-O2; Fri, 19 Apr 2019 00:44:19 +0200
Date: Fri, 19 Apr 2019 00:44:17 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Steven Rostedt <rostedt@goodmis.org>
cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
    x86@kernel.org, Andy Lutomirski <luto@kernel.org>, 
    Alexander Potapenko <glider@google.com>, 
    Alexey Dobriyan <adobriyan@gmail.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, 
    David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Dmitry Vyukov <dvyukov@google.com>, 
    Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, 
    Mike Rapoport <rppt@linux.vnet.ibm.com>, 
    Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org, 
    Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, 
    Marek Szyprowski <m.szyprowski@samsung.com>, 
    Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>, 
    Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, 
    linux-btrfs@vger.kernel.org, dm-devel@redhat.com, 
    Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, 
    intel-gfx@lists.freedesktop.org, 
    Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, 
    Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, 
    dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, 
    Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>, 
    Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 01/29] tracing: Cleanup stack trace code
In-Reply-To: <20190418181938.2e2a9a04@gandalf.local.home>
Message-ID: <alpine.DEB.2.21.1904190040510.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de>        <20190418084253.142712304@linutronix.de> <20190418181938.2e2a9a04@gandalf.local.home>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019, Steven Rostedt wrote:
> On Thu, 18 Apr 2019 10:41:20 +0200
> Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > @@ -412,23 +404,20 @@ stack_trace_sysctl(struct ctl_table *tab
> >  		   void __user *buffer, size_t *lenp,
> >  		   loff_t *ppos)
> >  {
> > -	int ret;
> > +	int ret, was_enabled;
> 
> One small nit. Could this be:
> 
> 	int was_enabled;
> 	int ret;
> 
> I prefer only joining variables that are related on the same line.
> Makes it look cleaner IMO.

If you wish so. To me it's waste of screen space :)

> >  
> >  	mutex_lock(&stack_sysctl_mutex);
> > +	was_enabled = !!stack_tracer_enabled;
> >  
> 
> Bah, not sure why I didn't do it this way to begin with. I think I
> copied something else that couldn't do it this way for some reason and
> didn't put any brain power behind the copy. :-/ But that was back in
> 2008 so I blame it on being "young and stupid" ;-)

The young part is gone for sure :)

> Other then the above nit and removing the unneeded +1 in max_entries:

s/+1/-1/

Thanks,

	tglx

