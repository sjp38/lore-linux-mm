Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82DB9C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 13:00:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 510EF2173B
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 13:00:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 510EF2173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E021D6B0007; Fri, 19 Jul 2019 09:00:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB3598E0003; Fri, 19 Jul 2019 09:00:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C534F8E0001; Fri, 19 Jul 2019 09:00:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CAB56B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 09:00:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so21974019ede.23
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 06:00:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FFJMkF8qMkBzkB9KeswyCpwfyqfgsQXc8+ux8h/6h5k=;
        b=bIEpsn7c0imVLZwwty5BVUP6gQiGuLn7Pvh3IE2p9pKcgoN8TP+zRQB8Fd4F4OyWmp
         A2gQ8IZXhZw2KqhkErCm8tTagmALAHP0SklDRo19/rKM7TXy6Ab8WbOzQpBdak3qmBIc
         9jPiqqtPBvneJTKAbJHF6TGtW2O2TcNKjB8/jL+Wz2xlxrOeccf+0n9vcucm+UvNtN+k
         OKArClG/atppNinRR/ClLxrT1o3a516PIm50doWuyqV79nPWjR2K02DBPHiTIngxZQQM
         JDRtUngilluBePcK8Ax55QXrjMBWASf0V8x5MFn4YWc6cV6rlvPBs9KyNjuw46paKzOE
         YQCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Gm-Message-State: APjAAAXzrDlLBWjjJpgwvB51+6cGN6sl3yDWMMSogbRaR/oObNdIh1Ez
	J/Uvobn54FWjyOE3npf0XmsNxGv2MWZ2lxEUxs5Z/njYgh4ROPuWUnEpBliKh5aa9FsiFN2Mh6j
	3NWHgsLj+a0mks7lKUm9IDM6sU1BZxHGsPwyuB9QrNUn6g6y9Dj3zVM/u5x+4Kw6rCg==
X-Received: by 2002:a50:a4ad:: with SMTP id w42mr45257067edb.230.1563541234135;
        Fri, 19 Jul 2019 06:00:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDwBH58rUYp+++e3exVJex++1XaeNeQd8WnO0Ssy7NwYMJarz71xbBM3gesZT51ZbUpkkg
X-Received: by 2002:a50:a4ad:: with SMTP id w42mr45256980edb.230.1563541233421;
        Fri, 19 Jul 2019 06:00:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563541233; cv=none;
        d=google.com; s=arc-20160816;
        b=GP1aDIOx5Dhto8DRNO8v9bWvfI22dcAs7INEiNy/iewCv9ScMaGvKrRmULwkE02j/7
         CjmbdXIuqu6pxHk4UOTgOH6fmuIosUnzm95Ngf4Bb2c5YudMCNTc1yFCshiDKAvP/jnA
         gfMPd8/2iz1fVl8Ei4k0IgIdWvmeY1iP5DWVqfjHkSB3Top/ZQFCjgFPG++jflyQW8Fc
         1Atau9GhTVUmCnVr7XY0JCStUGq7m7cylCScQ8EL4q0AiR+M3RXZMJJTZYfMPozm9hPf
         WxQpALZLyXxInbsS858Xia7m4T3R90GWNHk1s8tugycsaI0hRoU4+INsu2Qki3esgEN+
         UiUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FFJMkF8qMkBzkB9KeswyCpwfyqfgsQXc8+ux8h/6h5k=;
        b=ep8Y9YK0Bg0GzOUTlLu0fspJzxRajLtrl1ePJg7OIxSE/7q29G6nhjvMjW3e+TK3/D
         cRROMAjEgYf98l1G4WakrckVsPqKk3LwQyLZP2XmrZKpIHwd5UBcC1Wy597KcPNGgifW
         cWSse2YsKgoF062qV6xcxfBsatJ179bUXItsXK+Wf36w2YDph8i6OSg9ZMOOD9Crdoa3
         bOYavyH7+YjJACmIuixP/5RWo16WsvVgsBNrgSk8ibfg8wxG03rIM1HeyJfvmxnJDBKq
         xjuZr+Ueq+Z7dCjyvDRvPwLUtTipsRsir5AJSo7wDeGPGd5bAoK1NMa7BZNtYvevfT7/
         6zpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p5si91048ejf.233.2019.07.19.06.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 06:00:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C496EAF7A;
	Fri, 19 Jul 2019 13:00:32 +0000 (UTC)
Date: Fri, 19 Jul 2019 15:00:31 +0200
From: Joerg Roedel <jroedel@suse.de>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
Message-ID: <20190719130031.GE19068@suse.de>
References: <20190717071439.14261-1-joro@8bytes.org>
 <20190717071439.14261-4-joro@8bytes.org>
 <CALCETrXfCbajLhUixKNaMfFw91gzoQzt__faYLwyBqA3eAbQVA@mail.gmail.com>
 <20190718091745.GG13091@suse.de>
 <CALCETrXJYuHN872F74kVTuw4dYOc5saKqoUFbgJ5X0EuGEhXcA@mail.gmail.com>
 <20190719122111.GD19068@suse.de>
 <CALCETrUjATNr97ZWX41Tt3QyiMM+GSqG92Nn=qZTTG6XrvL8GQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUjATNr97ZWX41Tt3QyiMM+GSqG92Nn=qZTTG6XrvL8GQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 19, 2019 at 05:24:03AM -0700, Andy Lutomirski wrote:
> Could you move the vmalloc_sync_all() call to the lazy purge path,
> though?  If nothing else, it will cause it to be called fewer times
> under any given workload, and it looks like it could be rather slow on
> x86_32.

Okay, I move it to __purge_vmap_area_lazy(). That looks like the right
place.


Thanks,

	Joerg

