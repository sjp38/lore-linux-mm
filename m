Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 850A16B01B1
	for <linux-mm@kvack.org>; Mon, 24 May 2010 06:51:50 -0400 (EDT)
Message-ID: <4BFA5A3F.4040005@redhat.com>
Date: Mon, 24 May 2010 13:51:43 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: Swap checksum
References: <4BF81D87.6010506@cesarb.net> <1274551731-4534-3-git-send-email-cesarb@cesarb.net> <4BF94792.5030405@redhat.com> <4BF97AC2.1040505@cesarb.net> <4BFA1F92.2080802@redhat.com> <20100524073259.GW2516@laptop>
In-Reply-To: <20100524073259.GW2516@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 05/24/2010 10:32 AM, Nick Piggin wrote:
>
> I wonder, though. If we no longer trust block devices to give the
> correct data back, should we provide a meta block device to do error
> detection?

Some block devices do provide space for end-to-end checksums.  For the 
ones that don't, I see no efficient way of adding it (either we turn one 
access into two, or we have a non-power-of-two block size).

> No production filesystem on Linux has checksums (well, ext4
> has a few). Of the ones that add checksumming, I'd say most will not do
> data checksumming (and for direct IO it is not done).
>    

I believe btrfs checksums direct IO.  Unfortunately it has some way to 
go before it can be used in production.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
