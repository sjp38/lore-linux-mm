Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82CDAC282DF
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 00:40:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35D4821855
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 00:40:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35D4821855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFF5D6B0003; Thu, 18 Apr 2019 20:40:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAF7D6B0006; Thu, 18 Apr 2019 20:40:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99CFC6B0007; Thu, 18 Apr 2019 20:40:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 602016B0003
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 20:40:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e19so2405002pfd.19
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:40:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sTduqJ9jbkKiOdi8tB4/SeCHJZy6nRTfZyyPgVBiqkU=;
        b=k588TkGPeZ1w2pNEFwJ/iVuxdjSksaxx8rXra23827f9nHoMt+zEPXyZzFhvTOWq39
         KVDZFxAh0dbcOdjdjpUfS3xM6ZTxuF+6CazyKTjk5k6frwXLb8sqM0XgKBz+J9P+q7Dp
         yF35qSazheoNI6RpD5/M/vJAT7g95LoSM/jb2IaGDSw91NAoXdYxmdriP6GXl++Set9T
         6v51qkB8ntt+bhuJBRSsf8SChWp1BWS2RYcGKI2JalPXEfkFaL5QZmQhjwaxMiVcklfB
         SNC3kOM2qGYL3jXzAM+XijuWtCXMPCpzt8EV17TmJFRK/W3R/+0qtDGkKKaY97ulkGei
         +cMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAXlEZlb9BOqSkgIqLqFmbFMxP74EFv2tWpTY+M1VxgiKHWI/a32
	uDNdf+gVbV4Dphx55KxeEnbKruzLHmc10FviRiJ6CG5wiLK79Hm9fsvMD6kXpx9qWyA6cHcvDS/
	IZd/NjchDYP70EBJJ2wFBKvQkHyqB0hHSXIl46mt31KMyppDnD2qmvQ397D2tRyM=
X-Received: by 2002:aa7:86ce:: with SMTP id h14mr753064pfo.84.1555634401001;
        Thu, 18 Apr 2019 17:40:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyP8nuUDdjJgUP4Da/TgSh7Vc+AySxjndeDPYsTaNA5pCsiLBP2EPse7hrby4lUvcOSVx9J
X-Received: by 2002:aa7:86ce:: with SMTP id h14mr752997pfo.84.1555634400068;
        Thu, 18 Apr 2019 17:40:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555634400; cv=none;
        d=google.com; s=arc-20160816;
        b=rArVQKvgB3ZtVoSccm8Lmzi3ZYY60KE40HRgA0kGSp4714MYJV5Gfe/G6OMf4bWR5i
         9klefUbaYbk9t22d13U8vtJw3VmJ7Iszae4GZ38a7FE3jX+9OEavaDIj+vrgNQQ/Tap7
         48jrUtPg04HqUMmrn8e+OQ0AtV+KdKGuMI7QhS7SXuB+mSNpbervP5i90BNkq65trBBr
         QZ+Acvn3LTjGjCW/t/A9M418SqN3YhfxU0QmpU/c1omLqHfINIhopUH4R44KCP/SaGbZ
         9JhsygJMAMp6t4dT2HBpj7jUHKHhvfCtwA7EUzzMxNfv7hsJoR+S+6/KSgZNMfMeFyql
         eKDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=sTduqJ9jbkKiOdi8tB4/SeCHJZy6nRTfZyyPgVBiqkU=;
        b=r2oaKPFxpTmk2V0NRRL0JkzbASYYjmAcTsy520ozM4MMlV0Y0dDKFt5SmzvrGbansT
         oiXqT7WWjXYodQPvt5979vXGohQpzJNaz3N1pr0jZvOYuo9iF9VMd0CbLsSE4uBSPvlN
         hSRi3FGVtUUvpqFVVbx7PKXgBwaXEF4II9J0L3rxzQZbf7KcLGVVvA1VqdQGgUbjH3SH
         +G0WkEDGTs6tc/+o3KPPzhQmeeOIMZTuGJ90hBFKvCXgfBlz+jEFSZOVJveEb7VN57QJ
         fMHUGcvYlB9Na1tifzb4+2ee9ZI5ZjIXL1iyDH6JQN3VdUtpoGFI4zbySmAyPg7ZsSb5
         HUXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x14si3540713pgg.16.2019.04.18.17.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 17:40:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
Received: from oasis.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 51E6C2171F;
	Fri, 19 Apr 2019 00:39:56 +0000 (UTC)
Date: Thu, 18 Apr 2019 20:39:54 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf
 <jpoimboe@redhat.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>,
 Alexander Potapenko <glider@google.com>, Alexey Dobriyan
 <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka
 Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes
 <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Johannes Thumshirn <jthumshirn@suse.de>, David
 Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, Josef Bacik
 <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 linux-arch@vger.kernel.org
Subject: Re: [patch V2 01/29] tracing: Cleanup stack trace code
Message-ID: <20190418203954.631914cb@oasis.local.home>
In-Reply-To: <alpine.DEB.2.21.1904190040510.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de>
	<20190418084253.142712304@linutronix.de>
	<20190418181938.2e2a9a04@gandalf.local.home>
	<alpine.DEB.2.21.1904190040510.3174@nanos.tec.linutronix.de>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Apr 2019 00:44:17 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> On Thu, 18 Apr 2019, Steven Rostedt wrote:
> > On Thu, 18 Apr 2019 10:41:20 +0200
> > Thomas Gleixner <tglx@linutronix.de> wrote:
> >   
> > > @@ -412,23 +404,20 @@ stack_trace_sysctl(struct ctl_table *tab
> > >  		   void __user *buffer, size_t *lenp,
> > >  		   loff_t *ppos)
> > >  {
> > > -	int ret;
> > > +	int ret, was_enabled;  
> > 
> > One small nit. Could this be:
> > 
> > 	int was_enabled;
> > 	int ret;
> > 
> > I prefer only joining variables that are related on the same line.
> > Makes it look cleaner IMO.  
> 
> If you wish so. To me it's waste of screen space :)

At least you didn't say it helps the compiler ;-)

> 
> > >  
> > >  	mutex_lock(&stack_sysctl_mutex);
> > > +	was_enabled = !!stack_tracer_enabled;
> > >    
> > 
> > Bah, not sure why I didn't do it this way to begin with. I think I
> > copied something else that couldn't do it this way for some reason and
> > didn't put any brain power behind the copy. :-/ But that was back in
> > 2008 so I blame it on being "young and stupid" ;-)  
> 
> The young part is gone for sure :)

I purposely set you up for that response.

> 
> > Other then the above nit and removing the unneeded +1 in max_entries:  
> 
> s/+1/-1/

That was an ode to G+

-- Steve

