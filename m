Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFBD9C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:02:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B072520843
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:02:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hLZf25bq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B072520843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E9746B0005; Tue, 13 Aug 2019 05:02:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 499E96B0006; Tue, 13 Aug 2019 05:02:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 389256B0007; Tue, 13 Aug 2019 05:02:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0237.hostedemail.com [216.40.44.237])
	by kanga.kvack.org (Postfix) with ESMTP id 171746B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:02:27 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B4A39180AD805
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:02:26 +0000 (UTC)
X-FDA: 75816813492.25.dress67_89b204cb3d13b
X-HE-Tag: dress67_89b204cb3d13b
X-Filterd-Recvd-Size: 4222
Received: from mail-lf1-f65.google.com (mail-lf1-f65.google.com [209.85.167.65])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:02:26 +0000 (UTC)
Received: by mail-lf1-f65.google.com with SMTP id j17so22215833lfp.3
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 02:02:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zbadPFLbmftsI8N+IuNnBjaQB4827jD6fnEJgLKNTZs=;
        b=hLZf25bqcvbX25xNuMZbR5PzvxV6GImnoNKHQjbf8sETv7Ar9mx/GVJVNlFBiUoI+x
         OaBu+PCv1W1Alu6XSNHoHrNCp537Atpgj+R9HmRLZFXqzKsJ80D0kddeGkeb1Dqn7Kh4
         2qCin8I2SdptK0jFV8ULLCBJ5lOvpY0rk8B58UyCaS71IqEbPmstIIGYsGLKFiUdRVeg
         4x0pTMXVaKNeZJQeADuHIPNtlLphOYlT0XTQncnLpdJrQPPcNRRt+vf/l9AFxpkaF5yX
         xnhwZBqi6uccNYt04vgFRAZzxWAC+/fwgCCIT+XdyRKjlzxTa9KCw0iUesn6i5pyFpVa
         Nq0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:date:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=zbadPFLbmftsI8N+IuNnBjaQB4827jD6fnEJgLKNTZs=;
        b=UW/0ewAffxzLuUDOMMedytwfOzSW6HO6c4tOFOVBjmUq/nSRt3HPjhLwt2fxRuHl3v
         uJdQuVuzcJK2QTey4pVpbvXMxHfTGGdnngh2h0lU6T1/aC385pwvtCcVM5ayFCQuSTiz
         6ss5MtseTKMWmiMFzN6ISLgPstPxAAFchRqok5y8LH06DVLU52GZziSnro5PPtKoOhRJ
         8eCurVnrDjrm2GLSrpDporwZk7O7V5jKsBVnr4wB7aRTnf9ko7TLv28Jqvkhe+XtsLbO
         LMlLqYoYA8PHl4sWgcy6VhVnpWZlf9xOIwqt2KbqKgEZdT2+A3S/jM1g/5SZovczs3nX
         h3zA==
X-Gm-Message-State: APjAAAXGgmOcbz+pVovtDa+e96OhTsFTy3eS1KsQOFa2jlYNa0ZDRhxR
	FpxB4CX1hisHevxyOWmnFr8=
X-Google-Smtp-Source: APXvYqy8fBTXU8joNbGcSdpzVSvcOsS+2SxvVrN6+XsBFW7jGeYY3vigBmz3AZfzQPtQkVS+Jua7Zg==
X-Received: by 2002:ac2:4948:: with SMTP id o8mr1126632lfi.13.1565686944834;
        Tue, 13 Aug 2019 02:02:24 -0700 (PDT)
Received: from pc636 ([37.212.214.187])
        by smtp.gmail.com with ESMTPSA id o3sm19538418lfb.40.2019.08.13.02.02.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Aug 2019 02:02:24 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 13 Aug 2019 11:02:14 +0200
To: Michel Lespinasse <walken@google.com>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>, Roman Gushchin <guro@fb.com>,
	Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] mm/vmalloc: use generated callback to populate
 subtree_max_size
Message-ID: <20190813090214.xy6tgvar6kiartkb@pc636>
References: <20190811184613.20463-1-urezki@gmail.com>
 <20190811184613.20463-3-urezki@gmail.com>
 <CANN689Hh-Pr-3r9HD7w=FcNGfj_E7-9HVsHu3J9gZts_DYug8A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689Hh-Pr-3r9HD7w=FcNGfj_E7-9HVsHu3J9gZts_DYug8A@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 11, 2019 at 05:39:23PM -0700, Michel Lespinasse wrote:
> On Sun, Aug 11, 2019 at 11:46 AM Uladzislau Rezki (Sony)
> <urezki@gmail.com> wrote:
> > RB_DECLARE_CALLBACKS_MAX defines its own callback to update the
> > augmented subtree information after a node is modified. It makes
> > sense to use it instead of our own propagate implementation.
> >
> > Apart of that, in case of using generated callback we can eliminate
> > compute_subtree_max_size() function and get rid of duplication.
> >
> > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> 
> Reviewed-by: Michel Lespinasse <walken@google.com>
> 
> Love it. Thanks a lot for the cleanup!
Thank you for review!

--
Vlad Rezki

