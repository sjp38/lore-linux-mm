Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 065AAC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 11:27:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC11F2087C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 11:27:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC11F2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32CD78E0003; Wed, 27 Feb 2019 06:27:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DAEC8E0001; Wed, 27 Feb 2019 06:27:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F4678E0003; Wed, 27 Feb 2019 06:27:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B67FF8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 06:27:24 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id a21so6900258eda.3
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 03:27:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=addUXOH8mBS9PDRZhVKLYGRysT2WZTxpHp1e4SSYAvc=;
        b=lEWrdG0Jqu+2B49VELAEHPYWz7uWGQlESCQAue8WHkpde8B1U61MTrJvtXZkU196uU
         f1iF9oJEQNLo2oKkP4oI8YmTLWWORi8BdCYnFobMj1Ykp+qFd+JVaxhxHdn0gNoFgDRd
         UPdssEeusy+kB/wgZjS1DnyMT/vS8B0oc+vglvNr6kwSTz6wHPMoJN+As6/ZkvI19UfI
         xADnWlhKjwWy689bVsPg6ewjC9yogJz3rOQSi6DkoNFbS8qu+HxEkUkL62LhSFUgyI8T
         ZO1SufelmwUiCJoxli8uSbwVT3oeVTrvsJj2/hoG+5yTxXBnAf2YaPKsFr5ywOMviqzu
         l1VA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuYRXZLyZwacrY2wy5NBT/D6cjfsm/U5h2obSsOhAr/A90rNKv7R
	jruG4KnIotN9rJ1E9yhEcNPh2FNhc92DOFuyHWmyolRseNdm65uSytfl0xv/yFd5oeZJEKIwKn9
	VaGFFEcyfzYQcLCI9ts1Lwuzvluuk+YgOq2osMXwxOCrY8Cm4sHGFsuH8lXVVcqY72g==
X-Received: by 2002:a17:906:28c7:: with SMTP id p7mr1194362ejd.235.1551266844297;
        Wed, 27 Feb 2019 03:27:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZtO8SnN6R2nFDaABb2lZs19JrEFhiBZsLFOKATsmMGJcRSwZ1q+S/9XQ5LMkqnQN2qvE3Y
X-Received: by 2002:a17:906:28c7:: with SMTP id p7mr1194296ejd.235.1551266843123;
        Wed, 27 Feb 2019 03:27:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551266843; cv=none;
        d=google.com; s=arc-20160816;
        b=p86YV+WjF9YOJvdk1X9rZqEzXPX/XfAEw6YI/XJ9WWbIDNAKfLvWbh6OnaL+z7wDv+
         PmVJQeg83vylWqbfc6kOGiv+P7yme+PPvttfcJNOtH6wR9WlEv9nyYncoBsYSOvszIem
         1BAgepJSYd+SHRhEPo+Gl6RcX3h3ETSqcjvpAZMcV7opHYxxmMrghzxZDcUcOeXJmfUU
         qxEQLbMOXUccYm5Pzqs1CudZbYPUmK55pLTfa1ZOOQjh6gys52/el2WF1IU3F9wRTiup
         ML0X1Y50hDHmGuibx6Nm4iUJgKl7lml88/zFvIxOaxKCVja2+xBERRdk1KS6cOQ6uLRJ
         EiPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=addUXOH8mBS9PDRZhVKLYGRysT2WZTxpHp1e4SSYAvc=;
        b=DJU4ztsg4D1huvm0Ydk9fYm8ziyROMMNqStljJsYaTETjL+2/WqHhS4sURGEEkzQGE
         Ba8kZOHr1QGqVT7rTlBC+B4fseeh8CV9iq+3oY9ELad/g0Bt17+Yubv8nri/RihFeSYe
         aZdn1OZvd09ukOXwZqElpZfQ/rJG8gJJz/Fe3ojenObe+bvlUiXHYU0t5+6IgSPNRA36
         pxLIdgebUiRF3VQLJf2v7UneDhI2b+Mi5Rg76i4ZNaLMAivl8N7pzVTCks8awF3lHTBu
         yFump8rlPKzwHLEs4mm82HDtcnD1WdiGuMZq2KN7Gvum3cfI0vByayhM3DtvgOxejJ9D
         UTvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t32si5968071edd.442.2019.02.27.03.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 03:27:22 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F2FDFAC6C;
	Wed, 27 Feb 2019 11:27:21 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id B755E1E4264; Wed, 27 Feb 2019 12:27:21 +0100 (CET)
