Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id DF0FC6B0075
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 12:02:53 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so93526545igb.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:02:53 -0700 (PDT)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id mv8si8775571igb.62.2015.04.28.09.02.52
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 09:02:52 -0700 (PDT)
Message-ID: <553FAF26.9060609@sgi.com>
Date: Tue, 28 Apr 2015 11:02:46 -0500
From: nzimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/13] mm: meminit: Move page initialization into a separate
 function.
References: <1429785196-7668-1-git-send-email-mgorman@suse.de> <1429785196-7668-3-git-send-email-mgorman@suse.de> <20150427154633.2134d804987dad88e008c2ff@linux-foundation.org> <20150428082831.GI2449@suse.de>
In-Reply-To: <20150428082831.GI2449@suse.de>
Content-Type: text/plain; charset="iso-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

This is the one I have, but I haven't had a chance to talk with him in a 
long time.
robinmholt@gmail.com

On 04/28/2015 03:28 AM, Mel Gorman wrote:
> On Mon, Apr 27, 2015 at 03:46:33PM -0700, Andrew Morton wrote:
>> On Thu, 23 Apr 2015 11:33:05 +0100 Mel Gorman <mgorman@suse.de> wrote:
>>
>>> From: Robin Holt <holt@sgi.com>
>> : <holt@sgi.com>: host cuda-allmx.sgi.com[192.48.157.12] said: 550 cuda_nsu 5.1.1
>> :    <holt@sgi.com>: Recipient address rejected: User unknown in virtual alias
>> :    table (in reply to RCPT TO command)
>>
>> Has Robin moved, or is SGI mail busted?
> Robin has moved and I do not have an updated address for him. The
> address used in the patches was the one he posted the patches with.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
