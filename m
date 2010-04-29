Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 65D4D6B0214
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 15:02:06 -0400 (EDT)
Message-ID: <4BD9D7A5.1070003@redhat.com>
Date: Thu, 29 Apr 2010 22:01:57 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default> <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default> <4BD3377E.6010303@redhat.com> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com> <ce808441-fae6-4a33-8335-f7702740097a@default 20100428055538.GA1730@ucw.cz> <c2744f69-5974-4017-ae33-4244ce0960e2@default> <4BD9D702.90209@redhat.com>
In-Reply-To: <4BD9D702.90209@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/29/2010 09:59 PM, Avi Kivity wrote:
>
> I'm convinced it's useful.  The API is so close to a block device 
> (read/write with key/value vs read/write with sector/value) that we 
> should make the effort not to introduce a new API.
>

Plus of course the asynchronity and batching of the block layer.  Even 
if you don't use a dma engine, you improve performance by exiting one 
per several dozen pages instead of for every page, perhaps enough to 
allow the hypervisor to justify copying the memory with non-temporal moves.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
