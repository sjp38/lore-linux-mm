Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28FCCC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 13:38:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF847218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 13:38:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="fXscU4ee"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF847218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8590D8E0003; Thu, 31 Jan 2019 08:38:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DEF88E0001; Thu, 31 Jan 2019 08:38:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 680958E0003; Thu, 31 Jan 2019 08:38:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3D28E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:38:49 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id d6so1059714wrm.19
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:38:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N9ZfktBJAMGDaOqi63rNj6dpil8IUx1OGdlTeCh4s6w=;
        b=kmgGBwlsRFy40cZJ0JvSmjNTzLsHK+bhD9BOUfP7NceScBPRMkdL8a9iO6wLaC7GPQ
         +aaTZknNnMBTnUSSRZ6TydFwqnVACclZpZ//1c89F3KFMSERbShyI63PI0Cv05A8FZNR
         Q+Sq4d1BFYOl7QT+HGh/x6vpHi1Os21dffKYBVtYAc1gNYX6jjGg5llKtjCo6UTE2Yjt
         5Fa63InJpUpsERkpd3zNj3S+I4WeaeIb6gWHre4wZE1sdsbYTyycfg3UfJBgif17ZiAO
         JB1Phwq0sbiXp8tyaAeD0pKjCugUzKHhDwkj4rORASfmHZ8aGODi6VdLPfcgADQ3llNy
         +HJg==
X-Gm-Message-State: AJcUukcItGlWPnCXamvr1TqoQ02F1/2DSBl3H7UGKnNVhGd2FZD+SYwS
	kSJJ7Ld2A1B4G2d7CuFZaNvo1nGpaKbvzZrs3bqrszt0cjxTRU9xafIiJx7uuRLUe68hkIEO/Pj
	XXuPAfiMil2rFGpEaD/hW5cCMyZhwn4hON5ImAqN2rBzSIeWFD6J2HDC0f7Fy/ANeZA==
X-Received: by 2002:adf:f504:: with SMTP id q4mr35981985wro.321.1548941928662;
        Thu, 31 Jan 2019 05:38:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Y//redcYT1mLMIf8jL/sJqWndUmdzwjcrg8pA6Iq1mHdajjwfGCILMX1WveLecTsaRv41
X-Received: by 2002:adf:f504:: with SMTP id q4mr35981939wro.321.1548941927910;
        Thu, 31 Jan 2019 05:38:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548941927; cv=none;
        d=google.com; s=arc-20160816;
        b=qIoWlXk600OILoqOMGby7917q7ssqaQ+cqUF7LUwBiZdXe6fhN+G2EFbbWDv8/2wcy
         sy4u1K7aPnIfBDdnxn6i6t7lgZDbZycaLRSg3xl3mmrGA9DVbJUHWefeApRVgvUMgvHD
         YNX7j0LXM4iqdMta6xoqh5qLpFIyTlbr7DqM5WNMZpcHKixBHbYgqi9fSPC+ZZWEHsNr
         KRbtH0ryXaDUssW/d8LTdGqCu3SdNkym1uoyGnuuuuGTpMe7NasV9/juHsRDmTKmMsTE
         nmfnKXm+ySMVeH22NsHYYcpZx0BLkyUjiO9+6n99o0W4vb6YLhpmHsKT/TbDZ+JjRTWO
         K+NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=N9ZfktBJAMGDaOqi63rNj6dpil8IUx1OGdlTeCh4s6w=;
        b=TbPwMaGTmec3+s3u/4boKwvhwkWBoJZRjcDAdCAHQOMnob150bp3W58iVwlrcIETIv
         v1oh292L9S1bRbhJdExQ44OBcLQ2RImzTvaxh1p9oblg1QYhksGso8CAvIHE3UewKCwJ
         EmOcf6s6FGi+1YFUpi1DKULWhblojp2l+FEex0Ge7GmNsJZrTDRs7P5QymbFV4J+1HzU
         /VHaInNNltV6dtBpy0LDNb10gU+yvcikYDzCV94vXDwkqVyNKxyiF4lkNqz4bqdFNpx/
         uBKqmXX4csy3TnHEPY5c0DTrdi2P0wNdVYIacovh00Cym8D7Du3YRbjVnt8yAoGZGnRr
         yIOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=fXscU4ee;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id l3si3716972wru.225.2019.01.31.05.38.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 05:38:47 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=fXscU4ee;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCC5900651C63FB93E4C575.dip0.t-ipconnect.de [IPv6:2003:ec:2bcc:5900:651c:63fb:93e4:c575])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 191B41EC059E;
	Thu, 31 Jan 2019 14:38:47 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1548941927;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=N9ZfktBJAMGDaOqi63rNj6dpil8IUx1OGdlTeCh4s6w=;
	b=fXscU4eeC2ToGWv6EVxYT5WtmhOF8NW0lZM2/wfvSID9gZS0549ZoFEAJheQvCW+hl03Uj
	wfD84p+pgqW+Tl7C0OAylMfQ5Xd9zmT8Cyt/xLrjf9jDmxW5isLfbUA6QbTK6EZ+Ywtft6
	JzhH2T1j/SxhHenwGC/hy0GjIb2jDrs=
Date: Thu, 31 Jan 2019 14:38:42 +0100
From: Borislav Petkov <bp@alien8.de>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>
Subject: Re: [PATCH v7 20/25] ACPI / APEI: Use separate fixmap pages for
 arm64 NMI-like notifications
Message-ID: <20190131133842.GK6749@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-21-james.morse@arm.com>
 <20190121172743.GN29166@zn.tnic>
 <bee87ef4-60ae-d4a4-2855-159543072fc5@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <bee87ef4-60ae-d4a4-2855-159543072fc5@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2019 at 06:33:02PM +0000, James Morse wrote:
> Was the best I had, but this trips the BUILD_BUG() too early.
> With it, x86 BUILD_BUG()s. With just the -1 the path gets pruned out, and there
> are no 'sdei' symbols in the object file.
> 
> ...at this point, I stopped caring!

Yah, you said it: __end_of_fixed_addresses will practically give you the
BUG behavior:

        if (idx >= __end_of_fixed_addresses) {
                BUG();
                return;
        }

and ARM64 does the same.

> We already skip registering notifiers if the kconfig option wasn't selected.
> 
> We can't catch this at compile time, as the dead-code elimination seems to
> happen in multiple passes.
> 
> I'll switch the SDEI ones to __end_of_fixed_addresses, as both architectures
> BUG() when they see this.

Right.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

