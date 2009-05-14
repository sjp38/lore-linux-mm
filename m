Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 910036B01BD
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:09:30 -0400 (EDT)
Message-ID: <4A0C2614.4010803@zytor.com>
Date: Thu, 14 May 2009 07:09:24 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to
 64 bits in X86_64
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com> <4A0AFB7D.2080105@zytor.com> <4A0B036B.7000107@zytor.com> <200905141152.29378.sheng@linux.intel.com>
In-Reply-To: <200905141152.29378.sheng@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sheng Yang <sheng@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Sheng Yang wrote:
> 
> Yeah, this one also works well(lightly tested). :)
> 
> But one thing should be noticed that, bit ops recognized the input as signed. 
> According to SDM 2A 3.1.1.7 Operation Section, Bit(BitBase, BitOffset) can 
> accept BitOffset as negative value, then search backward... Well, I indeed 
> don't know when we need this, but I think keep signed here should be better...
> 

Urk, you're right.  How daft.  I had preferred to switch it to unsigned
long to match MIPS and SPARC, but that probably is a good reason to
leave it signed.  Pain.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
