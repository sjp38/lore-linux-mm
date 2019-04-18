Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C18BC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 19:59:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDB0421855
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 19:59:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDB0421855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D9D16B0005; Thu, 18 Apr 2019 15:59:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 789086B0006; Thu, 18 Apr 2019 15:59:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 650D76B0007; Thu, 18 Apr 2019 15:59:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29BE26B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:59:03 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 3so2060026ple.19
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:59:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PaTEdHmSKgEr8cPfL8EUF9+pcJ0cGJs8I+CD02WscDI=;
        b=SJRnkQ3kpClkbS3V35c81oEYViRUp7FfcLuwP/do+V3gWJJWhAJS2O/yA9tYaTnwVe
         UyrI/fh9uBDQun0nk6s4xyw3qn2F1iF6LINaZ2HsIeHpkArVufMdykj9AqF7qjBLxV8I
         mr/n4HpzNzpEjZu3wRvzsAZDDvRsvpZ7+Cv97J6Xy28MJA8RZAE4uDqManFoGuLpAFOp
         ooP4BhrwAf68fGKu2ooUYrahw/nWKBV61kMxwvyWmwJR2dI4F40nSiDD8gK3b9pY5yiA
         k85ubvupb+c5nb94afGbuaJ0txs4UQaygewSWWkmS4+4vj/6Ig4ZlQqwpPwfBGQ9bVBk
         sxDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tom.zanussi@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=tom.zanussi@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWimN3Av5f2O2PPhXoMcr7uiXLtJF6SFETuFHogYubVUf7ys4L6
	8VcUiwGppRD3llXm48KNNYw3p8at7a6o6s9x6fbyOb3sziT0h9rgWo36MHN+yW/gBnQlBw6bdaX
	LanuEHhu7d7SgVDXvYROBa5WBFMJorESanVbbTg6ytkBHaAgX6cAfusNX4sph15z+wg==
X-Received: by 2002:a62:8381:: with SMTP id h123mr98682360pfe.226.1555617542728;
        Thu, 18 Apr 2019 12:59:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4Sh3yNDMEMW1MKj0NgGBZWUprfL1c/kvmw7Q6RmTaF42kAUGUBuOpbrXR31TRdlM/Mn4F
X-Received: by 2002:a62:8381:: with SMTP id h123mr98682299pfe.226.1555617541832;
        Thu, 18 Apr 2019 12:59:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555617541; cv=none;
        d=google.com; s=arc-20160816;
        b=C0s5qB2r2jAaUJZ/6H7d8OfqGAWr70IbMUbl3XSFsAuH0tH+xAwfpAEkqaXUXPnsiS
         J3emVO8yWpaPfpj4uoDfSx63/FYR2dJT/Fq1pCHK8Juk5zDNOYHM10WaSxQlX8gH8hNM
         h/w+LwEDTuRUsk19srQmTBDWNaWjoZOZzhnXEihBT0fKhrA5M/XsT5loKJGnYljCRymk
         BfgCXZLQ3Qcc1+isy9gl+ilGkoGCPkLia7IGmrfk6+vSZ4XEZ2MoGcpIIKYMSazLLrEF
         EZ/ChrJFNXinI8OES81uvUQcS7zTeOzN3sRp06vdncLE2Fp1AOgd7btmTlF9/cGFiF0M
         6rMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=PaTEdHmSKgEr8cPfL8EUF9+pcJ0cGJs8I+CD02WscDI=;
        b=f61qqMC9KCErQ4gSB36Z1+c710TeyqUOpwFlzMEnQJraLDTuEzgIkPofEposFxhT1o
         CWTIaMdZvlHWgV1SOeSk5q0ZulStVXNwVHpyYa4HrUvZ3vQFWenCX6H6FX1+b84hFsi8
         yw8D4KAxW9h2UIkqP+O+8opoDqoS+Puxi8Xfe3Tg+A7eKOoUV+c1I6G/8uRwWFL603CE
         0fEjSO07AuwSor4+PIXEWCETOUxiP7N1YYaIU1EkfcVubrUMG6h0F9BWbNOW//xNKt9G
         hiDGLoF7iB67Ne8vpZynZFUHUV75ljBUlGtRPi6wCgUYUXhE2r6fE26ScnaJkM4Yf1DI
         UDAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tom.zanussi@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=tom.zanussi@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id o185si2717282pga.164.2019.04.18.12.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 12:59:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tom.zanussi@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tom.zanussi@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=tom.zanussi@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Apr 2019 12:59:01 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,367,1549958400"; 
   d="scan'208";a="224723852"
