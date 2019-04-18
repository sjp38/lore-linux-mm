Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 443ABC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:40:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0017F2183F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:40:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0017F2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A60F6B0006; Thu, 18 Apr 2019 09:40:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8555C6B0008; Thu, 18 Apr 2019 09:40:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 746486B000A; Thu, 18 Apr 2019 09:40:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC2B6B0006
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:40:20 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id c7so1517507plo.8
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:40:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EhGohp98dajYydgt0W68QLMG3WNkyvoG32dk/didwEw=;
        b=Aki8RWdwRNAOgFnmEtht09WmOtR9OzcjHsAWQjYR0MpS8wDEDWWYXZNdS/0HIVW3B3
         MOz/Fh3d67I4jeVoatzug9p2wWXezSprXfrNiNqYs6D3x/1fXP01uCOWcR56MWhpWa3R
         WaK9P2ygUMnhffb71dvdlpylkMlQn7jPvfElFuBZrKTJmdXAXP6VY9LdSCrVMaP24mJg
         2zI8wnLkqWRCUaaRN0JKAgsf5cm8jS6NnoMqFFEeUuV2wix4I1csmO5JWIcrpYP3EvH/
         x1sBhVUu0GfEY9eqoHrztwoNw52WO52e/6j/ex1tiESzhQg5siTPL+VljzWHci3yqewF
         LRRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAUq9s3pMnkxoOECcixciPuvO2ugoXzI2kZMuHaN1xJnwLTJGBDW
	+BrG/BkHKcO1k+Hlb/h0VSMxAgD1u9WtWlquibiF5DiTNj5HYShVGyhS098FOQ+x5RCQHP+4HH2
	H5/kn+JQHseSVLyIPChq6a+2x/121GE0f3yNgZfGpd1ojkvSc8tGjpo8bGZ9qDfs=
X-Received: by 2002:a17:902:a704:: with SMTP id w4mr92332726plq.51.1555594819901;
        Thu, 18 Apr 2019 06:40:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzj3DsWhZCTDNNdS1PFM6ZzUd2XJe3hegcmusi6VT3qqXZzE60d0KffOgz8NQh4odseZ80v
X-Received: by 2002:a17:902:a704:: with SMTP id w4mr92332671plq.51.1555594818996;
        Thu, 18 Apr 2019 06:40:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555594818; cv=none;
        d=google.com; s=arc-20160816;
        b=BVaJMlmeY2COhPcAnZKe/gMrYbpP27XIthsQvIkkmWoXfFDrxws0K+qUfh5ZH5d0Ui
         1ZNDrAuR4hPELaZhgd2WpbC8oio1kNZ8Xeihyz0HqdGMuMa/liFCvBiCLresdY8ajavf
         qG/2VeDqD4teADGT9yz05gSDxrnnPNwkK6MpUpR0OOC3DzRgcIwq+bfl6cOFw9u5nM5B
         4zxnLxhfvej2X3xDrjh3bwTS/KJM/Axm646qTWgmuv+L4VdHthVK1gyKPioDLtkA1IKs
         C+b6L5Dqz45ln+eyIaLGz0GY4J5IRqFzNlIZO6PrduYEgHiOcwppf1Dazjlrz4SWTCVK
         4Klg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=EhGohp98dajYydgt0W68QLMG3WNkyvoG32dk/didwEw=;
        b=Wf7yOsYez1p3hxMtVmSrs75PkkcEP6a+onxbHvt7NOhqjj+4JF/Whg+u4L8MvPOako
         M4YCYc7o04/rx1Tl/FT0go+d0GOjQkJ7JszFqzKsBDxeQ8GvXpOsNwQxO6iW+tQEXo/u
         LnYDIoWfT/u1obhABCY/c8H4F8jJCZAp/w0asCFW7c7EQGqHKmMWxw/2otdQT8vq14Vc
         ObqCFXBOIYCkdRGppvI3uYZXBqGo22Dgu7WMObLfq36Z1fZaeK/sZgFsC4EoJo0Rky8G
         17F8Eye6BA8QwXPLhtBtArrQ70IzRG4sl6LKA7Ry784VGqozUahyvZ9EWkoKJ8iYYqBf
         MnvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k12si1800962pgo.429.2019.04.18.06.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 06:40:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 77CD12083D;
	Thu, 18 Apr 2019 13:40:15 +0000 (UTC)
Date: Thu, 18 Apr 2019 09:40:14 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Thomas Gleixner <tglx@linutronix.de>, Tom Zanussi
 <tom.zanussi@linux.intel.com>
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
Subject: Re: [patch V2 20/29] tracing: Simplify stacktrace retrieval in
 histograms
Message-ID: <20190418094014.7d457f29@gandalf.local.home>
In-Reply-To: <20190418084254.910579307@linutronix.de>
References: <20190418084119.056416939@linutronix.de>
	<20190418084254.910579307@linutronix.de>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


[ Added Tom Zanussi ]

On Thu, 18 Apr 2019 10:41:39 +0200
Thomas Gleixner <tglx@linutronix.de> wrote:

> The indirection through struct stack_trace is not necessary at all. Use the
> storage array based interface.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Steven Rostedt <rostedt@goodmis.org>

Looks fine to me

Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

 But...

Tom,

Can you review this too?

Patch series starts here:

  http://lkml.kernel.org/r/20190418084119.056416939@linutronix.de

Thanks,

-- Steve

> ---
>  kernel/trace/trace_events_hist.c |   12 +++---------
>  1 file changed, 3 insertions(+), 9 deletions(-)
> 
> --- a/kernel/trace/trace_events_hist.c
> +++ b/kernel/trace/trace_events_hist.c
> @@ -5186,7 +5186,6 @@ static void event_hist_trigger(struct ev
>  	u64 var_ref_vals[TRACING_MAP_VARS_MAX];
>  	char compound_key[HIST_KEY_SIZE_MAX];
>  	struct tracing_map_elt *elt = NULL;
> -	struct stack_trace stacktrace;
>  	struct hist_field *key_field;
>  	u64 field_contents;
>  	void *key = NULL;
> @@ -5198,14 +5197,9 @@ static void event_hist_trigger(struct ev
>  		key_field = hist_data->fields[i];
>  
>  		if (key_field->flags & HIST_FIELD_FL_STACKTRACE) {
> -			stacktrace.max_entries = HIST_STACKTRACE_DEPTH;
> -			stacktrace.entries = entries;
> -			stacktrace.nr_entries = 0;
> -			stacktrace.skip = HIST_STACKTRACE_SKIP;
> -
> -			memset(stacktrace.entries, 0, HIST_STACKTRACE_SIZE);
> -			save_stack_trace(&stacktrace);
> -
> +			memset(entries, 0, HIST_STACKTRACE_SIZE);
> +			stack_trace_save(entries, HIST_STACKTRACE_DEPTH,
> +					 HIST_STACKTRACE_SKIP);
>  			key = entries;
>  		} else {
>  			field_contents = key_field->fn(key_field, elt, rbe, rec);
> 

