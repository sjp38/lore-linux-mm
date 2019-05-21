Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BCAEC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:24:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6872217D7
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:24:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P6sVSJ8V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6872217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C94E6B0003; Tue, 21 May 2019 07:24:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 552466B0005; Tue, 21 May 2019 07:24:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CBFD6B0006; Tue, 21 May 2019 07:24:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01B6E6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 07:24:31 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g11so11234105plb.3
        for <linux-mm@kvack.org>; Tue, 21 May 2019 04:24:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=19lOUlmB0BXO2qy5+86EiFCLj8kI8GOhTNcbKNP7IO4=;
        b=Eylo+kR3Crv7VkY9Hlukc6zzC4DPo4AIfRXGOPqyMjUQXOWQf8/YRAD1TW8aydSF0+
         0UbBJxn4pQMgsoUkRnLTyADPfAEytI86G8XNPXVy+ynAwKjKr7EZeVWPjZl++Lfn2xag
         enbRbU5H+tiMXdgiYT6PFGW9177/GR7KLTO3ogvOfw0WvGHGtWNM5c2HW0WDNqqme9Ye
         Z1klJ43tL+Sy4j2lwsHk/V2uE+qn0Mrc+ouXcXUhMQ6OgtppwEeH8wsmsttjbwyXVvLG
         sPyNEvdb5ey9kuk5UiKNIEBuNrQlo91mAPDm7+znzwFRcNeQqpC3BzeTT6aKdqXIxVDD
         nVcg==
X-Gm-Message-State: APjAAAXj4YsrKVRggrSB+JYtbrr0xuuJmE0uGxd+bqKkYlAW8EqHZoU/
	FHhKx/i0S5vECkcp34OMZkXA4buSbr7HwzxmuIqxJ5CszqUEduOPFuOdu4Spoe08UlCPmGs5/BZ
	YNianC0vofidAq0ogpKFEdiByVfBLUUO+TpEo73QCyTyOuzb7knAu96pD2UUpvLg=
X-Received: by 2002:aa7:87c3:: with SMTP id i3mr84803156pfo.85.1558437870663;
        Tue, 21 May 2019 04:24:30 -0700 (PDT)
X-Received: by 2002:aa7:87c3:: with SMTP id i3mr84803114pfo.85.1558437869942;
        Tue, 21 May 2019 04:24:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558437869; cv=none;
        d=google.com; s=arc-20160816;
        b=fPrvwO72mYJdcUTh6WW/pSbN1sYW0xPhtiheiNTrnWYEaN+iDeuwgo4pbzwE120w5C
         fv2or74WsXAL61zaY4levPYh2vM4+TMvMPaoHQRVHMJx3qMA0TtDNiPCIA2u0BNdGVPk
         E5SaxWc1cqjb2I8GQp6N6iZLJUOjVVTVpMXRa/hDvMIuc8iySCh7ZpQHcFNCNrlG5o63
         vXwohG39R5fIaE/Ez5/k8Wpdq0hhST5QuzEavfXkubtQamxQXPhBtOilmAvWw7kM0X1h
         6ds+NFxeEv8S/hp9WYZ9ENpPhGBXxoic0gQ7n31tXTGKB5WBNIdnnNmqe+c8dDYo0oop
         7I4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=19lOUlmB0BXO2qy5+86EiFCLj8kI8GOhTNcbKNP7IO4=;
        b=Dbr+FLIQNYKToBWMn31qevQGL0TlT8toG7X3pDsdZU3qqcElNy00V7JskfSpvaXhI9
         20geGjryGQVrKa/hr3hAM4ays5csAAzAHXBpMPjICckVireQVPvOLdh+1V8tMDuXnqbw
         8S30Lz5GA3Dicw0ZieTA10OuXhGQv7aygJAmoK8WhFhFUP9Ixa9qZqjFteoNA6YYM9lT
         J3c1I8Ud4H6/6bCDjDbTnQXouKsuZZRfNc2FUaFPDh4lyeCCLgzNhcoXXqbuH/ln7fvZ
         AfgA5QId6n2Y04wJaKc7W+pzgDa0/BnDUDnn42PVy6qwlG3YMlC+tZ8kmzxSOnAJxDv6
         kIrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P6sVSJ8V;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z134sor20299666pgz.86.2019.05.21.04.24.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 04:24:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P6sVSJ8V;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=19lOUlmB0BXO2qy5+86EiFCLj8kI8GOhTNcbKNP7IO4=;
        b=P6sVSJ8VYNp1+Lx4Dxzurk25CX9vkVoXH08GrauyQziSWr+fupC7M+k6u4UTyrGsbY
         jBDI1AiX+THg04/RNegnkFskFWc2Hde+r/6tC2DP+zcvIs4X2lQyrOQ2m6quf3I3IrDK
         7n5vzbRA0a6/LqCBIQsIMR/vnOEKPgxN7hl3hjGnf6LP0JrsutNyi9WSvdtj+Jw6mZQG
         MwxVmfse/1ttaoz24+lxlrWvFBtGZK+tuT51jRdv/4s+Uwa881cOKdhgis/0g1V47XZI
         RbKI0PyKuB5zZ1JKkzFhG9SfJxo2OfzwDIt009bJF5uw3P2FiSKwodIxOuirOUnvDbcO
         A2aw==