Received: from dytagah-mobl.amr.corp.intel.com ([10.254.15.29])
  by orsmga001.jf.intel.com with ESMTP; 18 Apr 2019 12:58:56 -0700
Message-ID: <014a7564d606b249a5e50bef0fedf266977a935b.camel@linux.intel.com>
Subject: Re: [patch V2 20/29] tracing: Simplify stacktrace retrieval in
 histograms
From: Tom Zanussi <tom.zanussi@linux.intel.com>
To: Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner
 <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf
 <jpoimboe@redhat.com>,  x86@kernel.org, Andy Lutomirski <luto@kernel.org>,
 Alexander Potapenko <glider@google.com>, Alexey Dobriyan
 <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka
 Enberg <penberg@kernel.org>,  linux-mm@kvack.org, David Rientjes
 <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>,  kasan-dev@googlegroups.com, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Johannes Thumshirn <jthumshirn@suse.de>, David
 Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, Josef Bacik
 <josef@toxicpanda.com>,  linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>,  Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>, 
 linux-arch@vger.kernel.org
Date: Thu, 18 Apr 2019 14:58:55 -0500
In-Reply-To: <20190418094014.7d457f29@gandalf.local.home>
References: <20190418084119.056416939@linutronix.de>
	 <20190418084254.910579307@linutronix.de>
	 <20190418094014.7d457f29@gandalf.local.home>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-04-18 at 09:40 -0400, Steven Rostedt wrote:
> [ Added Tom Zanussi ]
> 
> On Thu, 18 Apr 2019 10:41:39 +0200
> Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > The indirection through struct stack_trace is not necessary at all.
> > Use the
> > storage array based interface.
> > 
> > Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Steven Rostedt <rostedt@goodmis.org>
> 
> Looks fine to me
> 
> Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
> 
>  But...
> 
> Tom,
> 
> Can you review this too?

Looks good to me too!

Acked-by: Tom Zanussi <tom.zanussi@linux.intel.com>


> 
> Patch series starts here:
> 
>   http://lkml.kernel.org/r/20190418084119.056416939@linutronix.de
> 
> Thanks,
> 
> -- Steve
> 
> > ---
> >  kernel/trace/trace_events_hist.c |   12 +++---------
> >  1 file changed, 3 insertions(+), 9 deletions(-)
> > 
> > --- a/kernel/trace/trace_events_hist.c
> > +++ b/kernel/trace/trace_events_hist.c
> > @@ -5186,7 +5186,6 @@ static void event_hist_trigger(struct ev
> >  	u64 var_ref_vals[TRACING_MAP_VARS_MAX];
> >  	char compound_key[HIST_KEY_SIZE_MAX];
> >  	struct tracing_map_elt *elt = NULL;
> > -	struct stack_trace stacktrace;
> >  	struct hist_field *key_field;
> >  	u64 field_contents;
> >  	void *key = NULL;
> > @@ -5198,14 +5197,9 @@ static void event_hist_trigger(struct ev
> >  		key_field = hist_data->fields[i];
> >  
> >  		if (key_field->flags & HIST_FIELD_FL_STACKTRACE) {
> > -			stacktrace.max_entries = HIST_STACKTRACE_DEPTH;
> > -			stacktrace.entries = entries;
> > -			stacktrace.nr_entries = 0;
> > -			stacktrace.skip = HIST_STACKTRACE_SKIP;
> > -
> > -			memset(stacktrace.entries, 0,
> > HIST_STACKTRACE_SIZE);
> > -			save_stack_trace(&stacktrace);
> > -
> > +			memset(entries, 0, HIST_STACKTRACE_SIZE);
> > +			stack_trace_save(entries,
> > HIST_STACKTRACE_DEPTH,
> > +					 HIST_STACKTRACE_SKIP);
> >  			key = entries;
> >  		} else {
> >  			field_contents = key_field->fn(key_field, elt,
> > rbe, rec);
> > 
> 
> 

