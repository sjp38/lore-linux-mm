Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7393C31E5E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:56:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65C90213F2
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:56:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="gLp1WFIl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65C90213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 124ED8E0003; Tue, 18 Jun 2019 11:56:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D55E8E0001; Tue, 18 Jun 2019 11:56:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F06238E0003; Tue, 18 Jun 2019 11:56:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBB148E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:56:45 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id r7so8043010plo.6
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:56:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=D/2EhQrOmt2zSW9N+N/JSZvTbs3LkJk+GqsLjvTelPo=;
        b=rcY6u79YU9gKPZut83Hz9Yj24n8D3jgzP19AVvQNsoLZXOmnXDHZd8IsZKUJonNeGw
         U8qZfWO01jDaV92+l8hC2cLwb22me4NQqY7CzytJdfhaLXY0vYpH54NwwKr/BJ7VHu06
         CbO+FcdTO2F3Ad5OQ7AVYubbL81ROnSQBCebIBGWDAsfhiTPYzW4dohZAY0aFO8Jb6E8
         8zseLjDN2GXN8Jd6sOMIQqJXp50KA5v7mp9tk113+tVV6f58ZWuxVV9KHlmTHc3AafP1
         BC5jVfoU2bhvK3WYkeoXfAF5MtIQf1ovy+9ooJO/khCwaH42LT669C5dRBkDowMt4DO8
         JRrg==
X-Gm-Message-State: APjAAAUyRiILdwSGwtfye80xqxXtlKciL23E/iwHe74WL6/KtdegxoRo
	T86Bn63HInJtUtQAcibKH646X9RVQANlzxg83sBe4kClvgO/7zNEV3S7WsWT8/ToZMKOeeDvQZx
	NTgK1wJgOsWclo6xTQ7cvNwclLQTF4fumTKsQWuz1wacl4BcWiyayZB45XQpzZWsxbw==
X-Received: by 2002:a62:82c2:: with SMTP id w185mr101316298pfd.202.1560873405402;
        Tue, 18 Jun 2019 08:56:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvtwvBQc5l1x+/JuH7a2GpYR5yGavkhbiIcMp8bMZpvxWLAcGd8mQjkMHvQ5K5hs98uFVw
