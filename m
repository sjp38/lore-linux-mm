Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04004C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 07:24:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97044222B6
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 07:24:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oB/EkNRV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97044222B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D438A8E0002; Thu, 14 Feb 2019 02:24:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF4F28E0001; Thu, 14 Feb 2019 02:24:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBB108E0002; Thu, 14 Feb 2019 02:24:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 775C48E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:24:01 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so3661970plp.14
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 23:24:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=F1jQFRomg8z6bxckYaWujgYc61Y06VR9mkChwxkXyb4=;
        b=UP0HwfaJDSJjbzh6PqNSY7i+s1JunSWsHM/KHJqNXEhbYn2T0Rlquj1gyJFY6MWgVC
         ZuiSME5KaQgb+uKatjNA8aeOCB4Dyz6o4tzFxUDN/QmyHNtal515sD4GWO4mOzpLLsW9
         jcJKvA4byHUrieVvK1k/4sik84jWoEe3dPaAeUHPROs4sxKZJuK0uLc/agYL5HnyuCpo
         Plxm/4lvmbASWYn/FjqqhO0m8Zhp5NK/KJ01l3YdoaySrvGGO4tJrvyZxZx9O28kr2it
         Xy6x/kMxCtRz6A0rKkZJdxTYjUrTh5BtGnquQI7kwbYFt4jruFga11JNj+ssK7iGmUWX
         H/1A==
X-Gm-Message-State: AHQUAuY4/m6iD317/am2W2iTWEWP4BIsOyNr7weH3bo7UQbKMcXWeFCj
	PF159JW2SM5AG3ySwXJyGWkkXllWarq9Ii1bX7GS0MuBNkmkTdwDMxIwvcnd5LVCiPKf1waZkVF
	f9uGMhGZbeBuSLliLYQfAUer+W4wPdgYViyQ7Zf67h++bUXESLfihsjqTH7xIP2T638drXOZDQi
	K91nO6xTnr5B9MBmDcc3I6++zR+m3oox1Dlw8cOlpUCQyd/ABhGJILeYa4k33FlI5djjROEkOOw
	XbSr5mjCC6GAO7nutFbId/f+z2BzoB5DpaDyS+TUGLqvMc+2owXCoO3Go+d19evmYTYGCtuOMFz
	XdGu05aKTdCL9WnNUImvCQYN99ZWTH2pksivNgU15LZt6ZMWCI9klHoYtG77rvHqMYuDVlu0yQ=
	=
X-Received: by 2002:a63:d70e:: with SMTP id d14mr2417728pgg.159.1550129040988;
        Wed, 13 Feb 2019 23:24:00 -0800 (PST)
