Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH,USER_AGENT_MUTT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5170C4321B
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 19:06:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 922BA20859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 19:06:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hZuAZErp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 922BA20859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 310C46B026A; Mon, 10 Jun 2019 15:06:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E6036B026B; Mon, 10 Jun 2019 15:06:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D5746B026C; Mon, 10 Jun 2019 15:06:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D7D186B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:06:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e16so7464436pga.4
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:06:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:in-reply-to:user-agent;
        bh=0BaPEIGD7mBtWI4uLegSfnEAAPWaksEmyNdNQPDEPes=;
        b=O+4GZISudamXKMdAs/w0I9KTBGSh/QD7yzWsjwxve7ZrJEMUzobBRa/Xpo4nXanLwE
         hCnERmcsuVdtuB350bJay9IJHWpZbpfMmpjWG1JpQKPRzFdI7TC0SI+mE9PL5RrshJFq
         ZVng90f4mkwQm0aMUFtoeJGrzAawqkabBVCb6MPIis9zf8+KIG9L417UGv50eSdiFhhc
         CclrGgAogDIWbHXVaVI0POA3y0TD8zPlF8h1xQ3GBSlVeRHOpTFfYLU2Ruu17rETj/DQ
         ZJUj+uv0iUm7hzWbCOqNjhHLM7DERRg85t+jSRrmrUPsVaxDLEq4Z2MLevH/CqX7k+Ei
         V3gA==
X-Gm-Message-State: APjAAAWWVLfTVdY51qxNjNLBrx9Mg8axQ1gHS3rwqJ2TRNLyGOr0fZK9
	xx9bidlc1jhqtcIr2r0PxAtXKdO29l7cHlgZNLMafkcuKQq2itVG6jEY6bfk0w36D2wxdz+q0PM
	QQmUJajjPpBbdgRfXaU7JK+B+Wreg22HiYu0GCJN6PiRDemihGr77NfqIeEhURvozEw==
X-Received: by 2002:a17:90a:dc86:: with SMTP id j6mr21495356pjv.141.1560193586522;
        Mon, 10 Jun 2019 12:06:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkk1erktbFqPa2GRD/yvK9Y/gpPhsMZ6Q6+g6mrhA8mWbcN/yL8qVBBopQieimzHorHIkk
X-Received: by 2002:a17:90a:dc86:: with SMTP id j6mr21495312pjv.141.1560193585783;
        Mon, 10 Jun 2019 12:06:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560193585; cv=none;
        d=google.com; s=arc-20160816;
        b=iABN2WD8nyqaPBbYtp3QU6fSozzGw+BJJMdpPegHsHBpMpx5dfBkjPwlYs8T6a+wr9
         +y58SRyVTPt3CuGQJceks2depCdyjPdTx3hdBM3q4SuMxF5+XkNr2k+ILCLhQyFsXas6
         Wvk8Uh/yBpC3FLAmcscV/38vJowOA9qEwbv4RiiNokej6KPAySIascJ/Xaxc6OTypX++
         JnbjnU9IREmejjlJoFg/AsfF6MKDkW2JQAQU0QFgh3SzC29NThrlf5dOsfj4iylEz4Gc
         +6bHNkAHsRqHh+lFVouipkWy2xvQAvRB2DcdTRY2tmooesBBzIdXCsF91g//kHx5e3rG
         t11A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=0BaPEIGD7mBtWI4uLegSfnEAAPWaksEmyNdNQPDEPes=;
        b=f8xaEYXgJLWA63nIQUZ1agI3jrTGp5eaMTlNzWfLGAnfjZV5K+YsdgCOkQ1ius9+AT
         d+dwEiF73Z5fDg3x3ys1l4P4PLZNOCx8+7VVKpZiSmrl7QU2rTBoUkULyQlT1+ggsa8d
         8R4HXSGM7rHZ6l34GKWO0g6Iwg3ajUXBczYRtUhxZq+70HzwcQ+4GylqggwhowwjRDDn
         KE3MS4k7nz08gJdslCwYL7bEjUG0T6sfPN3oyt5oz3AGf7x09m9rd64gEfUaSnU5hIZS
         6DypNK+sYQarUeZSu76kbtErfpKYtc9OYsIUsW4L3JWfLsVvWXGTujFkM7sckT5QX6LB
         MVSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hZuAZErp;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q42si223912pjc.103.2019.06.10.12.06.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 12:06:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hZuAZErp;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from gmail.com (unknown [104.132.1.77])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ED769207E0;
	Mon, 10 Jun 2019 19:06:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560193585;
	bh=raeylV3VoaIg61MFgkPBLaPp7VUmGTWBluotgx9RhnE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:From;
	b=hZuAZErpG5I85Y9L/RNGXXEDk5onpPpwOSJKSirowqjMIPKqJlD768Zm1eUWZgUE2
	 NYRdIIGy4ViqvgbSIQTIYlrH30SU2uh0YSp8ajgL+e9GXqvfrvrY4+tN8R6HoxVtmw
	 15Ksnd1IWZb+Hb+5+elM5sjb2UvKllviGdYxY6Ow=
Date: Mon, 10 Jun 2019 12:06:23 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Mimi Zohar <zohar@linux.ibm.com>
Cc: syzbot <syzbot+e1374b2ec8f6a25ab2e5@syzkaller.appspotmail.com>,
	akpm@linux-foundation.org, aneesh.kumar@linux.ibm.com,
	dan.j.williams@intel.com, ira.weiny@intel.com, jack@suse.cz,
	jhubbard@nvidia.com, jmorris@namei.org, keith.busch@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org, richard.weiyang@gmail.com,
	rppt@linux.ibm.com, serge@hallyn.com, sfr@canb.auug.org.au,
	syzkaller-bugs@googlegroups.com, willy@infradead.org
Subject: [IMA] Re: possible deadlock in get_user_pages_unlocked (2)
Message-ID: <20190610190622.GI63833@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000001d42b5058a895703@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 06:16:00PM -0700, syzbot wrote:
> syzbot has bisected this bug to:
> 
> commit 69d61f577d147b396be0991b2ac6f65057f7d445
> Author: Mimi Zohar <zohar@linux.ibm.com>
> Date:   Wed Apr 3 21:47:46 2019 +0000
> 
>     ima: verify mprotect change is consistent with mmap policy
> 
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=1055a2f2a00000
> start commit:   56b697c6 Add linux-next specific files for 20190604
> git tree:       linux-next
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=1255a2f2a00000
> console output: https://syzkaller.appspot.com/x/log.txt?x=1455a2f2a00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=4248d6bc70076f7d
> dashboard link: https://syzkaller.appspot.com/bug?extid=e1374b2ec8f6a25ab2e5
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=165757eea00000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10dd3e86a00000
> 
> Reported-by: syzbot+e1374b2ec8f6a25ab2e5@syzkaller.appspotmail.com
> Fixes: 69d61f577d14 ("ima: verify mprotect change is consistent with mmap
> policy")
> 
> For information about bisection process see: https://goo.gl/tpsmEJ#bisection
> 

Hi Mimi, it seems your change to call ima_file_mmap() from
security_file_mprotect() violates the locking order by taking i_rwsem while
mmap_sem is held.

- Eric

