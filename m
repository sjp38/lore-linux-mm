Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59837C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 19:08:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1412A2175B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 19:08:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="f0bxWTQT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1412A2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A91CF8E0093; Tue,  5 Feb 2019 14:08:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A40E48E001C; Tue,  5 Feb 2019 14:08:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 957788E0093; Tue,  5 Feb 2019 14:08:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 569B28E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 14:08:46 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so3246642pfb.17
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 11:08:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=vjqluM4IrcpZa+q+Npo42GgZ7IxMR3vEfRcF7cBdbjU=;
        b=HFhGzTsHall1pDiyWxvOYhTRiFy9VJxIV+o6fqWm4ZEZRvZWI8emiAizOs+FW/C31P
         YaEL0x19VFhRC9P7Bj0yqfFemFPvEG090rfuSt/H1hgmKQGkUfvzWPu4ddYxH5QHcDF3
         PSDtSKT4jegTcR81JpwcrYoKzujghHNeBvllZh0nURrWNZZ87DfmAaR0TN8iU3uKOJCg
         zi4l0sTVARLhTt+3NMBdQ4heTNXnkHXBkXuE56I3VlG/WPqFa0OlT2o3I0aGWkUYOwqP
         IspEo1EIMlkPwdW2gOFCtqNaiHllh127cWGSeMNkk1Z9pdK5/4ksM83uWqipYAoT0Jdv
         Obmg==
X-Gm-Message-State: AHQUAubNpLL3htopRrCUkz2r2xfkxK5vw+EXJpmdSPK+mU2eJ4ojyYrv
	8IjvkIZhV6IsWyUNVxfoQ8XKf+Tfqu/PXq6zNrAc5hhlfA79pf0rn3tqsSv3raOwLMlMGUgBpkM
	DSI0bAYksN7/Izzbgxya1LuVzzXHNYbzsgLsgp/KLWzj/W8qKoQ++pV7nXvuarH3l5FiEcB68zm
	Cq5LPrNmNT0qh2/ayVeuQJrlQgYP1JRD4EDo++oHa8EsOALCFQ1RwfzLfEkh+qPyge7/QaDzABH
	NqdJR3hSh436/eYda9oUcWx/alE4n3aUQINyP+SxPmWtQZKfEAunwO9PAio7KtCSnqVAruyz3Fn
	J/Nk66vku10QK2I66S5NsekATUQlWW2iWl/pPB+ufnl5BJ56k5LWBXD6ahd0+Phg/ns/IH3SG+v
	N
X-Received: by 2002:a17:902:584:: with SMTP id f4mr6817038plf.28.1549393726041;
        Tue, 05 Feb 2019 11:08:46 -0800 (PST)
X-Received: by 2002:a17:902:584:: with SMTP id f4mr6816999plf.28.1549393725464;
        Tue, 05 Feb 2019 11:08:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549393725; cv=none;
        d=google.com; s=arc-20160816;
        b=EFHCITVlG7PO/PnQIGEjs/PCOOdOfhOohcSm3S2lVgVn8/ebNKUaNusO3UWaSrmMGZ
         2/A5zd46ozTKELLW/Oi25VRsEXLqHl9vaRkR+wgfg2oQ4rpvkG7M+TIj4BdVMdnp9kmR
         hXrf5sCpwZC1H6iu6Lhrd80WEx7aue8TDDzzgfx4ymtyRecmpPCtGUe1pmeb9l8RRh9z
         x+W5Bw8bPae4LniDF1qAddVneEWspuf7oM4gPFLhJsUHm9n1UklD+h/atCKHAGpmkt4y
         IIGqXzD3sKtkcaN1NcH4QnUeoiTOED2jBs6/jL3/AOyGLUeMRLRdSuZ5PGvViP+ezSk/
         cRww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=vjqluM4IrcpZa+q+Npo42GgZ7IxMR3vEfRcF7cBdbjU=;
        b=WYsUZOmkzX60Z4wWiJ7eUNdXfZbP9e2M/38ZYrontcMNbDBYqwRp2u2g/GWVnDZz/4
         bnbKz8muI/AT7wqqn1hjQWjfKkncm+y34HF5Rj75bI/z56m9b1W/I88riO6BHTGc8mWI
         qDAlbAtBot8Tq3VeQfGQtmeiri6B5ogY5JFJwV9r62QFTSwT+QRQwj28YjLsqNJAWO/6
         5fZWzpRN1qWBvaql4MCOBN/hdqkIcozBlgi7pJJh+420g4B/Q9Wk74HK05AQZdTgCgb9
         7zo2Fu6pd4jU2vt9lnabtnKhlRQw973IS5KMalE1nEY9qoj6UBekLmY3ocHBXXpK8JWQ
         yuNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=f0bxWTQT;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m4sor5467701pgp.34.2019.02.05.11.08.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 11:08:45 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=f0bxWTQT;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=vjqluM4IrcpZa+q+Npo42GgZ7IxMR3vEfRcF7cBdbjU=;
        b=f0bxWTQT7EVvTcCkR8C/MZnEMbdiyx4JNyXdcvQ4qGnWMBNyJQUIpuFf8w6j/Te/Hf
         R3q2hbIpL85MjpXxh+syAzX60X9ef9IlJ+0IBJWZS1+92p0t0m2ISZz134UNj+W6gVw6
         +3rVBGhyyBH1RWuucZLHV6YK+O2/8D1iTVbnbbE96Jz5RSc37XdiiVzyp5zWF+egTQoW
         RVipdb2hoX/g/lodZQcHsIeGRzy8vPY3QdnD/pKqF9L03UBeLkbEOGfM4pckrh2Z8iIP
         KHkVphcwjNFr17wbzwQuN5+fb8/atcfqF8VsETvehNxe7ftj1bMH5H5e1Ev64YkmC5hP
         tt+A==
