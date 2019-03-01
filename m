Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AFD7C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 22:12:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14D172083D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 22:12:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Z19Eg8Zm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14D172083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B72838E0003; Fri,  1 Mar 2019 17:12:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B21E88E0001; Fri,  1 Mar 2019 17:12:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E9A88E0003; Fri,  1 Mar 2019 17:12:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6517E8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 17:12:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x134so19946088pfd.18
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 14:12:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xgavR2DFMNaf/vLZRKzzbgkI0A+HRsMgfHhmYXn8qi4=;
        b=DffWPtI4Qg/ZMG6b2+T/JmhIUozzeUIwoA99nMdeWZeq9lVyaSMLPudLVON7kLLcPP
         evda4lQYrI78SNEVDW8QwI08ckjDia576Otj1gl3jDnQsxUeZeWnOb36sPgUXqoDBcks
         U8+5YVdDt2OfzywIKnFCI47PgXr6U5sVAVQpXDolbcugCpetVJWIkjdvGuEyGVIhNBgG
         q5/JzJdAW0W4NfOL3HnFcHyxOH9h8qSrub5WwjSmgkEbLqdOgcHM/eraZaY+y/idzf0O
         FZ/dqGevGAelteeT+u2wulkkPxxkQ79l8kPGAZ+qQ9wmFkFJ9YpbpwOYEx+9TUidQY20
         AaLw==
X-Gm-Message-State: APjAAAVUxJSvqhdWk2DbIEYikDI3IYcv8EkTkoJaEuUUcU8ZlAhZU8DN
	hxZ1cQPe3QyZk3BA0jXiW+B3Ny6dPuZcbGuv3G6erG1BPYoFnNUbK0MOdM+b6xJscrH8PuIfl3h
	xLfSXGqdsFfONQjlM36BcCYZy+bmyQC0Hn5DhWIXNYOIeySrr2r6y8idd26u60CBx1LdiFJqA4t
	xpBJDywohsBzGSFm6xce/nv9QNlx06obcMPju0+FsNBD1SuxEGZx/N60MkcUegMqVej3p5Eea4u
	LxXLn6eKb5758WUh1kvHiMQVWps7NIZ80rRIxUyQvWWHkxOvA5HwleoWbPUNkxxj/0DiEF4n7jy
	vDnpU51cj6Z3kk+xGlbZ+PbLGEAMDweunRH3I5M56+dfWxTcTxo9Tr9sVF81ALxjTfmdRB4k9UP
	z
X-Received: by 2002:a63:f806:: with SMTP id n6mr7033202pgh.19.1551478339059;
        Fri, 01 Mar 2019 14:12:19 -0800 (PST)
