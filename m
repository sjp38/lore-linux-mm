Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id EA15C6B016E
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 12:12:16 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id rr4so878566pbb.11
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 09:12:16 -0800 (PST)
Received: from psmtp.com ([74.125.245.114])
        by mx.google.com with SMTP id d2si3654302pac.242.2013.11.07.09.12.12
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 09:12:13 -0800 (PST)
Message-ID: <527BC98B.5060701@redhat.com>
Date: Thu, 07 Nov 2013 12:10:35 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zsmalloc: Ensure handle is never 0 on success
References: <20131107070451.GA10645@bbox>
In-Reply-To: <20131107070451.GA10645@bbox>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, lliubbo@gmail.com, jmarchan@redhat.com, mgorman@suse.de, hughd@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On 11/07/2013 02:04 AM, Minchan Kim wrote:

> I'm guilty and I have been busy by other stuff. Sorry for that.
> Fortunately, I discussed this issue with Hugh in this Linuxcon for a
> long time(Thanks Hugh!) he felt zram's block device abstraction is
> better design rather than frontswap backend stuff although it's a question
> where we put zsmalloc. I will CC Hugh because many of things is related
> to swap subsystem and his opinion is really important.
> And I discussed it with Rik and he feel positive about zram.

To clarify that, I agree with Minchan that there are certain
workloads where zram is probably more appropriate than zswap.

For most of the workloads that I am interested in, zswap will
be more interesting, but zram seems to have its own niche, and
I certainly do not want to hold back the embedded folks...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
