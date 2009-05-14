Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4A2296B0176
	for <linux-mm@kvack.org>; Wed, 13 May 2009 23:51:15 -0400 (EDT)
From: Sheng Yang <sheng@linux.intel.com>
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to 64 bits in X86_64
Date: Thu, 14 May 2009 11:52:28 +0800
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com> <4A0AFB7D.2080105@zytor.com> <4A0B036B.7000107@zytor.com>
In-Reply-To: <4A0B036B.7000107@zytor.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905141152.29378.sheng@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thursday 14 May 2009 01:29:15 H. Peter Anvin wrote:
> H. Peter Anvin wrote:
> > H. Peter Anvin wrote:
> >> Sheng Yang wrote:
> >>> This fix 44/45 bit width memory can't boot up issue. The reason is
> >>> free_bootmem_node()->mark_bootmem_node()->__free() use
> >>> test_and_clean_bit() to clean node_bootmem_map, but for 44bits width
> >>> address, the idx set bit 31 (43 - 12), which consider as a nagetive
> >>> value for bts.
> >>>
> >>> This patch applied to tip/mm.
> >>
> >> Hi Sheng,
> >>
> >> Could you try the attached patch instead?
> >
> > Sorry, wrong patch entirely... here is the right one.
>
> This time, for real?  Sheesh.  I'm having a morning, apparently.
>
> 	-hpa

Yeah, this one also works well(lightly tested). :)

But one thing should be noticed that, bit ops recognized the input as signed. 
According to SDM 2A 3.1.1.7 Operation Section, Bit(BitBase, BitOffset) can 
accept BitOffset as negative value, then search backward... Well, I indeed 
don't know when we need this, but I think keep signed here should be better...

-- 
regards
Yang, Sheng 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
