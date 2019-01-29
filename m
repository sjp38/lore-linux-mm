Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AB18C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 11:50:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A0802148E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 11:50:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="oOKT8xnv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A0802148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A64DA8E0002; Tue, 29 Jan 2019 06:50:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A13E88E0001; Tue, 29 Jan 2019 06:50:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92B1D8E0002; Tue, 29 Jan 2019 06:50:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3527B8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 06:50:07 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id t199so5746648wmd.3
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 03:50:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LCYrgx75yodWyZGmEPOpeqX5RHV1kjJgal/khS6fssg=;
        b=boO6zuUi6X+tbfj/870IkbXvfTT4dC/AOcRzMrp4eEeiZYN1imKYm04Ugdag4NlSxt
         JCG7bfguE5x5g5fbZeFwvBjHx6H8J2fDM7MvhrlwTe3nPvYXrYZTzwaDeT5HKf6Yemv1
         WQQ1HOlWtioH5NlffQvu6jqiQt8knUjCLercFDrsfPzf9ZAKAB07EPrn2i9TY29eyhX5
         7vxG5dJbfkEZBL0WJSrd9wCEsn4Sn6gSbOu5wWxU+Sg0aesbXxqNJGfPsYaRo3/SSYJ3
         CB9W3vZWbsgQLrXXtv6ssSfIoy/i4Vcff9SXqTrWBso+QAkU8EuhoiVAEecjr4vyE3AC
         Tz6w==
X-Gm-Message-State: AJcUukcU6K+terQjah7/J9Va3BLhqW6ms4g17ikRLF/CXMSDyoEH5ZPN
	ySEqF6HIT9BYQqn1GV1952JURnuUyOi9C348DjfgbsLnSejFlkHzq+Xj7YxpNzLNQCTLRQ9TU+P
	lyDuuBOGnFKb/jU+8N2x/X7WJKxwKvPcgtmrUH7KYHincIYktnFh85DDGA94YF64h9Q==
X-Received: by 2002:a5d:4202:: with SMTP id n2mr25434324wrq.260.1548762606512;
        Tue, 29 Jan 2019 03:50:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7bSbpCPByjcI8rGs/NZYM/IuVkks2e57GwYrKro/t2obOyxqKDeW0h30GvMwUNiCjf6RLg
X-Received: by 2002:a5d:4202:: with SMTP id n2mr25434262wrq.260.1548762605571;
        Tue, 29 Jan 2019 03:50:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548762605; cv=none;
        d=google.com; s=arc-20160816;
        b=KnFZPJRWO3UMhlVTTLUlKPfPvyn5PaQh+sYwQGU7TAfC5IXVdRgITaiTbu6LOJZR6X
         7keywprLEP8QzZ5E0Zi2blghdelutOYmC+fBCseZrcmnH1/5xLunDDUOkJbll6AuG9tL
         BzFG3+2hX4Ei7jTl6Ul94pzWIlyBd9vNfDdSjFlQGQ7cY+cmNH1jbF1Pe1pm952XEvUG
         Iieu6Uv7rrJdfY1tRHb7HoLZALxMTOufHGrw67fCALDtj6NcVLnWHmxbTt/hO0Gu6yjw
         b/0MNravRdDfMmatUXobLbHiZbkWYTEoDwpZp+qP6QZKtxRtC4MypIHIAPd4flito6x4
         tZTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LCYrgx75yodWyZGmEPOpeqX5RHV1kjJgal/khS6fssg=;
        b=n3ZbTgzbnIGhleriwlQTrOfPD40oadN5A6fmaocimz3Xt5o9bzuDZeoSw9qHESpFox
         y0qkUehK41zLPL2wtqK8sNEggGHClB9UYfVQlUxTDQVAKpMQ73Pp0kyH7xz3Rog4LctM
         c3KA9r9VOX7Q6wLa/wbPFO2fQ1ndxCRAml+6xKo+PUHNpiUf3j/XDmrrWKAH5Da0YtGU
         5tMimbjp1qHxGsORxG06DWkjtwRl2JfCoeTPzt3njKhG0B6ZBWp9Wlxgy4okonbJRK1/
         Yb6VwuZ+GmyK/P2pjG9Ns0yuQZ/JwhD9vBdikve0AmCiY+LCLQgePSuIZl2CI2XiYBCM
         mdfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=oOKT8xnv;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id 78si1752452wme.56.2019.01.29.03.50.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 03:50:05 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=oOKT8xnv;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCC5400A93DC78EB3841B4D.dip0.t-ipconnect.de [IPv6:2003:ec:2bcc:5400:a93d:c78e:b384:1b4d])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 729541EC0573;
	Tue, 29 Jan 2019 12:50:04 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1548762604;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=LCYrgx75yodWyZGmEPOpeqX5RHV1kjJgal/khS6fssg=;
	b=oOKT8xnvwyl/iMtxbVhzpSstiZI7BSD6aEqdH4UwzCWdmTm7tNTs91fJWT1uE48qnARN/S
	9iAhuef5li3aXBvKyFR1DRuIecWmJuweZgmLDNDGGaPvsTSpuDSR/zKPUkPN8veu5SFWld
	ANDiqurv7CQ7J5GcL13qPob/ohl4/Hw=
