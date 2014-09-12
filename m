Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C6BB56B0038
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 15:07:36 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so1879935pab.32
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 12:07:36 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id al3si9488869pad.211.2014.09.12.12.07.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 12:07:35 -0700 (PDT)
Message-ID: <54134464.1010809@zytor.com>
Date: Fri, 12 Sep 2014 12:07:16 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 07/10] x86, mpx: decode MPX instruction to get bound
 violation information
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-8-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120015030.4178@nanos> <5412230A.6090805@intel.com> <541223B1.5040705@zytor.com> <alpine.DEB.2.10.1409121949460.4178@nanos>
In-Reply-To: <alpine.DEB.2.10.1409121949460.4178@nanos>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>, Qiaowei Ren <qiaowei.ren@intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/12/2014 10:52 AM, Thomas Gleixner wrote:
> 
> Well, I did not see the trainwreck which tried to use the generic
> decoder, but as I explained in the other mail, there is no reason not
> to use it and I can't see any complexity in retrieving the data beyond
> calling insn_get_length(insn);
> 

Looking at how complex the state machine ended up being, it probably was
the wrong direction.  It is safe to copy_from_user() 15 bytes, decode
what we get (which may be less than 15 bytes) and then verify with
insn_get_length() that what we decoded is actually what we copied if the
copy_from_user() length is < 15.

My intent was to explore a state machine limited to the restricted "mib"
encodings that are valid for BNDSTX and BNDLDX only, but in the end it
really doesn't make enough difference that it is worth messing with, I
don't think.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
