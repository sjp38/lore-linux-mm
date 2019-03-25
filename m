Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53F3CC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 17:02:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C7A7208E4
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 17:02:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C7A7208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D8E86B0003; Mon, 25 Mar 2019 13:02:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 986D96B0006; Mon, 25 Mar 2019 13:02:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 877186B0007; Mon, 25 Mar 2019 13:02:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE646B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 13:02:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e55so4080091edd.6
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:02:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=srOOFOMLqqaKksrJkyj9RLUnmBAbmmmTkj10WcZSBCg=;
        b=csKTqkPqvgVF4i59wKVhQOt1UREScqDh5WGZNdXrOpzzxoIUj0S9WfVo+qLZQmNefe
         eVvFtLAVpwwavZWSJYNxL1byybk+Hyi4rD++Eqn+8rynQqPuGHc1eJncf+pBZ0nz6tpk
         xjVq1YnVaIakVm35cH2ENBShswbfxZZW+3EACe1O+yyno2ANa8KaneqM2kzL7Iss9f0Y
         SlILLQj3ztDxmVLx6nsbx7GKNudoTirfG1NoUVjGx5JVaVmdHWa8zd5Uvy7S3Ovc0ka9
         0LOcjgST/IOeJYrnwfkgaQ7WBVtAgIx8e6dQV9mmwuNoyTgpORvO+tbsXXOY2JRsRrLo
         WiUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXdfZH8g8SpRzGtT7pIa78u/b5kLxbUtlD1GLpfEEr175mpVtwD
	+PSnJhfaAjdmHrUN5KNsXzu+acdnjyhYbKYR7dZ6HJ4JeChGyxJsu6EvzKN93OYVUyBR9rXWp9W
	WJxhZCAidIrvlgdH1WbEO5is1lGrCUbYMJyL0ItTRaflFexE3ryhrUCx4pg5Kk48Emg==
X-Received: by 2002:a50:f286:: with SMTP id f6mr17082826edm.139.1553533328913;
        Mon, 25 Mar 2019 10:02:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUJ1ROXoLoa6Cc/obFLN1EB/Im7qehdA9cxCdZa8WmdmR2JeVUoJ+qdggv1PqtdMMB9gbY
X-Received: by 2002:a50:f286:: with SMTP id f6mr17082786edm.139.1553533328182;
        Mon, 25 Mar 2019 10:02:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553533328; cv=none;
        d=google.com; s=arc-20160816;
        b=rKAKa1nVKZKoQNY+pA9E/9keiiPPKJau6FoZQPVKDyoB4+ZrBlb4tXZbG86QUnsZpg
         A9h8ABvAbvWivfzPxoIJy7frkSTRcDGiW1QjRyFjRkFpQOBEZ7Xm/mS0YUgZlyMKLs1X
         SelUyg3dVvRuWpBYhVtZ2LbOUKmVi9W+hqmqEdseNAFpGThJcEqt93zRNmJcfXHXAiTP
         Wyv8LG/E87f9UmR13cwhyP5bjD/D+2UsHo77s30g2zoD0dMVwCx/R+8TMiCh1lQCh5pj
         73vFmPhtVzOf1pKeMvXfdE0Mte+Qw5swuZp7QHWnBTcm+VpR7vqB9bTWX76z5Pwvj2v6
         RjsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=srOOFOMLqqaKksrJkyj9RLUnmBAbmmmTkj10WcZSBCg=;
        b=Q9tp4zJLAciWWVQvOYbFg7xwk8NWXu9WhlksmX5+ko7OOGP56ammsjsQnUYXDWu4dR
         XmXRRB3LnGMO8aC/U/YJ/ryBtPfIRcqY6Z0SLrFO5vg8UzW0XRtkXxPwfNvAkTM/pp7c
         afVXw0uqfJz/6hO1FxmWOfC4x88XJApoz2fLkhxrHyj/0GayvcAZi1uLxDugLFMymDba
         1bSJXL+45tBF/h3o5YH1XXoE19kRTIVBtgbeq8o7OE2q0UnM5yJ8s6GolnsdaONbf0ka
         xZA/q8rHx0tnUzu/BllT4jalxM8ANBkwLzARMD/TWnc7t/cfUZRkPzX2+HU+UGapa130
         u3gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p54si86174edc.398.2019.03.25.10.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 10:02:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5D69EAF17;
	Mon, 25 Mar 2019 17:02:07 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 04FCC1E429A; Mon, 25 Mar 2019 18:02:07 +0100 (CET)
Date: Mon, 25 Mar 2019 18:02:06 +0100
From: Jan Kara <jack@suse.cz>
To: Sasha Levin <sashal@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn()
Message-ID: <20190325170206.GH8308@quack2.suse.cz>
References: <20190311084537.16029-1-jack@suse.cz>
 <20190325003820.EED802147A@mail.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325003820.EED802147A@mail.kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 25-03-19 00:38:20, Sasha Levin wrote:
> Hi,
> 
> [This is an automated email]
> 
> This commit has been processed because it contains a "Fixes:" tag,
> fixing commit: b2770da64254 mm: add vm_insert_mixed_mkwrite().
> 
> The bot has tested the following trees: v5.0.3, v4.19.30, v4.14.107.
> 
> v5.0.3: Build OK!
> v4.19.30: Failed to apply! Possible dependencies:
>     f2c57d91b0d9 ("mm: Fix warning in insert_pfn()")
> 
> v4.14.107: Failed to apply! Possible dependencies:
>     f2c57d91b0d9 ("mm: Fix warning in insert_pfn()")
> 
> 
> How should we proceed with this patch?

I'd say apply also f2c57d91b0d9 to both trees. Nice automation BTW :).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

