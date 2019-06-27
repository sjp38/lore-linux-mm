Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.9 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE624C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 23:56:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A00C2067D
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 23:56:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TD/Y9ETx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A00C2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1740B6B0005; Thu, 27 Jun 2019 19:56:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FDF88E0003; Thu, 27 Jun 2019 19:56:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB88C8E0002; Thu, 27 Jun 2019 19:56:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0D016B0005
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 19:56:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so2554060pfo.22
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 16:56:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CLj4gZCTfK/NAoTIvU2cEk9DiiqDuv0OJwpnaduKmqA=;
        b=XWV6PXGrc2oBN3tsAVEAUb1uLZxwhOqfv1vtiOt6xxbkDfV1YNWPTcwaGwSuqoLHgt
         95JYhG48iBgMzbVDOs+0APnHqQY85bbB32lyWiCfRPTr464FhmUJ0a3Nng/WhJ6gQMzn
         EGgogzcz+pLtb3C2Jsu9mIecHC7abJO/WVGoAyrRjCsMAHq44jlbkKnnryw3liDyWKj0
         0nKqG8UhgUrh2ZZ6nkmIeNuKXZJikv73rw3zmjN7xBlxVdYd/laybg59t3h1xXUsR0U6
         BwsOHVgFqcA5CLxLpYIApyPSz7j/xn8AdFgOQ7B+3E7DiExwe4qutSOy53LxwxNQi19e
         javg==
X-Gm-Message-State: APjAAAV4rr8k70chFwoxZRxCxZc/fqa/Y+bsLakaqgFQtgowT512VFts
	OKsgpEicMYlGrjHvefHvk5SCj2Hp14/58nPj2xYkKpnSOxXoSnallu4p+brrHWOwGpnq5Llli9g
	O6TAhseV3jS4y4/vb3c57z/RKs9QOnOjeKzGvzJVf2v22awAnGWhm4wBKiimRuwI=
X-Received: by 2002:a17:90a:a397:: with SMTP id x23mr9505763pjp.118.1561679787350;
        Thu, 27 Jun 2019 16:56:27 -0700 (PDT)
X-Received: by 2002:a17:90a:a397:: with SMTP id x23mr9505720pjp.118.1561679786772;
        Thu, 27 Jun 2019 16:56:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561679786; cv=none;
        d=google.com; s=arc-20160816;
        b=e79CThpYj9n1/aI2H+uH5FX2h68PVCDlHSkYhBiPS5RJRLDge367IM/rwlBevzdKoa
         jlBYLUPyxVJsSSqpt0BYNAC0GquwP/ndevmGggTdT+Tzr3a5jV386Y9vckyFcj95pb52
         We2ovo915xITIJU9+Wy6q5+yE9E8KmEh6KkKElRvKg5oJo1FnaTfB7jmJ60uQMR32ELh
         H9QjoP4tlVKnVl/JCTMFvu+6YUPZuch2rxiHOc0TPlzZlycQ9W6fx7g77njyhZOeOukJ
         H5s5OOqkyvoTLSEnsVcPZ8OzmtU1Lq+1tS4qV77WsBZYnO+Khj8fmfbjuvUscAeadil4
         2tDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=CLj4gZCTfK/NAoTIvU2cEk9DiiqDuv0OJwpnaduKmqA=;
        b=m8lvCAu6POqFfQbYph4gf2we2UEV7O493+AFnJ6xpOdFd5NmguXeMQ/nuU3gNJ5qVS
         dlyOltE8waJ/qHda+EI4/5rmyn1E8cUwS/GAwnMWXJhHKC4hVruOd7PDaz4LyXL1FgLT
         6nMMM+nEy+t0oX0HWqQLxhe9OogKhsz6hzhzjG49nECMR7caqfj1niZk058Ry7T7WXaF
         d8l1RaHqcEVyJcqjKrU9+JB/7QO0X3qJ/EQltNINr84+pmDYVARugXSl7KQ3ZISsJCz4
         YygCoITTT5fvWUyU/wvsIYHnRJcMLFr4ySC7XFjMbFWhhCvtxC0pNvjg86429xu5uYfW
         tC2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="TD/Y9ETx";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1sor209587pfb.34.2019.06.27.16.56.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 16:56:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="TD/Y9ETx";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CLj4gZCTfK/NAoTIvU2cEk9DiiqDuv0OJwpnaduKmqA=;
        b=TD/Y9ETxzwIz92B9+E24f8PXv4qRImq4vZCpEFH0DQAK0HYr9/LCzuC51LYrglkt9H
         x107u1OY4skzs+uUyX/5RNDgKbdmpfJ8q6NcbT0lRYiwUwQqAQXplH4P8knqbVMuCLfr
         r/QQe6OnL2EdKXhlSxyR6ooko9ZkW529nCwU12nL1zwuVwh8bQieBXaxA9q9y5G+xBqY
         JuztrCRRnJKg3B6VfnSKAdOn3ZHw5uh4V1BpQH+y3R+eK1C30Ajm+GSGH2SLlqmnzRb5
         Oq2itXwjtvyt4k1Z1Jlm5GX+GuhGPQJiPvrankJmbqYBzY2I7Rr8KdQBdGF8XuhmHrYj
         vdvQ==
X-Google-Smtp-Source: APXvYqwioUiNv41x01aQdRcQnt8g3CLHIHh9zwhAz5EQgEvfxKBbPX0L6hoApe0uDHiYVFbY+15cDA==
X-Received: by 2002:a63:4c46:: with SMTP id m6mr6527455pgl.59.1561679786207;
        Thu, 27 Jun 2019 16:56:26 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id a3sm319767pje.3.2019.06.27.16.56.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 16:56:24 -0700 (PDT)
Date: Fri, 28 Jun 2019 08:56:18 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 1/5] mm: introduce MADV_COLD
Message-ID: <20190627235618.GC33052@google.com>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-2-minchan@kernel.org>
 <343599f9-3d99-b74f-1732-368e584fa5ef@intel.com>
 <20190627140203.GB5303@dhcp22.suse.cz>
 <d9341eb3-08eb-3c2b-9786-00b8a4f59953@intel.com>
 <20190627145302.GC5303@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190627145302.GC5303@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 04:53:02PM +0200, Michal Hocko wrote:
> On Thu 27-06-19 07:36:50, Dave Hansen wrote:
> [...]
> > For MADV_COLD, if we defined it like this, I think we could use it for
> > both purposes (demotion and LRU movement):
> > 
> > 	Pages in the specified regions will be treated as less-recently-
> > 	accessed compared to pages in the system with similar access
> > 	frequencies.  In contrast to MADV_DONTNEED, the contents of the
> 
> you meant s@MADV_DONTNEED@MADV_FREE@ I suppose

Right, MADV_FREE is more proper because it's aging related.

> 
> > 	region are preserved.
> > 
> > It would be nice not to talk about reclaim at all since we're not
> > promising reclaim per se.

Your suggestion doesn't expose any implementation detail and could meet your
needs later. I'm okay. I will change it if others are not against of it.

Thanks, Dave.

