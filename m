Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FCA36B025E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 14:34:19 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u74so77349699lff.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 11:34:19 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id f5si36285918wje.247.2016.06.14.11.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 11:34:18 -0700 (PDT)
Date: Tue, 14 Jun 2016 19:34:07 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
Message-ID: <20160614193407.1470d998@lxorguk.ukuu.org.uk>
In-Reply-To: <57603DC0.9070607@linux.intel.com>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
	<1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
	<57603DC0.9070607@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, hpa@zytor.com, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com

On Tue, 14 Jun 2016 10:24:16 -0700
Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 06/14/2016 10:01 AM, Lukasz Anaczkowski wrote:
> > v2 (Lukasz Anaczkowski):
> >     () fixed compilation breakage  
> ...
> 
> By unconditionally defining the workaround code, even on kernels where
> there is no chance of ever hitting this bug.  I think that's a pretty
> poor way to do it.
> 
> Can we please stick this in one of the intel.c files, so it's only
> present on CPU_SUP_INTEL builds?

Can we please make it use alternatives or somesuch so that it just goes
away at boot if its not a Knights Landing box ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
