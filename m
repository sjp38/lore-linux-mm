Message-ID: <404D5EED.80105@cyberone.com.au>
Date: Tue, 09 Mar 2004 17:06:37 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/4] vm-mapped-x-active-lists
References: <404D56D8.2000008@cyberone.com.au> <404D5784.9080004@cyberone.com.au> <404D5A6F.4070300@matchmail.com>
In-Reply-To: <404D5A6F.4070300@matchmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Fedyk <mfedyk@matchmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Mike Fedyk wrote:

> Nick Piggin wrote:
>
>>
>>
>> ------------------------------------------------------------------------
>>
>>
>> Split the active list into mapped and unmapped pages.
>
>
> This looks similar to Rik's Active and Active-anon lists in 2.4-rmap.
>

Oh? I haven't looked at 2.4-rmap for a while. Well I guess that gives
it more credibility, thanks.

> Also, how does this interact with Andrea's VM work?
>

Not sure to be honest, I haven't looked at it :\. I'm not really
sure if the rmap mitigation direction is just a holdover until
page clustering or intended as a permanent feature...

Either way, I trust its proponents will take the onus for regressions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
