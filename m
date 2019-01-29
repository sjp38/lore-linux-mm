Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01B20C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:48:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2A9720844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:48:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2A9720844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 449A88E0004; Tue, 29 Jan 2019 13:48:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FA148E0001; Tue, 29 Jan 2019 13:48:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C3678E0004; Tue, 29 Jan 2019 13:48:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C66148E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:48:55 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so8297088edm.20
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:48:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=nl0+H0NJxLL5KOp3R4b0qS7t48WA6RmxRX6lIpxKwHI=;
        b=XQ/X2FE+RYYUwI0k8VTlkUI0Q2tDhCnJMbk0kEIyohtlKxXEq33Gn+Q0aO8wDMpvcY
         vdoSTfWLL69V5r1prvNndIpIx7fDXLydbs8TwumlzFM1Zoe7HjqGPZviNTP/20MvV+89
         dOtI239UeMZ+gcFbeJ8PXF/ylaXDt0SyK00Ha+PFqedb3kViHhL5LZ3dK1CE1Zm0Oi1x
         9m2upRHp2FN1O6SIqOfHdNcfpMnx/mwQ4u0XSjZa8URlj6hLvKCP3XnzSOhsRE9ptK1n
         7qpTsFTeJ9IsZ6C6c1v+g9t5NsautppT3hrZw2eutaJhuIDdbKUd4YQMHuNq4YxTumZi
         IDPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukcKqVtrlJKjQCGbQsTyKNe+InGN7xYIENAHbMiIr1+Uc52KaK2t
	foa6aES1bTLd3yLgAJ3WeL0R8VzqyAISZpfL+M2tofDDSHzbdKvPq12Xee8ssb03caIwJyVCY4+
	3VUlj53A4NfaIBvZz6pwbMBf9/s8DYjbzzAqXbwxblDRl30w2zSJlBw4f54y0S3eiUQ==
X-Received: by 2002:a50:fa0c:: with SMTP id b12mr25528418edq.138.1548787735269;
        Tue, 29 Jan 2019 10:48:55 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7BTNoZKJ/xUWQkWru/jBfVIAFiG3UDY0Kfo4jTZqrQ8CehSRzC9MoEvdXODmGSH+S6jAcH
X-Received: by 2002:a50:fa0c:: with SMTP id b12mr25528376edq.138.1548787734292;
        Tue, 29 Jan 2019 10:48:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787734; cv=none;
        d=google.com; s=arc-20160816;
        b=ZQ2T7UFhyyygXASF4X/Eco6oRly4mzyxo2b4hIleYvBjQuv41Tj+Aek4yX9alXj3N8
         OcIYTRNReiUpb/a70Xymal20McocA/sY9YcM3z8D8ONTu1qx0yeXBpnkhK9LATSyLBvX
         muGCqXcS2+Rnc39+Vg/jHuud9UsX9mSE/X4TZ2MYOM3IkD+oqDeRsxGoozQPcwJVmkc6
         Xn7RrlT1akGeWUTE7BmsNugZQDidbOhuNr5O8A5huAu1A2vrnunpWF2rU9Ps3dAcUysm
         GRiVuU6e7k0tnl9bCngQ5OUxZnyVlpvAM66suAlniSVCsm2OUaAV+1PzbPPM2SKMoeHg
         Y7pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=nl0+H0NJxLL5KOp3R4b0qS7t48WA6RmxRX6lIpxKwHI=;
        b=DVg5XO7UPUmWa1ypiapYZVqL5Wjr8AsxdSAVRptY7cREGCsX5xHg0LlR79ekKhRfPQ
         E+6A7jr7dJny1/ZW71Y2r0Jl2865Vg7fGy1FdsArO7tFHEOA8cOGq8/SzyiLzyHL6DAc
         FJRAglKWfE/hzcPI3rb/Tqs7uswYz9YJIdr8mAxIvK1ORXP6/+yB1NmPuUEiKhC2gnyu
         F6GRFoFVuKDtJ5HiYq7a4qhUG0SodVcpmMEC4/tmAV+dJPnHWU2Db4fMsypigXDWupba
         Uag53xzPLBttOoYzW4O0xwD2Eu7QUUNYpJT1OSpuxX/2iHGatVZSGWrXUaBJfDVb6Nfv
         sEjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h11si863488ejc.43.2019.01.29.10.48.53
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:48:54 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D2F461596;
	Tue, 29 Jan 2019 10:48:52 -0800 (PST)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1C1753F71E;
	Tue, 29 Jan 2019 10:48:49 -0800 (PST)
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
To: Borislav Petkov <bp@alien8.de>
Cc: Tyler Baicar <baicar.tyler@gmail.com>,
 Linux ACPI <linux-acpi@vger.kernel.org>, kvmarm@lists.cs.columbia.edu,
 arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org,
 Marc Zyngier <marc.zyngier@arm.com>,
 Christoffer Dall <christoffer.dall@arm.com>,
 Will Deacon <will.deacon@arm.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
 Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>,
 Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>
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
 <20190129114952.GA30613@zn.tnic>
From: James Morse <james.morse@arm.com>
Message-ID: <c17156e4-278b-7544-367e-50e928407a03@arm.com>
Date: Tue, 29 Jan 2019 18:48:33 +0000
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129114952.GA30613@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Boris,

On 29/01/2019 11:49, Borislav Petkov wrote:
> On Wed, Jan 23, 2019 at 06:36:38PM +0000, James Morse wrote:
>> Do you consider ENOENT an error? We don't ack in that case as the
>> memory wasn't in use.
> 
> So let's see:
> 
>         if (!*buf_paddr)
>                 return -ENOENT;
> 
> can happen when apei_read() has returned 0 but it has managed to do
> 
> 	*val = 0;

