Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A30EA900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:06:54 -0400 (EDT)
Message-ID: <4E023D3E.1090408@zytor.com>
Date: Wed, 22 Jun 2011 12:06:38 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>	<20110622110034.89ee399c.akpm@linux-foundation.org>	<4E0230CD.1030505@zytor.com> <BANLkTinMrMcDw8KX3BxmZh12-kULmecT-s9gdRGpYUCfNjFO7Q@mail.gmail.com>
In-Reply-To: <BANLkTinMrMcDw8KX3BxmZh12-kULmecT-s9gdRGpYUCfNjFO7Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nancy Yuen <yuenn@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, rick@vanrein.org, rdunlap@xenotime.net, Michael Ditto <mditto@google.com>

On 06/22/2011 12:01 PM, Nancy Yuen wrote:
> 
> Good point.  There's the MAX_NODES that expands it, though it's still
> hard coded, and as I understand, intended for NUMA node entries.  We
> need anywhere from 8K to 64K 'bad' entries.  This creates holes and
> translates to twice as many entries in the e820.  We only want to
> allow this memory if it's needed, instead of hard coding it.
> 

It should be dynamic, probably.  We can waste memory during early
reclaim, but the memblock stuff should be dynamic.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
