Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6E7AC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:51:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9913C20842
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 21:51:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="o9Q41Qcr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9913C20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BACE8E0003; Fri,  1 Mar 2019 16:51:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 342D28E0001; Fri,  1 Mar 2019 16:51:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20D608E0003; Fri,  1 Mar 2019 16:51:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D17C38E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 16:51:34 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id n1so15297424plk.4
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 13:51:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Aj5WngXuPv1MUGPfr1Svb4twrAc+hcEOJ/1LSJ7sZ+s=;
        b=C4UxllOm6g4o7LzUwfuyfdCippTW5sutVTwuv5lgp7JeX+hyTMkKEGNIUYrPayNnsb
         LtrIb3YbUeS8ljAL3mPABzAxN3pAzg+9BErnQfVhcp8VvxB/2yfbi4fq859c424llJvG
         vkNGDveDqD9cWD/FBkws/D3uazAmddqphq635fKIZFcXdu8yg9JuAypfp9dyt7w4nvct
         R0DZFh4Q9ZxKNm3WKBJVX+29cLBy/m2lTU5eRbxLej952hqYLPSTFTYpWnFjeQocBAOf
         Cb/TFRHpMgC4JtWMFBzzG7ravznGi2+Fuvd/BZRdHAb1hc6NW5CEDY9HTyT3WrfygIWw
         LumQ==
X-Gm-Message-State: APjAAAVwqPUz6rntrH4T1d7HGFZYAPzIvS4Tw3f1ofcE6KO2g+dq6ZQu
	JtmnRx8L+9v1HyRL4LuWtCTEpTbefH5BxV2V1ovp38CV3j6ZOvMZDDOPptVX2OX9/QOJD8tl9l8
	CucGIQeK5hb9zmSFbzg4PcCse2c2hVeCQG6ktujRewf4ca5YgNLv48RgdwPIgdojr0FMIkWSzSj
	3V9MER6+FjR1ypIbnTwMxLxALtFq6g7AT9oIBEF+D5VD2kiHiUkT2UmdKXD6TN4x0ApeeKP7aja
	1Lsvbvjq3kSh9nDV5BMxdSoyvoKllIt43wbpFXMNKDkFidOrv8ZcKOZ6hixj0oY8ObFBoFBznQY
	0/HGGySmAJOxL2fqO9S5/E073eEgxjUSyrNfQF7jkF6ydIqOqhrNTMjPubsioO0f1/tXbt+aih2
	w
X-Received: by 2002:a63:c310:: with SMTP id c16mr6754774pgd.233.1551477094525;
        Fri, 01 Mar 2019 13:51:34 -0800 (PST)
X-Received: by 2002:a63:c310:: with SMTP id c16mr6754718pgd.233.1551477093695;
        Fri, 01 Mar 2019 13:51:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551477093; cv=none;
        d=google.com; s=arc-20160816;
        b=WEr1UIU9kFTT6Hm2tTPORBNE4JFNFObK7dqZeJm7TFM2r0QXnQ0tZUp+0MsF9HAwA/
         Kozijy+YQW5r1Dytp9r/EmAgz/GlwKAFKN1zAFJP4hTyjcHKiN9Ha29W6d1ADfza3X0z
         UORgSvjxCt0O8I3mDROnFPHw36Krntvg53BSYPOmwyb2DjaO2LGuAHHQn07nXjVEVkYI
         6TYIlB1AYBZhS2neYxTBG9tYwnVwyE3VEDF9PLtpexX/0PQOeuy/YhekmjftZkoOYRTk
         VnpyYcWNNy0qGU7aH59qa0fZ5uQrAZGASnLn53v5eC+FJhdNQmfL8gA2SE8QLe4qdiU/
         +HRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Aj5WngXuPv1MUGPfr1Svb4twrAc+hcEOJ/1LSJ7sZ+s=;
        b=nlMmQHlByG4yDBojkPBlchFeF/LkdrAGL6B66nieiad4KbB/hc9nrfRv7FcblQrkSk
         6Dhth1ttIXi7G93j399G0jUHzWlFD96p89D8itDuVCh/t6FcYXBNJCUmFv3Uk8S0Jx3+
         zZDzvlg8IfaK8vYKpogR+n5zFyD08e+Ie/sZ+kNsj1N+sDLND/g+886Xtxd4ZsbFz/9A
         eKRqjhLdjdw18df2N2//VqOZi31QKEbf+HjLTqjg7rEU0jAunLdRRy9Ys2UVLcyKd2OF
         3Wa9kP0UGqVHFxdbc42h0qV3bFsiVW8EQX3g7gcYutvJRMzdY6KSDxCCXKDEhVZhPZxv
         GT9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=o9Q41Qcr;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e13sor37396995pfn.5.2019.03.01.13.51.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 13:51:33 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=o9Q41Qcr;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Aj5WngXuPv1MUGPfr1Svb4twrAc+hcEOJ/1LSJ7sZ+s=;
        b=o9Q41QcrAmiy9uClSumYrhP0iIX1ivdxDjZJXBgtpU1Wa/IhUIBZ9Wsy2IXYtbjtAu
         QLNb5xTEx1bVx/d9Ks70I5wArsnPwmzFhdyccxlH2Y1x39uGrK7TV5Fox3VBW5L/Fuwh
         MR0PUYQsP0blBMEG27GA5FAk/3CCBX9jBeLPY+2epUC/cO05WTuW/kukGAj1vaOGABGT
         N6ujdNuuiVeX4WC0qaWFarQKhh6VvcEfelWGu94ARSkaeeXKD01NeDuL3ScC66+ja2aT
         578nbXYLdDYnLnrTCgY7vu/bBcboS6uFf1Ux75ILzpvgHlfjLnYKF7s8ZyQw0xL+tAxu
         Soag==
X-Google-Smtp-Source: AHgI3IZDDJx8IBKR78ntuvauMt2JDwANXe4J3i+HfBUUs8GKofdYxp30dg8nhFCM1C0nuGGiV76tSw==
X-Received: by 2002:a62:449b:: with SMTP id m27mr7938829pfi.79.1551477093379;
        Fri, 01 Mar 2019 13:51:33 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.82])
        by smtp.gmail.com with ESMTPSA id e21sm60252029pfh.45.2019.03.01.13.51.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 13:51:32 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 31A663007CA; Sat,  2 Mar 2019 00:51:29 +0300 (+03)
Date: Sat, 2 Mar 2019 00:51:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Guo Ren <guoren@kernel.org>
Subject: Re: [PATCH v3 06/34] csky: mm: Add p?d_large() definitions
Message-ID: <20190301215128.qqzmyqyzxxatbqgh@kshutemo-mobl1>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-7-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227170608.27963-7-steven.price@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 05:05:40PM +0000, Steven Price wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
> 
> For csky, we don't support large pages, so add a stub returning 0.
> 
> CC: Guo Ren <guoren@kernel.org>
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  arch/csky/include/asm/pgtable.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/csky/include/asm/pgtable.h b/arch/csky/include/asm/pgtable.h
> index edfcbb25fd9f..4ffdb6bfbede 100644
> --- a/arch/csky/include/asm/pgtable.h
> +++ b/arch/csky/include/asm/pgtable.h
> @@ -158,6 +158,8 @@ static inline int pmd_present(pmd_t pmd)
>  	return (pmd_val(pmd) != __pa(invalid_pte_table));
>  }
>  
> +#define pmd_large(pmd)	(0)

Nit: here and in other places, parentheses around 0 is not needed.

-- 
 Kirill A. Shutemov

