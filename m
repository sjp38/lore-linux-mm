Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CA49F6B0105
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 15:40:29 -0400 (EDT)
Received: by gyg13 with SMTP id 13so289759gyg.14
        for <linux-mm@kvack.org>; Tue, 28 Jun 2011 12:40:26 -0700 (PDT)
Message-ID: <4E0A2E26.5000001@gmail.com>
Date: Tue, 28 Jun 2011 12:40:22 -0700
From: David Daney <ddaney.cavm@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
References: <20110626193918.GA3339@joi.lan> <alpine.DEB.2.00.1106281431370.27518@router.home>
In-Reply-To: <alpine.DEB.2.00.1106281431370.27518@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Marcin Slusarz <marcin.slusarz@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/28/2011 12:32 PM, Christoph Lameter wrote:
> On Sun, 26 Jun 2011, Marcin Slusarz wrote:
>
>> slub checks for poison one byte by one, which is highly inefficient
>> and shows up frequently as a highest cpu-eater in perf top.
>
> Ummm.. Performance improvements for debugging modes? If you need
> performance then switch off debuggin.

There is no reason to make things gratuitously slow.  I don't know about 
the merits of this particular patch, but I must disagree with the 
general sentiment.

We have high performance tracing, why not improve this as well.

Just last week I was trying to find the cause of memory corruption that 
only occurred at very high network packet rates.  Memory allocation 
speed was definitely getting in the way of debugging.  For me, faster 
SLUB debugging would be welcome.

David Daney

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
