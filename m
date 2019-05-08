Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE868C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:49:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B196E20850
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:49:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B196E20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 408796B0003; Wed,  8 May 2019 16:49:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B9996B0005; Wed,  8 May 2019 16:49:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A9046B0007; Wed,  8 May 2019 16:49:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E88C56B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:49:36 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g11so80942plt.23
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:49:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=3s6ZOoEFzQgmmY4RiBUNYa05M1MljOt4HlKCqq6VpBE=;
        b=WGton5QNs5Fhrz8RrdZ3dboaF+ZUIofVTcXEQMhy/z4axmuFnp2sGzLWaHTCSdmWOp
         q64PChQ26TJksONVR4hx7g+FRzhJ02uAXRq/GH60dc5Q//oaiLspdVJbW6Na9Ze0kubL
         PMmHZ+7/NlkFx1v7iU06eocpdpvJUe16RSYKMljw88MkgDXs3SCxM04+UrU7Z8T0BxDl
         1JWSH0j7BcQt4aa6i3CA7Pp05GppftN3XhDc9lDEyqbEEma8SXmRYH0mjM5wmMflobua
         JA5h0CuKVk+LPF9iz/y3bOSlS7UJuJSH+Rsb4SLTk4gXiS0B42e5DSBFuitufadc1456
         8xTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of jacob.jun.pan@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=jacob.jun.pan@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWhFOHSh71QNVresbpXtqjwzu6iV0Czuckd63sQ82Q6+U64lbmi
	ILLJFdJFMfStFO5IuG4tCJweDMoYV17G0U0YmU4aCSt31f0K+e2LG1kxh/208kSc3HBzfxVxoOH
	FoMW0JtDJvzNl6In4oVCH846O1FgXfMu4aoP6HFcFqu9aosS/RBifngS0z04eM9MVXw==
X-Received: by 2002:a63:1e4d:: with SMTP id p13mr232943pgm.125.1557348576631;
        Wed, 08 May 2019 13:49:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCwKTP2ql0ns8tea0mcgsRbnhL6bbCJvgN0upT4mKJIwq2UCO1vhj88NTyxpZ9wjt0kDNW
X-Received: by 2002:a63:1e4d:: with SMTP id p13mr232882pgm.125.1557348576009;
        Wed, 08 May 2019 13:49:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557348576; cv=none;
        d=google.com; s=arc-20160816;
        b=xBzj8t+B46K3Stvj6MchRRZMBQpEq0tWqe3b5neQCokJxJvnZCdXx/yGvrTtvkgYSl
         yWR95UXGej5UXt4fH9R4btnKtUixZuA5Y/tnHSC9+luIRP6dixI6KpJ0VFUTAhhoEOmU
         3qJRrEeoTmofuq3cAPT2eEA6gLIr756gz3ZD1lCvU7xJofoOpUsI4d1Xb3SeTIN8xlwW
         zRCvLPeCE6zFPYGL3ngcQ0Pp5knm7g8sh1ajTct2wi4cuCmKv84HCNegtGrpJO4hiIK+
         VkgQs1kU6HV6h/Htow0iJG2ecDV/+VGBMTilKj3rKqQN/F+Penw8Tg5aiSdX4rbbqsgJ
         iZ1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=3s6ZOoEFzQgmmY4RiBUNYa05M1MljOt4HlKCqq6VpBE=;
        b=zZZBjjlenNrKU94xK0ambXqgBOzyJTXT71bl1/F4cDtf4KOBEjftIrHTEC2FJfj1ov
         5/G+rCi+AAQpZNta1n5LWfo2eHs45JAVXSQlGBk0HF7a53hL/zjiLSSjNKxC1wUpK9o3
         kMTMjq/SXqSRJcOAkcFIPR7xfftNCYtkqLGTVONrkFnxoxYlhcq9+1oXV8lLG6iEC8MP
         tf2gv0MAuo/S/YOZmkgh4baUxgckzBHTj9usB8HnlUEHAoY5QpcwKCCsnVxPKPQNI82S
         WAimP6M4RqfuFXgC1P6Yks2caXRYcxph1dVmbp4awjqIK7OPKCOssuX8ujHswkielzGn
         oyBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of jacob.jun.pan@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=jacob.jun.pan@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h5si45014pgq.224.2019.05.08.13.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:49:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of jacob.jun.pan@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of jacob.jun.pan@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=jacob.jun.pan@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 13:49:35 -0700
X-ExtLoop1: 1
Received: from jacob-builder.jf.intel.com (HELO jacob-builder) ([10.7.199.155])
  by orsmga008.jf.intel.com with ESMTP; 08 May 2019 13:49:34 -0700
Date: Wed, 8 May 2019 13:52:25 -0700
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton
 <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin"
 <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra
 <peterz@infradead.org>, Andy Lutomirski <luto@amacapital.net>, David
 Howells <dhowells@redhat.com>, Kees Cook <keescook@chromium.org>, Dave
 Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>,
 Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
 kvm@vger.kernel.org, keyrings@vger.kernel.org,
 linux-kernel@vger.kernel.org, jacob.jun.pan@linux.intel.com
Subject: Re: [PATCH, RFC 52/62] x86/mm: introduce common code for mem
 encryption
Message-ID: <20190508135225.3cb0e638@jacob-builder>
In-Reply-To: <20190508165830.GA11815@infradead.org>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	<20190508144422.13171-53-kirill.shutemov@linux.intel.com>
	<20190508165830.GA11815@infradead.org>
Organization: OTC
X-Mailer: Claws Mail 3.13.2 (GTK+ 2.24.30; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 May 2019 09:58:30 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, May 08, 2019 at 05:44:12PM +0300, Kirill A. Shutemov wrote:
> > +EXPORT_SYMBOL_GPL(__mem_encrypt_dma_set);
> > +
> > +phys_addr_t __mem_encrypt_dma_clear(phys_addr_t paddr)
> > +{
> > +	if (sme_active())
> > +		return __sme_clr(paddr);
> > +
> > +	return paddr & ~mktme_keyid_mask;
> > +}
> > +EXPORT_SYMBOL_GPL(__mem_encrypt_dma_clear);  
> 
> In general nothing related to low-level dma address should ever
> be exposed to modules.  What is your intended user for these two?

Right no need to export. It will be used by IOMMU drivers.