X-Received: by 2002:a63:f806:: with SMTP id n6mr7033150pgh.19.1551478338228;
        Fri, 01 Mar 2019 14:12:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551478338; cv=none;
        d=google.com; s=arc-20160816;
        b=jyGhgLCVSOPx4fT0lgl9m7cFEiLzGoUhHKrEpkW5lLt1Mh8wgeCTejr99ZEzWBsY2l
         pAX6ElEdstZ3fp5bsSGlAzg52LL7IJk7zO1nEcw8X8LmByFm9fE7c0G418utOSISZzbn
         0lq2RxOEMTv0DbzeudRauRBUYmQbk6tLPdpjcWCXXzPEDgelfTuG3YPXYevKwxhjb4oV
         seztwpncGOAkiIpatVuaUIFN8s8joRptr+zfUmR8mBsw7ezH05tocvrc4kzt1/J9M9PE
         IldVBfnK48k/xPgDBtFGt6Q4eG+oIf7qWpJzmqYeGXyPCv6EwcXZi8ZyA6vAawAw62bY
         x93Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xgavR2DFMNaf/vLZRKzzbgkI0A+HRsMgfHhmYXn8qi4=;
        b=xsvkVPd2JTJI1lY2L6OVUr9x3aHfuR3yitVv5IaqZGKoRrartQN3txPe0XbFiU+v0O
         LsgOoTxbezN0vYdFNm9yiqgCiYgCtl2kbCp3gBNGhcEEH/2I81vjChDjlMPz2je49y6C
         78sUMRP3irouhA6wiHsQwfasVrFg+EprUKYhzsz9w6Wa6rMql1WPzyXhID4qpsLFymNV
         TYI2tWhe755SKcrmpgBjtCVhZ7rQAMykjnT03H2/0nE0uyGQ7RdCQ7AP38uayD78JDJ0
         7T8udoubtdegfq2PcMS7bMY34Ov8QVMeU/B4pZJzUB+0byrZR63NqAFK7NHLYcrUBAuO
         A9lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Z19Eg8Zm;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b195sor37612099pfb.45.2019.03.01.14.12.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 14:12:18 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Z19Eg8Zm;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xgavR2DFMNaf/vLZRKzzbgkI0A+HRsMgfHhmYXn8qi4=;
        b=Z19Eg8ZmrghAT9eBXNyLpiI/7ERPMdrWg5DQeGPgeU16srlz6HQsrx0aMgpqjuLQlQ
         cwbxb5u1F8g9p0jGQhOGqdRT8+YRzUxZtcL2tTYYl+0i4zMOLlAw/Af8ZGXeRAIdZkab
         gN+a3UjlXLRZHSea7cTKzQFud5aqbi+g0zUUKlvey6DJkNLE6G9ETpnNO7MBSOXeM3wr
         YKObJWB40lILN3qaxB1hHcrNQIOwHAH3mKe0qJ0CvTkVSAilzXaGHLK40B7wJz8+gdTn
         9YYxqtRcctZhiS4IrS+9+grY1WqYPiU8o8Wn+r+AHvg+kFW6HONdnYpr0XSiKODtNPNl
         SyiQ==
X-Google-Smtp-Source: AHgI3IYTSxYFj6M42G+F5q8mktYtGtp45mqV2dSA6y4kEmnaHrlMPzNlAqdKw3hK7RfzKI6R5msSYg==
X-Received: by 2002:a62:ed08:: with SMTP id u8mr7944175pfh.200.1551478337753;
        Fri, 01 Mar 2019 14:12:17 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.43])
        by smtp.gmail.com with ESMTPSA id l5sm29968347pfi.97.2019.03.01.14.12.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 14:12:16 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 2E4AB3007CA; Sat,  2 Mar 2019 01:12:13 +0300 (+03)
Date: Sat, 2 Mar 2019 01:12:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Helge Deller <deller@gmx.de>
Cc: Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
	Andy Lutomirski <luto@kernel.org>,
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
	"James E.J. Bottomley" <jejb@parisc-linux.org>,
	linux-parisc@vger.kernel.org
Subject: Re: [PATCH v3 15/34] parisc: mm: Add p?d_large() definitions
Message-ID: <20190301221213.snm7cwowr67pdifs@kshutemo-mobl1>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-16-steven.price@arm.com>
 <fa3072ba-f02b-fee5-dc16-d575a5308d4b@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa3072ba-f02b-fee5-dc16-d575a5308d4b@gmx.de>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 07:54:22PM +0100, Helge Deller wrote:
> On 27.02.19 18:05, Steven Price wrote:
> > walk_page_range() is going to be allowed to walk page tables other than
> > those of user space. For this it needs to know when it has reached a
> > 'leaf' entry in the page tables. This information is provided by the
> > p?d_large() functions/macros.
> > 
> > For parisc, we don't support large pages, so add stubs returning 0.
> 
> We do support huge pages on parisc, but not yet on those levels.

Just curious, what level do parisc supports huge pages on?
AFAICS, it can have 2- or 3- level paging and the patch defines helpers
for two level: pgd and pmd. Hm?

-- 
 Kirill A. Shutemov

