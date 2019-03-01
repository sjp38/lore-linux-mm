Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA036C10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:28:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 598192083E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:28:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Tm1tQon+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 598192083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB9EC8E0003; Fri,  1 Mar 2019 07:28:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A69B98E0001; Fri,  1 Mar 2019 07:28:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 932C78E0003; Fri,  1 Mar 2019 07:28:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 501EA8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:28:50 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so17592761pgq.9
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:28:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=//6YYsQF8GgCh58e9gUcqUx70l8klEmhGzm+30mhqCg=;
        b=ivgX7yESNthmIEkC94xdpcrwkvJhK7atlnrNcEu72JGKe/+2lUs88ySHVS/u0AAHJY
         Kr4P6WTnbSyvybQ8y47apkvjIFC/q74ZoJ23EEIYmUcTE1TLnfg20tMQGd5YFQ6DflUS
         IkUgM3LQcLsFENO60GAUbGy3bJFx5v8mULg1owmADt8vewVfd+RJZ0Tkf1DAN7SpCg6Q
         9VnE11DJgy2xC2WmTK9RmZZ3Ny/VUs5WGmb23Y+XTocr1jHkaoef4bk9jRdk9Qxnb8Z6
         E6Tpk82esxWV4JANLvKuWE8c2vdf6IX8r/v8JsdkJXHFKqLol4SBT/471SsRIW20ALF8
         olNA==
X-Gm-Message-State: APjAAAWYaqtvD3VglhK7mftVlr7OU4FcSRrWl54pdCkRMNaM3rNNSA1v
	OYqvnMtCDyltADRNLGFwkcn/5M0fIQYMaNupMRHuIzkP/ImjHlYMwGrW1sDxIYUw3f1Lfx8Ai2f
	/4EK1HGivpxjYnN7leqS5y3PLcbVJv4Q1hXwa8msKpIpK+je9iEqadaoZ4AhfctNgtMzLyDW8xc
	gIcw05xpnqVOre7Srv6clDw+WP11qcQsVWfHU8dj9KSKnSJv7aqytnZ/G7oGIGlbeDulzs7E20J
	ySEGkanvWeqHqiiccLaMTPMFdnzrBKlkMZ/XrrYI0KZCF6eP/yMX1F39wrAF+5xjCG5mDuMLLee
	3qv4IyAeyQUb4ghcVEYZrC66+nIEiB/CqBsexhoic2SmIeuNqLUSGVFKf7bWyB2YA2Q70Bcz7nD
	c
X-Received: by 2002:aa7:8059:: with SMTP id y25mr5263351pfm.74.1551443329851;
        Fri, 01 Mar 2019 04:28:49 -0800 (PST)
