Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2D06B00BC
	for <linux-mm@kvack.org>; Tue, 19 May 2015 10:06:33 -0400 (EDT)
Received: by obfe9 with SMTP id e9so12878184obf.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 07:06:33 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id o132si8636370oia.63.2015.05.19.07.06.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 07:06:32 -0700 (PDT)
Message-ID: <1432043228.25898.0.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 19 May 2015 07:47:08 -0600
In-Reply-To: <20150519132307.GG4641@pd.tnic>
References: <1431714237-880-7-git-send-email-toshi.kani@hp.com>
	 <20150518133348.GA23618@pd.tnic>
	 <1431969759.19889.5.camel@misato.fc.hp.com>
	 <20150518190150.GC23618@pd.tnic>
	 <1431977519.20569.15.camel@misato.fc.hp.com>
	 <20150518200114.GE23618@pd.tnic>
	 <1431980468.21019.11.camel@misato.fc.hp.com>
	 <20150518205123.GI23618@pd.tnic>
	 <1431985994.21526.12.camel@misato.fc.hp.com>
	 <20150519114437.GF4641@pd.tnic> <20150519132307.GG4641@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com

On Tue, 2015-05-19 at 15:23 +0200, Borislav Petkov wrote:
> On Tue, May 19, 2015 at 01:44:37PM +0200, Borislav Petkov wrote:
> > > Try with a smaller page size.
> > > 
> > > The callers, pud_set_huge() and pmd_set_huge(), check if the given range
> > > is safe with MTRRs for creating a huge page mapping.  If not, they fail
> > > the request, which leads their callers, ioremap_pud_range() and
> > > ioremap_pmd_range(), to retry with a smaller page size, i.e. 1GB -> 2MB
> > > -> 4KB.  4KB may not have overlap with MTRRs (hence no checking is
> > > necessary), which will succeed as before.
> 
> Scratch that, I think I have it now. And I even have a good feeling
> about it :-)

Looks good. Thanks for the update!
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
