Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECC6EC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 07:19:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D95C208CB
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 07:19:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="fyBYqmEq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D95C208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 389846B0007; Thu, 20 Jun 2019 03:19:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33C8A8E0002; Thu, 20 Jun 2019 03:19:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 229CD8E0001; Thu, 20 Jun 2019 03:19:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E092F6B0007
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:19:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z10so1180517pgf.15
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 00:19:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wAqewpyLg9wyfyO+W4xMU0VSpAQed917bo3KrM2+hhA=;
        b=V9+KeR0NwhhxwqV6E/r1rzkzAw/b2P2vwkpVjTY9+S8nkJaEgTGo72zncg4Sn0qOwO
         3BjdFqxipRl8lZtBf9mdk7QAN3JzjHdka7VlOi9HNMVy2+SLsArRqCQyk/QnGKraQbZJ
         bNeGkTQJgoCDNsPPRE6fJz/keaKjDiuGblMI/ci24jYXJ5UxvuEv0jcYYAhezLMJ79qh
         S7EcbDBk+WY3MB8M0HIjzJ8l843I2t5ODvwyEHZrlhJHZhbCmJtZZVdBDrQmtcxIDHlH
         eUZv3DlGxFpqUJ9Wuv8wLZsz9TjCeUCQkVLdS51NfQeK9b16dbAB6n3nIcPE906j/+qq
         Ylzg==
X-Gm-Message-State: APjAAAW4k+gSK8nA+E5G8p1h8prKo+uZzAv9jqOYZjS/loOjINJ/uT93
	Y49QqvX1ZerK3V2mqYfs5w7Hx9zVPvb5jHlCIYprX+3C/p8THft7is91R51N274ju8Jg90WBYPm
	MWcHDb4IyuZjXy1OHyItBpWpNpu6qZCyT0g2bqusBYQ9ddgC8QBLfQSDFW5KDwu4vFw==
X-Received: by 2002:aa7:9117:: with SMTP id 23mr1524326pfh.206.1561015161457;
        Thu, 20 Jun 2019 00:19:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYdlYVSxI/RD+d9tjS+VAbeycgrTO1ReH/hY/tYZd5ld2eKL0smzk8NnNCFtv9txv5UfgX