X-Received: by 2002:a62:82c2:: with SMTP id w185mr101316243pfd.202.1560873404776;
        Tue, 18 Jun 2019 08:56:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560873404; cv=none;
        d=google.com; s=arc-20160816;
        b=VueEvQwxExGSH8goeiv0Fy+Nh3kSavO7GGsDQCfHNgoX4xysooyDO80HSrYW/yybpq
         icnnO59MjGIKBS2ib4GQJJSnutS8JdqhiHIfjBTTlL+ztbG4YEGXEh/CeH58GfZKB92f
         Pj74lNuPlzEmM7i2GdALBWSZm8JDtzkn7doLg8gqdpCptRb5l/fUhcsDklLzkMmkVLo7
         jchp0FUkLsEMA29nqpKGpsxviPnALNvA+3PJQiG/h4/mJHqbDPkPgdWvlSW+PPW++VBo
         8jLFiI0bAlLxnSjV7dvTWNrN8EZN7vUe9xgKtIE+Q9ol/ph9o9stwt9JpqOTTfSoYPDa
         XaXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=D/2EhQrOmt2zSW9N+N/JSZvTbs3LkJk+GqsLjvTelPo=;
        b=Z4ObxawpS+EGa/MbDmlOPBW/m1+ABGTo/f7fiGR+TL2WL3oa5v5MgJ/nI9P/1JB/pA
         bKEK5sZEVYVQbb3MshlMdqxjn0LygxLeAIwkYJer82oQ8ZPeFxGtdby6PRd+WJEGErT+
         wB5rf31w3uMEHkB6e6zP6CdRmgZAic5Y+JI3RZrZbmtsWbOFGD2PJaeNuTOfJUq7+Vzq
         ZZIR7sCtHcmGk3ejdGdIExFs+0l9mz3NOioCjymHfxZTFabCBSZ2I5gPal62QVVf/0r1
         30QawhOCz6pIsrIf14tz31XGZAP1PF1H5nbdn08yPD5XKsqqqNquk8Wu37oNf4YEKP22
         rzvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=gLp1WFIl;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.102 as permitted sender) smtp.mailfrom=Vineet.Gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay-out1.synopsys.com (dc8-smtprelay2.synopsys.com. [198.182.47.102])
        by mx.google.com with ESMTPS id q7si504317pgp.245.2019.06.18.08.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 08:56:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.102 as permitted sender) client-ip=198.182.47.102;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=gLp1WFIl;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.102 as permitted sender) smtp.mailfrom=Vineet.Gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (badc-mailhost2.synopsys.com [10.192.0.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay-out1.synopsys.com (Postfix) with ESMTPS id 3FFF8C01A5;
	Tue, 18 Jun 2019 15:56:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1560873403; bh=1CMFfyJ7KaqXsTwHeD0j2YtsPsIQr6LJJY2pE9Kcd60=;
	h=Subject:To:CC:References:From:Date:In-Reply-To:From;
	b=gLp1WFIlY0uITGiBUv9seLfszYyDfOeKylsQABZ2qhGKRm70yCVDLOC2NJlg7bM+5
	 +JMjx860EQZ58XxmfMDDGp7ehxdfkvOhQ+JpVGzZDWhJgJLPbC3/fG9xaB3kUZlkJj
	 qcutieg+xUzcla39kpZj7SzhNi3boWO5AvnpBYjnfvj+IQkhl7ipROUMdD626O0ydM
	 Ic5gNnWgvlYjTWuxWwJ01ypiUQ6CKDrUvhC0J0ZS3EyyzWHPZyUWxhs2v91hrLy+Ms
	 N+WX6vmDUjyJxNBmYDLddfI6TCY6097LKe850NFvCbOCub5IhpXr5EDm5bEF/RTh5B
	 sMWOPW0YcJ49Q==
Received: from US01WEHTC3.internal.synopsys.com (us01wehtc3.internal.synopsys.com [10.15.84.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
	(No client certificate requested)
	by mailhost.synopsys.com (Postfix) with ESMTPS id D2325A0069;
	Tue, 18 Jun 2019 15:56:40 +0000 (UTC)
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.106) by
 US01WEHTC3.internal.synopsys.com (10.15.84.232) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Tue, 18 Jun 2019 08:56:39 -0700
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.103) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.105) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Tue, 18 Jun 2019 21:26:50 +0530
Received: from [10.10.161.66] (10.10.161.66) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Tue, 18 Jun 2019 21:26:50 +0530
Subject: Re: [PATCH] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	Eugeniy Paltsev <Eugeniy.Paltsev@synopsys.com>
CC: Anshuman Khandual <anshuman.khandual@arm.com>, Fenghua Yu
	<fenghua.yu@intel.com>, arcml <linux-snps-arc@lists.infradead.org>, "Masami
 Hiramatsu" <mhiramat@kernel.org>
References: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
 <e5f45089-c3aa-4d78-2c8d-ed22f863d9ee@synopsys.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Openpgp: preference=signencrypt
Autocrypt: addr=vgupta@synopsys.com; keydata=
 mQINBFEffBMBEADIXSn0fEQcM8GPYFZyvBrY8456hGplRnLLFimPi/BBGFA24IR+B/Vh/EFk
 B5LAyKuPEEbR3WSVB1x7TovwEErPWKmhHFbyugdCKDv7qWVj7pOB+vqycTG3i16eixB69row
 lDkZ2RQyy1i/wOtHt8Kr69V9aMOIVIlBNjx5vNOjxfOLux3C0SRl1veA8sdkoSACY3McOqJ8
 zR8q1mZDRHCfz+aNxgmVIVFN2JY29zBNOeCzNL1b6ndjU73whH/1hd9YMx2Sp149T8MBpkuQ
 cFYUPYm8Mn0dQ5PHAide+D3iKCHMupX0ux1Y6g7Ym9jhVtxq3OdUI5I5vsED7NgV9c8++baM
 7j7ext5v0l8UeulHfj4LglTaJIvwbUrCGgtyS9haKlUHbmey/af1j0sTrGxZs1ky1cTX7yeF
 nSYs12GRiVZkh/Pf3nRLkjV+kH++ZtR1GZLqwamiYZhAHjo1Vzyl50JT9EuX07/XTyq/Bx6E
 dcJWr79ZphJ+mR2HrMdvZo3VSpXEgjROpYlD4GKUApFxW6RrZkvMzuR2bqi48FThXKhFXJBd
 JiTfiO8tpXaHg/yh/V9vNQqdu7KmZIuZ0EdeZHoXe+8lxoNyQPcPSj7LcmE6gONJR8ZqAzyk
 F5voeRIy005ZmJJ3VOH3Gw6Gz49LVy7Kz72yo1IPHZJNpSV5xwARAQABtCpWaW5lZXQgR3Vw
 dGEgKGFsaWFzKSA8dmd1cHRhQHN5bm9wc3lzLmNvbT6JAj4EEwECACgCGwMGCwkIBwMCBhUI
 AgkKCwQWAgMBAh4BAheABQJbBYpwBQkLx0HcAAoJEGnX8d3iisJeChAQAMR2UVbJyydOv3aV
 jmqP47gVFq4Qml1weP5z6czl1I8n37bIhdW0/lV2Zll+yU1YGpMgdDTHiDqnGWi4pJeu4+c5
 xsI/VqkH6WWXpfruhDsbJ3IJQ46//jb79ogjm6VVeGlOOYxx/G/RUUXZ12+CMPQo7Bv+Jb+t
 NJnYXYMND2Dlr2TiRahFeeQo8uFbeEdJGDsSIbkOV0jzrYUAPeBwdN8N0eOB19KUgPqPAC4W
 HCg2LJ/o6/BImN7bhEFDFu7gTT0nqFVZNXlOw4UcGGpM3dq/qu8ZgRE0turY9SsjKsJYKvg4
 djAaOh7H9NJK72JOjUhXY/sMBwW5vnNwFyXCB5t4ZcNxStoxrMtyf35synJVinFy6wCzH3eJ
 XYNfFsv4gjF3l9VYmGEJeI8JG/ljYQVjsQxcrU1lf8lfARuNkleUL8Y3rtxn6eZVtAlJE8q2
 hBgu/RUj79BKnWEPFmxfKsaj8of+5wubTkP0I5tXh0akKZlVwQ3lbDdHxznejcVCwyjXBSny
 d0+qKIXX1eMh0/5sDYM06/B34rQyq9HZVVPRHdvsfwCU0s3G+5Fai02mK68okr8TECOzqZtG
 cuQmkAeegdY70Bpzfbwxo45WWQq8dSRURA7KDeY5LutMphQPIP2syqgIaiEatHgwetyVCOt6
 tf3ClCidHNaGky9KcNSQ
Message-ID: <8b184218-6880-204e-a9dd-e627c5ca92ca@synopsys.com>
Date: Tue, 18 Jun 2019 08:56:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <e5f45089-c3aa-4d78-2c8d-ed22f863d9ee@synopsys.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.10.161.66]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000030, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+CC Masami San, Eugeniy