X-Received: by 2002:aa7:8059:: with SMTP id y25mr5263295pfm.74.1551443328821;
        Fri, 01 Mar 2019 04:28:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443328; cv=none;
        d=google.com; s=arc-20160816;
        b=wxtVTxV9JdHEpw8eTcxsSd3GZ3pYwrbQxOCeO/vYlMTX+5lT1nRj0uug53S50wZt/7
         k024j8j9RrE0AAS6uNnjx7EppnbU1WLMBtew+20ZQ4BJKNyXSSyOmToVcLElACrn+p23
         VuwJBMFjsEj7MwszkqxxUfH4Vz37IF/MhMPWpvx2wMUFya8POP3PCDa6RSVdglWV5kOt
         PZCkNRCd3Q+IiNB7A6k1I4dlJ4RYQKkG5pJJWA+EXLV+/XDlrZ9sxZIFcDlr2rwnfjDt
         lkVjYTe6KjgHNMvE5xqRBBRoDJu0UeglVfgWR4mdi+O58tl9PTUtYqZNNHJAo0Ch8eVa
         pJSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=//6YYsQF8GgCh58e9gUcqUx70l8klEmhGzm+30mhqCg=;
        b=xPErUqX40jEkr/aJAax4nFGHVjtJdHevxCsP5jcuPRYUvtmeDqqLQoS9ovFTEg8fg4
         eJR4rNVyWLzVbcaLkOuuWyrJcEYtBlSUG332Cc8wJYT9B3ZGJlLYWm2BQ4MD1a8g1E8E
         NOZYpUlTc39Ij60aYTWKj/0tx3cL04D/6CZJ51dg5RfSlyxLnuHm966W0xZm9qqRHew2
         saOh/qST3631pdjW4j8FgHxv2z/Su8fsM0TIWfVELhdJm5Xtmm9Wu4urq7vO1kgJqzye
         f/zvvvPvqPO0N3VTKQSgWbJZAZbMSMVIZKO0b3KS48XBTTLjM1LfJexnbB3Zzv4L+K8J
         nVFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Tm1tQon+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e13sor34907920pfn.5.2019.03.01.04.28.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 04:28:48 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Tm1tQon+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=//6YYsQF8GgCh58e9gUcqUx70l8klEmhGzm+30mhqCg=;
        b=Tm1tQon+UU7S9BJ8mWVuw58F/jEjjJT9Y5SBanjOnNYZcQNzXTmiC1Xwnxp2FbG17u
         C5C0XCbHKjGbuxPl314LrXHPwi0tTbrK3izEi8T/5Rb1o2kho9SfYMCznGhpXWQjf2Do
         GzBvvN4CDeaFJurfVbSpa/vXOO/FnrGjf5VvcSJYqof1rdcuKdbrJj7dEsL6sP35P7tS
         zFw4Y3/r5eLSZxvH+5SiSpeBb50fMj17WHwcPQbn+R4ech237C7IyExUbEn1GfNMWDP+
         NeKbTY/pFIFt+UnNt4GTLrffJXkDwmL5jvrQGSQ4GPIujgW5nQMdeMVgaVTpENey7BdI
         j4RQ==
X-Google-Smtp-Source: AHgI3IYJXPBVK8/oKi2e4yu3mf/HzJGVjbMeFmbWAqJgFTTns7suMUS1K566ACkqu9WFhUM6jAHMYA==
X-Received: by 2002:aa7:9259:: with SMTP id 25mr5219988pfp.221.1551443328369;
        Fri, 01 Mar 2019 04:28:48 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id d5sm30561812pfo.83.2019.03.01.04.28.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:28:47 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 2630F3007CA; Fri,  1 Mar 2019 15:28:44 +0300 (+03)
Date: Fri, 1 Mar 2019 15:28:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Steven Price <steven.price@arm.com>,
	Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-arm-kernel@lists.infradead.org,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
Message-ID: <20190301122843.a2pwiqejhcbammao@kshutemo-mobl1>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
 <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
 <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
 <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
 <20190301114953.GD5156@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190301114953.GD5156@rapoport-lnx>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 01, 2019 at 01:49:53PM +0200, Mike Rapoport wrote:
> Hi Kirill,
> 
> On Thu, Feb 21, 2019 at 05:57:06PM +0300, Kirill A. Shutemov wrote:
> > On Thu, Feb 21, 2019 at 02:46:18PM +0000, Steven Price wrote:
> > > On 21/02/2019 14:28, Kirill A. Shutemov wrote:
> > > > On Thu, Feb 21, 2019 at 11:34:52AM +0000, Steven Price wrote:
> > > >> From: James Morse <james.morse@arm.com>
> > > >>
> > > >> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> > > >> we may come across the exotic large mappings that come with large areas
> > > >> of contiguous memory (such as the kernel's linear map).
> > > >>
> > > >> For architectures that don't provide p?d_large() macros, provided a
> > > >> does nothing default.
> > > > 
> > > > Nak, sorry.
> > > > 
> > > > Power will get broken by the patch. It has pmd_large() inline function,
> > > > that will be overwritten by the define from this patch.
> > > > 
> > > > I believe it requires more ground work on arch side in general.
> > > > All architectures that has huge page support has to provide these helpers
> > > > (and matching defines) before you can use it in a generic code.
> > > 
> > > Sorry about that, I had compile tested on power, but obviously not the
> > > right config to actually see the breakage.
> > 
> > I don't think you'll catch it at compile-time. It would silently override
> > the helper with always-false.
> 
> Can you explain why the compiler would override the helper define in, e.g.
> arch/powerpc/include/asm/pgtable.h with the generic (0)?

This one will not be overrided, but the other one will. See

arch/powerpc/include/asm/book3s/64/pgtable.h

-- 
 Kirill A. Shutemov