X-Received: by 2002:aa7:9117:: with SMTP id 23mr1524289pfh.206.1561015160787;
        Thu, 20 Jun 2019 00:19:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561015160; cv=none;
        d=google.com; s=arc-20160816;
        b=wLk6/gceBVZc8NThWy910R3oGombeDYIaVznu877a2au0teAWHvvSH86xQ9dDUXJEC
         MR7YsDbQsJC0YScVdvldG/kfz2q5iHej8QJsGtSPm+31Aym8BicezWzvWDjZUU1zS4gU
         jdxjIDzT3r3C9B+SQv88Uc0q1T4ThMmd3pOkCtFb2OPz0GvA/PBxf+t8rDzy6E+YaZTz
         AU5M58mjvsVTAil4qcm/0YERHM+nIzZzMMF+gl/vY6WI/cpt+FEXDW83cnaQe5EvTWIh
         Rm1P1zKUCVfTXNCkY7YMBv636Dut14vFzFuxYtxLYVCIKbXa7I8Ts1efNzPNjpC6H9Mi
         M5oA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wAqewpyLg9wyfyO+W4xMU0VSpAQed917bo3KrM2+hhA=;
        b=SziD7712pzykI0QG7TqtaY6fpBpoHwhmC9k380qT8SVngZ2ZLN2z6ZGunjsgz11+IL
         /no8waTcMhIiy9l+1UtRc/RQpzZZ/qhyFBwctMpRQ23MBN7F9XDsSCVHJRjYXF2Ubhto
         5LQ930188VkCcjuOYUr1O3Hb2uaHcNlT4gpCGssaHILAAn7CAfsrn6V7jZyW+P2sqDiI
         N2b9Eu0suaNl97Z1mozcbVEJ7FLuyjMFQQut+/Ja7Yag9RHacSS7gt7nppx3OhaNQAWF
         qfhUGBLWk3ZA6Db35P4wuN20borWqDgdz5GeGowjoBBXIrdJ3UDLbgHECA4pvrKKqH31
         PmAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fyBYqmEq;
       spf=pass (google.com: domain of mhiramat@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=mhiramat@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d5si5031377pgc.596.2019.06.20.00.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 00:19:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhiramat@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fyBYqmEq;
       spf=pass (google.com: domain of mhiramat@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=mhiramat@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from devnote2 (113x40x119x170.ap113.ftth.ucom.ne.jp [113.40.119.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 81DA02084A;
	Thu, 20 Jun 2019 07:19:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561015160;
	bh=ditT581I77m/ZbUu7CLuX7DQIEDwZUnG/8oeauPi0io=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=fyBYqmEqZeklNLUnmdmPM/4625Mcbao07QGNIYQw5knhEZK8wIHjcm8xUL4RmnX0r
	 PMnegxpi1BIQAjhCwgTuEYSEaa/KbTsng4M1dGIJ9/yq3pToiPLhZ1loMNuNQ0OZTt
	 fyFz0fNafXWDnlMWBNAdXCvQrux1gSBdpWnS1k4c=
Date: Thu, 20 Jun 2019 16:19:17 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Eugeniy Paltsev
 <Eugeniy.Paltsev@synopsys.com>, Anshuman Khandual
 <anshuman.khandual@arm.com>, Fenghua Yu <fenghua.yu@intel.com>, arcml
 <linux-snps-arc@lists.infradead.org>, "Masami Hiramatsu"
 <mhiramat@kernel.org>
Subject: Re: [PATCH] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
Message-Id: <20190620161917.a713ea0ff38fa18a2c6f05c2@kernel.org>
In-Reply-To: <8b184218-6880-204e-a9dd-e627c5ca92ca@synopsys.com>
References: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
	<e5f45089-c3aa-4d78-2c8d-ed22f863d9ee@synopsys.com>
	<8b184218-6880-204e-a9dd-e627c5ca92ca@synopsys.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000011, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 18 Jun 2019 08:56:33 -0700
Vineet Gupta <Vineet.Gupta1@synopsys.com> wrote:

> +CC Masami San, Eugeniy
> 
> On 6/13/19 10:57 AM, Vineet Gupta wrote:
> 
> 
> > On 6/13/19 3:07 AM, Anshuman Khandual wrote:
> >> Questions:
> >>
> >> AFAICT there is no equivalent of erstwhile notify_page_fault() during page
> >> fault handling in arc and mips archs which can call this generic function.
> >> Please let me know if that is not the case.
> > 
> > For ARC do_page_fault() is entered for MMU exceptions (TLB Miss, access violations
> > r/w/x etc). kprobes uses a combination of UNIMP_S and TRAP_S instructions which
> > don't funnel into do_page_fault().
> > 
> > UINMP_S leads to
> > 
> > instr_service
> >    do_insterror_or_kprobe
> >       notify_die(DIE_IERR)
> >          kprobe_exceptions_notify
> >             arc_kprobe_handler
> > 
> > 
> > TRAP_S 2 leads to
> > 
> > EV_Trap
> >    do_non_swi_trap
> >       trap_is_kprobe
> >          notify_die(DIE_TRAP)
> >             kprobe_exceptions_notify
> >                arc_post_kprobe_handler
> > 
> > But indeed we are *not* calling into kprobe_fault_handler() - from eithet of those
> > paths and not sure if the existing arc*_kprobe_handler() combination does the
> > equivalent in tandem.

Interesting, it seems that the kprobe_fault_handler() has never been called.
Anyway, it is used for handling a page fault in kprobe's user handler or single
stepping. And a page fault in user handler will not hard to fix up. Only a hard
case is a page fault in single stepping. If ARC's kprobes using single-stepping
on copied buffer, it may crashes kernel, since fixup code can not find correct
address without kprobe_fault_handler.

Thank you,

> 
> @Eugeniy can you please investigate this - do we have krpobes bit rot in ARC port.
> 
> -Vineet
> 
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>