Date: Wed, 27 Feb 2019 12:27:21 +0100
From: Jan Kara <jack@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mgorman@suse.de
Subject: Re: Truncate regression due to commit 69b6c1319b6
Message-ID: <20190227112721.GB27119@quack2.suse.cz>
References: <20190226165628.GB24711@quack2.suse.cz>
 <20190226172744.GH11592@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226172744.GH11592@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-02-19 09:27:44, Matthew Wilcox wrote:
> On Tue, Feb 26, 2019 at 05:56:28PM +0100, Jan Kara wrote:
> > after some peripeties, I was able to bisect down to a regression in
> > truncate performance caused by commit 69b6c1319b6 "mm: Convert truncate to
> > XArray".
> 
> [...]
> 
> > I've gathered also perf profiles but from the first look they don't show
> > anything surprising besides xas_load() and xas_store() taking up more time
> > than original counterparts did. I'll try to dig more into this but any idea
> > is appreciated.
> 
> Well, that's a short and sweet little commit.  Stripped of comment
> changes, it's just:
> 
> -       struct radix_tree_node *node;
> -       void **slot;
> +       XA_STATE(xas, &mapping->i_pages, index);
>  
> -       if (!__radix_tree_lookup(&mapping->i_pages, index, &node, &slot))
> +       xas_set_update(&xas, workingset_update_node);
> +       if (xas_load(&xas) != entry)
>                 return;
> -       if (*slot != entry)
> -               return;
> -       __radix_tree_replace(&mapping->i_pages, node, slot, NULL,
> -                            workingset_update_node);
> +       xas_store(&xas, NULL);

Yes, the code change is small. Thanks to you splitting the changes, the
regression is easier to analyze so thanks for that :)

> I have a few reactions to this:
> 
> 1. I'm concerned that the XArray may generally be slower than the radix
> tree was.  I didn't notice that in my testing, but maybe I didn't do
> the right tests.

So one difference I've noticed when staring into the code and annotated
perf traces is that xas_store() will call xas_init_marks() when stored
entry is 0. __radix_tree_replace() didn't do this. And the cache misses we
take from checking tags do add up. After hacking the code in xas_store() so
that __clear_shadow_entry() does not touch tags, I get around half of the
regression back. For now I didn't think how to do this so that the API
remains reasonably clean. So now we are at:

COMMIT      AVG            STDDEV
a97e7904c0  1431256.500000 1489.361759
69b6c1319b  1566944.000000 2252.692877
notaginit   1483740.700000 7680.583455

> 2. The setup overhead of the XA_STATE might be a problem.
> If so, we can do some batching in order to improve things.
> I suspect your test is calling __clear_shadow_entry through the
> truncate_exceptional_pvec_entries() path, which is already a batch.
> Maybe something like patch [1] at the end of this mail.

So this apparently contributes as well but not too much. With your patch
applied on top of 'notaginit' kernel above I've got to:

batched-xas 1473900.300000 950.439377

> 3. Perhaps we can actually get rid of truncate_exceptional_pvec_entries().
> It seems a little daft for page_cache_delete_batch() to skip value
> entries, only for truncate_exceptional_pvec_entries() to erase them in
> a second pass.  Truncation is truncation, and perhaps we can handle all
> of it in one place?
> 
> 4. Now that calling through a function pointer is expensive, thanks to
> Spectre/Meltdown/..., I've been considering removing the general-purpose
> update function, which is only used by the page cache.  Instead move parts
> of workingset.c into the XArray code and use a bit in the xa_flags to
> indicate that the node should be tracked on an LRU if it contains only
> value entries.

I agree these two are good ideas to improve the speed. But old radix tree
code has these issues as well so they are not the reason of this
regression. So I'd like to track down where Xarray code is slower first.

I'm going to dig more into annotated profiles...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