Date: Tue, 29 Jan 2019 12:49:52 +0100
From: Borislav Petkov <bp@alien8.de>
To: James Morse <james.morse@arm.com>
Cc: Tyler Baicar <baicar.tyler@gmail.com>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	kvmarm@lists.cs.columbia.edu,
	arm-mail-list <linux-arm-kernel@lists.infradead.org>,
	linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
Message-ID: <20190129114952.GA30613@zn.tnic>
References: <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic>
 <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com>
 <20190111120322.GD4729@zn.tnic>
 <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
 <20190111174532.GI4729@zn.tnic>
 <32025682-f85a-58ef-7386-7ee23296b944@arm.com>
 <20190111195800.GA11723@zn.tnic>
 <18138b57-51ba-c99c-5b8d-b263fb964714@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <18138b57-51ba-c99c-5b8d-b263fb964714@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2019 at 06:36:38PM +0000, James Morse wrote:
> Do you consider ENOENT an error? We don't ack in that case as the
> memory wasn't in use.

So let's see:

        if (!*buf_paddr)
                return -ENOENT;

can happen when apei_read() has returned 0 but it has managed to do

	*val = 0;

Now, that function returns error values which we should be checking
but we're checking the buf_paddr pointed to value for being 0. Are
we fearing that even if acpi_os_read_memory() or acpi_os_read_port()
succeed, *buf_paddr could still be 0 ?

Because if not, we should be checking whether rc == -EINVAL and then
convert it to -ENOENT.

But ghes_read_estatus() handles the error case first *and* *then* checks
buf_paddr too, to make really really sure we won't be reading from
address 0.

> For the other cases its because the records are bogus, but we still
> unconditionally tell firmware we're done with them.

... to free the memory, yes, ok.

> >> I think it is. 18.3.2.8 of ACPI v6.2 (search for Generic Hardware Error Source
> >> version 2", then below the table):
> >> * OSPM detects error (via interrupt/exception or polling the block status)
> >> * OSPM copies the error status block
> >> * OSPM clears the block status field of the error status block
> >> * OSPM acknowledges the error via Read Ack register
> >>
> >> The ENOENT case is excluded by 'polling the block status'.
> > 
> > Ok, so we signal the absence of an error record with ENOENT.
> > 
> >         if (!buf_paddr)
> >                 return -ENOENT;
> > 
> > Can that even happen?
> 
> Yes, for NOTIFY_POLLED its the norm. For the IRQ flavours that walk a list of
> GHES, all but one of them will return ENOENT.

Lemme get this straight: when we do

	apei_read(&buf_paddr, &g->error_status_address);

in the polled case, buf_paddr can be 0?

> We could try it and see. It depends if firmware shares ack locations between
> multiple GHES. We could ack an empty GHES, and it removes the records of one we
> haven't looked at yet.

Yeah, OTOH, we shouldn't be pushing our luck here, I guess.

So let's sum up: we'll ack the GHES error in all but the -ENOENT cases
in order to free the memory occupied by the error record.

The slightly "pathological" -ENOENT case is I guess how the fw behaves
when it is being polled and also for broken firmware which could report
a 0 buf_paddr.

Btw, that last thing I'm assuming because

  d334a49113a4 ("ACPI, APEI, Generic Hardware Error Source memory error support")

doesn't say what that check was needed for.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