X-Google-Smtp-Source: APXvYqzO8k/cpniPZ4As3COPVMn1h85852mwAsWD2KOvHeEb0TcpcFBsTAgm3gjNSBmuXcimHbfaBA==
X-Received: by 2002:a63:1657:: with SMTP id 23mr30125895pgw.98.1558437869394;
        Tue, 21 May 2019 04:24:29 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id k13sm17361700pgr.90.2019.05.21.04.24.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 04:24:28 -0700 (PDT)
Date: Tue, 21 May 2019 20:24:23 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleksandr Natalenko <oleksandr@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 4/7] mm: factor out madvise's core functionality
Message-ID: <20190521112423.GH219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
 <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
 <20190521012649.GE10039@google.com>
 <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
 <20190521065000.GH32329@dhcp22.suse.cz>
 <20190521070638.yhn3w4lpohwcqbl3@butterfly.localdomain>
 <20190521105256.GF219653@google.com>
 <20190521110030.GR32329@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521110030.GR32329@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:00:30PM +0200, Michal Hocko wrote:
> On Tue 21-05-19 19:52:56, Minchan Kim wrote:
> > On Tue, May 21, 2019 at 09:06:38AM +0200, Oleksandr Natalenko wrote:
> > > Hi.
> > > 
> > > On Tue, May 21, 2019 at 08:50:00AM +0200, Michal Hocko wrote:
> > > > On Tue 21-05-19 08:36:28, Oleksandr Natalenko wrote:
> > > > [...]
> > > > > Regarding restricting the hints, I'm definitely interested in having
> > > > > remote MADV_MERGEABLE/MADV_UNMERGEABLE. But, OTOH, doing it via remote
> > > > > madvise() introduces another issue with traversing remote VMAs reliably.
> > > > > IIUC, one can do this via userspace by parsing [s]maps file only, which
> > > > > is not very consistent, and once some range is parsed, and then it is
> > > > > immediately gone, a wrong hint will be sent.
> > > > > 
> > > > > Isn't this a problem we should worry about?
> > > > 
> > > > See http://lkml.kernel.org/r/20190520091829.GY6836@dhcp22.suse.cz
> > > 
> > > Oh, thanks for the pointer.
> > > 
> > > Indeed, for my specific task with remote KSM I'd go with map_files
> > > instead. This doesn't solve the task completely in case of traversal
> > > through all the VMAs in one pass, but makes it easier comparing to a
> > > remote syscall.
> > 
> > I'm wondering how map_files can solve your concern exactly if you have
> > a concern about the race of vma unmap/remap even there are anonymous
> > vma which map_files doesn't support.
> 
> See http://lkml.kernel.org/r/20190521105503.GQ32329@dhcp22.suse.cz

Question is how it works for anonymous vma which don't have backing
file.

> 
> -- 
> Michal Hocko
> SUSE Labs