On 6/13/19 10:57 AM, Vineet Gupta wrote:


> On 6/13/19 3:07 AM, Anshuman Khandual wrote:
>> Questions:
>>
>> AFAICT there is no equivalent of erstwhile notify_page_fault() during page
>> fault handling in arc and mips archs which can call this generic function.
>> Please let me know if that is not the case.
> 
> For ARC do_page_fault() is entered for MMU exceptions (TLB Miss, access violations
> r/w/x etc). kprobes uses a combination of UNIMP_S and TRAP_S instructions which
> don't funnel into do_page_fault().
> 
> UINMP_S leads to
> 
> instr_service
>    do_insterror_or_kprobe
>       notify_die(DIE_IERR)
>          kprobe_exceptions_notify
>             arc_kprobe_handler
> 
> 
> TRAP_S 2 leads to
> 
> EV_Trap
>    do_non_swi_trap
>       trap_is_kprobe
>          notify_die(DIE_TRAP)
>             kprobe_exceptions_notify
>                arc_post_kprobe_handler
> 
> But indeed we are *not* calling into kprobe_fault_handler() - from eithet of those
> paths and not sure if the existing arc*_kprobe_handler() combination does the
> equivalent in tandem.

@Eugeniy can you please investigate this - do we have krpobes bit rot in ARC port.

-Vineet