X-Received: by 2002:a63:d70e:: with SMTP id d14mr2417694pgg.159.1550129040242;
        Wed, 13 Feb 2019 23:24:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550129040; cv=none;
        d=google.com; s=arc-20160816;
        b=gD4Zx9MmxhOgPhwGUFuJ6IvUeUtNS6iq0BXKfkEvxS6MIO4AnIiZTPxoVZovsb+/OW
         LC6MvGvhYws2tLXYCdZnqseU6k3bKC866UWEERUCFlz89DhlZFutZmZ2O8ccwiFlgwSe
         4f8074qRbxMu0iaMKnTEHTt7JQZ7Byky+LJWqQbFOrKtH4hG0Q6YBn78IiKot3y2jXP0
         2gjGsP6k3CYaXmP2jCX7jZlnrORopN92gvuxEwmyueeraJcOehxy2yGnVVi45XcTDZCr
         HMKTkvuRchoARNDRYPCtVtO9qajTJB+i4AHrFQi+9vFKS8uWF8vnhLR1KyKuR7CwWmGN
         3q4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=F1jQFRomg8z6bxckYaWujgYc61Y06VR9mkChwxkXyb4=;
        b=OURyD7f2jXuhVNdNGQF3PYN9/UMzSBA8qqvjkF+CfKtBQ0KjuCApMrRjXsr/+IJE9D
         Jr4mAB4HYwFE0YsqkCFhgDBMEZ6c5JoFK6oQHxKqw7kofIcJnEMrD7DdOCBvuzYikIsJ
         g4zNcq1B4NNCmVqOePottaESeLb8OHLg/amwUW7X5Fh5ppsJAF/eWPPIpM2CxzfzpSbe
         EdGNOxvYApd3m3CNOLMXe5Ppc9RFL/c314DdOpN/NQzM+oLHKgW9gMc2TbjvNqLlOCJB
         mmX6Tm85XgW36nZIp8gkF2wM7ow3EIhSNh2UpYTKOrjYPwP/XH8WdUacOw6ZZRElcIoA
         Mx8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="oB/EkNRV";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j36sor2326437plb.30.2019.02.13.23.24.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 23:24:00 -0800 (PST)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="oB/EkNRV";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=F1jQFRomg8z6bxckYaWujgYc61Y06VR9mkChwxkXyb4=;
        b=oB/EkNRV7wtskWebNYJO0rEUXLmYt3qpmvoN41PBK6t8sKWqXx6jSW1VR4J1iLyGMP
         9CULoepcjufhlptggR7+90kbRVA0uAY8vPk62ZzURncg8h9d60MT9zDPFIVdRU02DYEU
         LppCmecyETZOBzG4Qa3jV739E4+1ChQRsnBTvXzPsnDAdg6DFchxDZAt6MAIQk3BqGXZ
         2DVXJcmz5sWbHLcQ9jVvOVpE0r+5eg0t0kp+p+oCK0uNimtznFIKbKskxXMoyCxF5j8h
         E9VJtJKSP1J4GcmL3wqMq1dueL5zsHdvcVnUjhYVSu2JFNbKA2zoMwhNq0kW0oNL9Vmc
         i0yA==
X-Google-Smtp-Source: AHgI3IZ5GAcPKn68oH218XOBZwhFpm72LeTU46aBVqGZ909TCPLgBRuWEr8G9dVaVamxXwJhFNUcdA==
X-Received: by 2002:a17:902:503:: with SMTP id 3mr2655060plf.233.1550129039481;
        Wed, 13 Feb 2019 23:23:59 -0800 (PST)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id g10sm1762487pgo.64.2019.02.13.23.23.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 23:23:57 -0800 (PST)
Date: Thu, 14 Feb 2019 16:23:52 +0900
From: Minchan Kim <minchan@kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>, Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix the pgtable leak
Message-ID: <20190214072352.GA15820@google.com>
References: <20190213112900.33963-1-minchan@kernel.org>
 <20190213133624.GB9460@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213133624.GB9460@kroah.com>
User-Agent: Mutt/1.10.1+60 (6df12dc1) (2018-08-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 02:36:24PM +0100, Greg KH wrote:
> On Wed, Feb 13, 2019 at 08:29:00PM +0900, Minchan Kim wrote:
> > [1] was backported to v4.9 stable tree but it introduces pgtable
> > memory leak because with fault retrial, preallocated pagetable
> > could be leaked in second iteration.
> > To fix the problem, this patch backport [2].
> > 
> > [1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback
> 
> This is really commit 63f3655f9501 ("mm, memcg: fix reclaim deadlock
> with writeback") which was in 4.9.152, 4.14.94, 4.19.16, and 4.20.3 as
> well as 5.0-rc2.

Since 4.10, we has [2] so it should be okay other (tree > 4.10)

> 
> > [2] b0b9b3df27d10, mm: stop leaking PageTables
> 
> This commit was in 4.10, so I am guessing that this really is just a
> backport of that commit?

Yub.

> 
> If so, it's not the full backport, why not take the whole thing?  Why
> only cherry-pick one chunk of it?  Why do we not need the other parts?

Because [2] actually aims for fixing [3] which was introduced at 4.10.
Since then, [1] relies on the chunk I sent. Thus we don't need other part
for 4.9.

[3] 953c66c2b22a ("mm: THP page cache support for ppc64")

Thanks.

