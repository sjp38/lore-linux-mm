Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42226C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 08:53:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00ACB20823
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 08:53:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l2ZimJ7+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00ACB20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 856628E0002; Tue, 18 Jun 2019 04:53:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 807488E0001; Tue, 18 Jun 2019 04:53:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CF368E0002; Tue, 18 Jun 2019 04:53:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0696D8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 04:53:54 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id a19so2464991ljk.18
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:53:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mVLl8qg2zqaDh/gdEb9wEQJKnsVlAR9GRhHD703Wsgg=;
        b=TfMzJ9cOHlBQVtwOcdy/69w+kzcAnag/sAOXdmlzXeR34C3wlaTJvDf5y/LeobIAYn
         GO/aQSv4K468RSxR95hHy7uyhLXXjUOdIb7FOSyXxQBU1xe9DJ7GyLKsEtOYvnBQTOEz
         e5FSuYgMZlPEYDtXd24z/SRQNu7Y7EYq7odjq7AK5XnW4koFUUS8E0xImWcY8jjwtE0u
         w+oURCAin50IKk1ZnUUFGLhKxDIT83Hw1G0vb9IIGOJU22WCIV1Uigh1DeIDhMVD6ZrD
         Wd5dWdhimm7SYEQYA7TnZocTGKQr0FJb+M0ZAZggPYpxpw7Bi74h6SsOHDbTfoimnPlZ
         N0OA==
X-Gm-Message-State: APjAAAXJkWo/74rzz/u5+R5h3NCTItrZ45uk/zFF6V+INyeWeHcr4U/p
	fZB93C9VpMpD5txkUersa/pX9TwBr/Nv7ogtr3sh+ItUxbDgW8hduXMWZcB2jR66QDLAhMlJ9Lt
	GRFJr8HJEzKyzBHPDasfVea2C4aOjlhL5XbXBdCVWU86qQsdtrEp55N2LjzPj9FCsFQ==
X-Received: by 2002:a19:4bc5:: with SMTP id y188mr58128757lfa.113.1560848033200;
        Tue, 18 Jun 2019 01:53:53 -0700 (PDT)
X-Received: by 2002:a19:4bc5:: with SMTP id y188mr58128734lfa.113.1560848032465;
        Tue, 18 Jun 2019 01:53:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560848032; cv=none;
        d=google.com; s=arc-20160816;
        b=HR1ReBS/JgyDfJ9NOzYFEeilyB/9n0Efp2LZycC1grqdC6C4P1aty59u+PQMzPffiA
         wfFQFOdIvmPDdu6gLIew1gMTUHdaSTJcvWPbgMRTvNy6+g+4kAEkcBpTnYv8qj0H05cH
         RSFpdOaYlvFo2M5GeaP5xCs+6uvDN5s8QwcgrNXOEV5W8tNqUGfsVOqUFlF3wTNqu1jU
         AtEsi5siKYAbng3X4PUmnj0I2cKIHq4uCfzYmvmbqNbP7nPSjBiSokVFithmAn7gJ+j+
         1G//YShwzvMgSyBFaSdTRTD17ZmCEsTjMCGhhdVz0U+sIQ27ajQwQP0yyBNBAiJElRXx
         j43A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=mVLl8qg2zqaDh/gdEb9wEQJKnsVlAR9GRhHD703Wsgg=;
        b=C3VW+pOJ7bxNFyn0WATrOzYzbaQTuIcCwOgOTNy2VTIgen2K5U/hSYxnFFsJjQ+uYA
         +zY3PeS7cbWnzaKgNW/dsViIarzCardXkpoDohtZ8Q3Rlg4Eqm0S/ChCFo6hKOWOiovT
         IBmpZc5WUW31pDNSjG9zzJzoVLCIOrYUF66000jFSkoPFk84qBQWTuJvnneNWG/1Dgwa
         fs6/jkWeYIr2JeGabmxALNJMJflZXtpNLeFVqVsor9l+QYoSgJIGWOQIwB180vfmy7LU
         ZTHKOHCW4/a/6Ptk34DYuEfE7KlxTz5PbXNjcIRhC4xDJjob46+rr+2mX3o9UK2HXY4z
         Bnkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=l2ZimJ7+;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r23sor7582310lja.30.2019.06.18.01.53.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 01:53:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=l2ZimJ7+;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mVLl8qg2zqaDh/gdEb9wEQJKnsVlAR9GRhHD703Wsgg=;
        b=l2ZimJ7+joIbXpMgW56vhJYwQSFrL4LWu4I7Ql+izeYannpJQEcxzhi1PpOZqGp7Y9
         grcDAB8AMXGefwDH3jV+zqepNU36ABB3k9eKqk8Nw68FmxMzsK3Rb45qQ9VEwiqam+kz
         UuvVEXbxMQn0q+m5/q2amKho+FM5PQkIZndzUEJs7i+nyKpbmG7fsOY6M5ny+IXLsJiP
         z2vN3wUJiQU/xVehwZV3jWIOIhjhxbZLKUD3yKRi0HoXn1aW0AlGxXAG4mChYMJGFkQj
         VCCHFoQs1Jv4J7JVbCBv+rl3t+1T4t4erpmwcr9XnkhmovAWlkcncPQgYtbM/1ggU6jX
         K2Ig==
X-Google-Smtp-Source: APXvYqzG4Ae/L2osFup2Ddti5CVcK2yNW8/zwQGdGN5YhfLW1DknSSgh1gx+OGNhdXqd9hXaqchy/g==
X-Received: by 2002:a2e:8ed2:: with SMTP id e18mr15912316ljl.235.1560848031996;
        Tue, 18 Jun 2019 01:53:51 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id r84sm2744089lja.54.2019.06.18.01.53.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 01:53:51 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 18 Jun 2019 10:53:43 +0200
To: Arnd Bergmann <arnd@arndb.de>
Cc: Uladzislau Rezki <urezki@gmail.com>, Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Roman Penyaev <rpenyaev@suse.de>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mike Rapoport <rppt@linux.ibm.com>, Linux-MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [BUG]: mm/vmalloc: uninitialized variable access in
 pcpu_get_vm_areas
Message-ID: <20190618085343.i6trqxavavkfipzb@pc636>
References: <20190617121427.77565-1-arnd@arndb.de>
 <20190617141244.5x22nrylw7hodafp@pc636>
 <CAK8P3a3sjuyeQBUprGFGCXUSDAJN_+c+2z=pCR5J05rByBVByQ@mail.gmail.com>
 <CAK8P3a0pnEnzfMkCi7Nb97-nG4vnAj7fOepfOaW0OtywP8TLpw@mail.gmail.com>
 <20190617165730.5l7z47n3vg73q7mp@pc636>
 <CAK8P3a1Ab2MVVgSh4EW0Yef_BsxcRbkxarknMzV7tOA+s79qsA@mail.gmail.com>
 <CAK8P3a0965MhQfpygCqxqnocLt9f4L80-mF-UgoP5OdAoLCCqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a0965MhQfpygCqxqnocLt9f4L80-mF-UgoP5OdAoLCCqw@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Arnd.

> 
> Nevermind, the warning came back after all. It's now down to
> one out of 2000 randconfig builds I tested, but that's not good
> enough. I'll send a patch the way you suggested.
> 
Makes sense to me :)

Thank you.

--
Vlad Rezki