X-Google-Smtp-Source: AHgI3IYlzM4wG9zZ+epMUVDVb0A4n+P6MdANnIifvYKKVJuL6PTOHmt3VfEfQblMkweXkg5PgG0bZg==
X-Received: by 2002:a63:df13:: with SMTP id u19mr1150197pgg.294.1549393724655;
        Tue, 05 Feb 2019 11:08:44 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id i72sm5462182pfe.181.2019.02.05.11.08.43
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Feb 2019 11:08:43 -0800 (PST)
Date: Tue, 5 Feb 2019 11:08:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Qian Cai <cai@lca.pw>
cc: Artem Savkov <asavkov@redhat.com>, Baoquan He <bhe@redhat.com>, 
    Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, 
    Andrea Arcangeli <aarcange@redhat.com>, torvalds@linux-foundation.org, 
    vbabka@suse.cz, akpm@linux-foundation.org, Linux-MM <linux-mm@kvack.org>
Subject: Re: BUG() due to "mm: put_and_wait_on_page_locked() while page is
 migrated"
In-Reply-To: <5bf18231-4039-10ad-4d2b-cac856a998c3@lca.pw>
Message-ID: <alpine.LSU.2.11.1902051103300.9007@eggly.anvils>
References: <f87ecfb2-64d3-23d4-54d7-a8ac37733206@lca.pw> <20190123093002.GP4087@dhcp22.suse.cz> <alpine.LSU.2.11.1901241909180.2158@eggly.anvils> <921c752d-8806-b9b5-8bb6-d570a3fec33d@lca.pw> <20190125085156.GH3560@dhcp22.suse.cz>
 <5bf18231-4039-10ad-4d2b-cac856a998c3@lca.pw>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jan 2019, Qian Cai wrote:
> On 1/25/19 3:51 AM, Michal Hocko wrote:
> > On Thu 24-01-19 23:31:46, Qian Cai wrote:
> > [...]
> >> It looks like the put_and_wait commit just make the bug easier to reproduce, as
> >> it has finally been able to reproduce it (via a different path) after 50+ runs
> >> of migrate_pages03 on one of the affected machines even with the commit reverted.
> > 
> > OK, great. This makes it a little bit less of a head scratcher then.
> > Could you confirm whether this is FS specific please? I will go and
> > check the migration path. Maybe we doing something wrong there but it
> > would be definitely good to know whether the underlying fs is really
> > relevant. Thanks!
> > 
> 
> So, I reinstalled everything using an ext4 rootfs, and then it becomes
> impossible to reproduce it anymore...

Just to wrap up this thread: Artem Savkov has identified 5.0-rc5 commit
8e47a457321c "iomap: get/put the page in iomap_page_create/release()"
as fixing this issue on xfs (iomap), and Cai verified, in other thread
https://marc.info/?l=linux-kernel&m=154927160417473&w=2

