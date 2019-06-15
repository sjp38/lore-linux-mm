Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1A53C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 00:29:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 739A3217D6
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 00:29:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 739A3217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F5076B0006; Fri, 14 Jun 2019 20:29:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A7436B0007; Fri, 14 Jun 2019 20:29:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDF6E6B0008; Fri, 14 Jun 2019 20:29:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3FBA6B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 20:29:27 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v62so3052654pgb.0
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 17:29:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KmfkUDcbXBjuwj5yzcQuQKQgi24UD03tulJmJMc6gMA=;
        b=i53kHf3T+BdVazx4cHL4UH1gkr8rEJRWx2zuzyy5b+AWjEQ9Z/gZt+kqPu/VDCEqBr
         eC9p3yvHxOqlGCsdMPsN7pb9JZR5TR3Wcazp8Bh4+LYEIBh0TneZU1IYzhWy3M7ZvJO/
         x1R2QOoJlPI+ILspEkNTP/tCWkooNGzhZGhe29LXz+yYKI92/MfUj+8cYrmKiwE4mtcK
         8JS/0tI1r7Yv+zS09tRo+fLNcWWVLTY74Q3kIdAh5d7PF+mraw2emkwLmclJ3MiyZlGs
         30GSKTH43VVhtJCdMfUfWZ7zKjKJ9iL/qCVQKbrt7fXnAifJgmcCDFPssUPGXXYR3gwN
         qZhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX6b/orieqeTMvJkHW+5QfPhwZS17qt285Pt276av7C9uztKFGF
	avloQ3RJihb80DBcRps04dCnqJ41gjLBHVG2uy4dtz37dz6kurDxjmfiDR14cjaGeBIOjoacYDu
	uAwbXkMVfn5su/59uZc+UQMsbOkrFRyGHcoAofUKjgwW6E85pviz2lMRE388nBBLcyw==
X-Received: by 2002:a63:f346:: with SMTP id t6mr32061741pgj.203.1560558567295;
        Fri, 14 Jun 2019 17:29:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN+ahfEyjHaT6eMNrtNLgipTdir+vI41NrwbjccdwJXlgMrLGHyr7slscLG/hpvtmLYmPs
X-Received: by 2002:a63:f346:: with SMTP id t6mr32061703pgj.203.1560558566470;
        Fri, 14 Jun 2019 17:29:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560558566; cv=none;
        d=google.com; s=arc-20160816;
        b=ZSVM54RJGScS46BUAn89ZpeUD0BmPF4YOVECEHDD5c8lm8MptFLV9JpaG1KrnQcV6e
         kyc6Hx8Z01sLYR4sQELz4uf7jdpt2jF96kv4tGxcmuS/m2eJihPyELo9bqLifZMB38Om
         zIHzwtyudwgMbIgYSZb9lkblYNIX3/WVagXgaeQyU41QR7aoJi3X3rOjHI61GSUXFRn0
         4MuH+MjP2/zjRqlbL/HQi0jK/+rkOllmFqArYzVpmXshlrGu0Hd8sZ0jIt2byuZQy1QY
         PBTL9kRxo6KctYuQuUPUXSOwCxmvJ93OHrCd/3RoBX1m9DdaNulAF3ScAPG+fiGZLpi2
         +FBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KmfkUDcbXBjuwj5yzcQuQKQgi24UD03tulJmJMc6gMA=;
        b=y5yKqbFEcVaLrI4bxT+HImoBaO/Hfk/hfg8Pju7JiXPTG+esTil+VNyu8eVCxC3IVt
         MsBpA7Qsc18KY9tr6p6s41YqPQ4Tv6dF7eYSNNpanIEFoOdTjtdZUkOaF72ePATbGxCB
         ZTrevG1Baf2C9Ist7JIvU/GjOkX37Dxn2Y/hxq5X7M3nwLY8vMcL0mS3wqoVOdxJvS4e
         RHtOuOxyEA2hwPvMdCmWxF+zQIIrDr8YXKPffjgReUS0BHHD45jOG3Ec3bkVXlZV82qN
         I9uOnvvSiQaunoRETatV8VsiHPN+Y/wqNou81SVJCitKN6w2by4f1orxTbn0mOWsqgs6
         jw8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z20si3637089pfa.282.2019.06.14.17.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 17:29:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 17:29:25 -0700
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by fmsmga008-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 17:29:25 -0700
Date: Fri, 14 Jun 2019 17:32:31 -0700
From: Alison Schofield <alison.schofield@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
Message-ID: <20190615003231.GA15479@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
 <20190614115137.GF3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614115137.GF3436@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 01:51:37PM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:44:05PM +0300, Kirill A. Shutemov wrote:
snip
> >  /*
> > - * When pkey==NO_KEY we get legacy mprotect behavior here.
> > + * do_mprotect_ext() supports the legacy mprotect behavior plus extensions
> > + * for Protection Keys and Memory Encryption Keys. These extensions are
> > + * mutually exclusive and the behavior is:
> > + *	(pkey==NO_KEY && keyid==NO_KEY) ==> legacy mprotect
> > + *	(pkey is valid)  ==> legacy mprotect plus Protection Key extensions
> > + *	(keyid is valid) ==> legacy mprotect plus Encryption Key extensions
> >   */
> >  static int do_mprotect_ext(unsigned long start, size_t len,
> > -		unsigned long prot, int pkey)
> > +			   unsigned long prot, int pkey, int keyid)
> >  {

snip

>
> I've missed the part where pkey && keyid results in a WARN or error or
> whatever.
> 
I wasn't so sure about that since do_mprotect_ext()
is the call 'behind' the system calls. 

legacy mprotect always calls with: NO_KEY, NO_KEY
pkey_mprotect always calls with:  pkey, NO_KEY
encrypt_mprotect always calls with  NO_KEY, keyid

Would a check on those arguments be debug only 
to future proof this?