> Now, that function returns error values which we should be checking
> but we're checking the buf_paddr pointed to value for being 0. Are
> we fearing that even if acpi_os_read_memory() or acpi_os_read_port()
> succeed, *buf_paddr could still be 0 ?

That's what this code is doing, checking for a successful read, of zero.
The g->error_status_address has to point somewhere as its location is advertised
in the tables.

What is the value of g->error_status_address 'out of reset' or before any error
has occurred? This code expects it to be zero, or to point to a CPER block with
an empty block_status.

(the acpi spec is unclear on when *(g->error_status_address) is written)


> Because if not, we should be checking whether rc == -EINVAL and then
> convert it to -ENOENT.

EINVAL implies the reg->space_id wasn't one of the two "System IO or System
Memory". (I thought the spec required this, but it only says this for EINJ:
'This constraint is an attempt to ensure that the registers are accessible in
the presence of hardware error conditions'.)

apei_check_gar() checks for these two in apei_map_generic_address(), so if this
is the case we would have failed at ghes_new() time.


> But ghes_read_estatus() handles the error case first *and* *then* checks
> buf_paddr too, to make really really sure we won't be reading from
> address 0.

I think this is the distinction between 'failed to read', (because
g->error_status_address has bad alignment or an unsupported address-space
id/access-size), and successfully read 0, which is treated as ENOENT.


>> For the other cases its because the records are bogus, but we still
>> unconditionally tell firmware we're done with them.
> 
> ... to free the memory, yes, ok.
> 
>>>> I think it is. 18.3.2.8 of ACPI v6.2 (search for Generic Hardware Error Source
>>>> version 2", then below the table):
>>>> * OSPM detects error (via interrupt/exception or polling the block status)
>>>> * OSPM copies the error status block
>>>> * OSPM clears the block status field of the error status block
>>>> * OSPM acknowledges the error via Read Ack register
>>>>
>>>> The ENOENT case is excluded by 'polling the block status'.
>>>
>>> Ok, so we signal the absence of an error record with ENOENT.
>>>
>>>         if (!buf_paddr)
>>>                 return -ENOENT;
>>>
>>> Can that even happen?
>>
>> Yes, for NOTIFY_POLLED its the norm. For the IRQ flavours that walk a list of
>> GHES, all but one of them will return ENOENT.


> Lemme get this straight: when we do
> 
> 	apei_read(&buf_paddr, &g->error_status_address);
> 
> in the polled case, buf_paddr can be 0?

If firmware has never generated CPER records, so it has never written to void
*error_status_address, yes.

There seem to be two ways of doing this. This zero check implies an example
system could be:
| g->error_status_address == 0xf00d
| *(u64 *)0xf00d == 0
Firmware populates CPER records, then updates 0xf00d.
(0xf00d would have been pre-mapped by apei_map_generic_address() in ghes_new())
Reads of 0xf00d before CPER records are generated get 0.

Once an error occurs, this system now looks like this:
| g->error_status_address == 0xf00d
| *(u64 *)0xf00d == 0xbeef
| *(u64 *)0xbeef == 0

For new errors, firmware populates CPER records, then updates 0xf00d.
Alternatively firmware could re-use the memory at 0xbeef, generating the CPER
records backwards, so that once 0xbeef is updated, the rest of the record is
visible. (firmware knows not to race with another CPU right?)

Firmware could equally point 0xf00d at 0xbeef at startup, so it has one fewer
values to write when an error occurs. I have an arm64 system with a HEST that
does this. (I'm pretty sure its ACPI support is a copy-and-paste from x86, it
even describes NOTIFY_NMI, who knows what that means on arm!)

When linux processes an error, ghes_clear_estatus() NULLs the
estatus->block_status, (which in this example is at 0xbeef). This is the
documented sequence for GHESv2.
Elsewhere the spec talks of checking the block status which is part of the
records, (not the error_status_address, which is the pointer to the records).

Linux can't NULL 0xf00d, because it doesn't know if firmware will write it again
next time it updates the records.
I can't find where in the spec it says the error status address is written to.
Linux works with both 'at boot' and 'on each error'.
If it were know to have a static value, ghes_copy_tofrom_phys() would not have
been necessary, but its been there since d334a49113a4.

In the worst case, if there is a value at the error_status_address, we have to
map/unmap it every time we poll in case firmware wrote new records at that same
location.

I don't think we can change Linux's behaviour here, without interpreting zero as
CPER records or missing new errors.


>> We could try it and see. It depends if firmware shares ack locations between
>> multiple GHES. We could ack an empty GHES, and it removes the records of one we
>> haven't looked at yet.
> 
> Yeah, OTOH, we shouldn't be pushing our luck here, I guess.
> 
> So let's sum up: we'll ack the GHES error in all but the -ENOENT cases
> in order to free the memory occupied by the error record.

I agree.


> The slightly "pathological" -ENOENT case is I guess how the fw behaves
> when it is being polled and also for broken firmware which could report
> a 0 buf_paddr.
> 
> Btw, that last thing I'm assuming because
> 
>   d334a49113a4 ("ACPI, APEI, Generic Hardware Error Source memory error support")
> 
> doesn't say what that check was needed for.

Heh. I'd assume this was the out-of-reset value on the platform that was
developed for, which implicitly assumed we could never get CPER records at zero.


Thanks,

James

