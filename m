Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADA78C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:48:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 690EA2082C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:48:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 690EA2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C0988E0006; Mon, 17 Jun 2019 20:48:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 049F28E0005; Mon, 17 Jun 2019 20:48:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7AE08E0006; Mon, 17 Jun 2019 20:48:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE7568E0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:48:57 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bb9so6807271plb.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:48:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x1IIyy853VWmbMFvPrJ8ctqrhILgMGwYO0QwBpaQk00=;
        b=DrRrpVtrhfJNoFFqjPy+DuARKKWYM0EC7OfI4vpRJwqBXaeXe9Pk23DFly67Br8xF2
         ghv3hHi3Cb7Alvk5De8OhoVKuxys3VwhXx9AupvO9jjyzHGTdq78IUGV/5PuXR2v46HH
         /OkWIGjjgA7iBkcEC01w2AmnxsrxLnMmxBjcdCOx/2Nr/RDI8Hrfyu/ZFpWr2wM7DHya
         AFQEsx2+fX/d35RICnab4hWs/hTANA9H48Ex7xueOZOTg2KWEUDNrmKIrNV0xqmED75Z
         lC5sSAxH2VOhCfe8Ca6N1iJ5/k+ep14suIWmT7TkR8O4XfjfUGAZOVpNTIe00cFCumkO
         jkeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXHi/wM5EYmb7os3oS3jJXPYOubeAjBV0CyfkfTa63OIU62VG7U
	z2mQeag1Fw7sG8qh0ebrIGIljXOhBdRsUkt7Wdi800EYYD1BYBgC3gcj8fzPsnIteB6H6pCk0Au
	5uWDnclwtWpWTkz5JT+mPzoQwgXD7JGtKkA82UeZQS20Odd3YkvxzqO6eQ5HTEmmRKg==
X-Received: by 2002:a65:568d:: with SMTP id v13mr103927pgs.144.1560818937234;
        Mon, 17 Jun 2019 17:48:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/DibQsAFs6V5P/rhldjb4cooILTyAVCPbOPIY1n16POoedz7TcwTNTOXDp3gX0E2WAJ/B
X-Received: by 2002:a65:568d:: with SMTP id v13mr103880pgs.144.1560818936493;
        Mon, 17 Jun 2019 17:48:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560818936; cv=none;
        d=google.com; s=arc-20160816;
        b=EIP3kLqYfuEb2aNkl3AKtXxsWGKE5VxV4+6/elJ9xYdwaHkH2KxYWfTSsiLbxycf2I
         1uGEwyzTUSCw/xP8zPR0Dkj2Xbc4sN/VQSxk2RrqIJrhh3SrbTe/EQ0btmeP1pVwIM48
         wzKucSUUIcKWT4qCq8h5NTMmmp4sAsv4cEi0zleN3j/s+NKRHKyEhPs9fa1L315ae1vG
         e1f9/5CG4ATQ70IAEZT/pzHdWYIqdC2w5pBKayg//u2HxTyeAJPBDBaaTvSvZV6z8oDq
         hJ52S9Al0nP8D4OH1EnE7fSG9CM87Zyjdna5133zdPBcE4b8CI5BJmBs2KIbhDILFG+L
         1OYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=x1IIyy853VWmbMFvPrJ8ctqrhILgMGwYO0QwBpaQk00=;
        b=P+KYXYM82qlQZ1ParR30VUr+Y4arR2wm8Re+CZuRrUlyCf0+lcuyi4trjvpX4MDyo2
         wuv5EJDNtUxe5gTJZ0VsWx8vtpfsZavk3k/JduJmerozcIPySiRblbrisD7+nIfFMA+t
         W0aTX6013JarEVDPgkxQzV8/zQ4Y//BuWHXFur94zFTMVOx8BGOKK/Xz0omVpMDvuSDQ
         D3ilNIMCHYtvZC2CGuRKqpC1DzH46nJgX1HgN8p9f6DLQ2rsUPwFASzun6oYVjD8Bz/Z
         25c+3G5GmYoMrW9J4VUDUVyRcLUOxk6A/0pR9//hKLDHo9zONwftV0G/w9yhZJWJzbt5
         73xA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id j8si11120813plt.303.2019.06.17.17.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 17:48:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 17:48:55 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,386,1557212400"; 
   d="scan'208";a="185930070"
Received: from khuang2-desk.gar.corp.intel.com ([10.255.91.82])
  by fmsmga002.fm.intel.com with ESMTP; 17 Jun 2019 17:48:52 -0700
Message-ID: <1560818931.5187.70.camel@linux.intel.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
From: Kai Huang <kai.huang@linux.intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton
 <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin"
 <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra
 <peterz@infradead.org>, David Howells <dhowells@redhat.com>, Kees Cook
 <keescook@chromium.org>, Jacob Pan <jacob.jun.pan@linux.intel.com>, Alison
 Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, kvm
 list <kvm@vger.kernel.org>,  keyrings@vger.kernel.org, LKML
 <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 18 Jun 2019 12:48:51 +1200
In-Reply-To: <d599b1d7-9455-3012-0115-96ddbad31833@intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
	 <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
	 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
	 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
	 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
	 <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
	 <d599b1d7-9455-3012-0115-96ddbad31833@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.24.6 (3.24.6-1.fc26) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> 
> > And another silly argument: if we had /dev/mktme, then we could
> > possibly get away with avoiding all the keyring stuff entirely.
> > Instead, you open /dev/mktme and you get your own key under the hook.
> > If you want two keys, you open /dev/mktme twice.  If you want some
> > other program to be able to see your memory, you pass it the fd.
> 
> We still like the keyring because it's one-stop-shopping as the place
> that *owns* the hardware KeyID slots.  Those are global resources and
> scream for a single global place to allocate and manage them.  The
> hardware slots also need to be shared between any anonymous and
> file-based users, no matter what the APIs for the anonymous side.

MKTME driver (who creates /dev/mktme) can also be the one-stop-shopping. I think whether to choose
keyring to manage MKTME key should be based on whether we need/should take advantage of existing key
retention service functionalities. For example, with key retention service we can
revoke/invalidate/set expiry for a key (not sure whether MKTME needs those although), and we have
several keyrings -- thread specific keyring, process specific keyring, user specific keyring, etc,
thus we can control who can/cannot find the key, etc. I think managing MKTME key in MKTME driver
doesn't have those advantages.

Thanks,
-Kai

