Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6B18C6B01AC
	for <linux-mm@kvack.org>; Sat,  3 Jul 2010 07:56:17 -0400 (EDT)
Message-ID: <4C2F255D.6000908@kernel.dk>
Date: Sat, 03 Jul 2010 13:56:13 +0200
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 16321] New: os unresponsive during buffered
  I/O
References: <bug-16321-10286@https.bugzilla.kernel.org/> <20100702160501.45861821.akpm@linux-foundation.org>
In-Reply-To: <20100702160501.45861821.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/07/10 01.05, Andrew Morton wrote:
> On Thu, 1 Jul 2010 11:57:37 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=16321
>>
>>            Summary: os unresponsive during buffered I/O
>>            Product: IO/Storage
>>            Version: 2.5
>>     Kernel Version: 2.6.34
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Block Layer
>>         AssignedTo: axboe@kernel.dk
>>         ReportedBy: rrs@researchut.com
>>         Regression: No
>>
>>
>> I have been running these tests on my laptop running the 2.6.34 Debian kernel.
>> When doing buffered I/O, the OS completely stalls to any interactivity. I
>> cannot switch console tabs in my Desktop Environment and the mouse pointer does
>> not move.
>>
>> Eventually, I/O completes and every thing resumes to normal. There is no OOM
>> seen during the I/O operation.
>> If doing direct I/O, interactivity does not get penalized.
>>
> 
> 1...
> 
> 2...
> 
> 3...
> 
> FUCK!!!
> 
> We've been trying to fix this stuff for ten years.  Apparently, without
> success.  Do we suck, or what?

We suck. This is assigned to the block layer, but it must be something
a lot more fundemental than this. Either the vm is shitting itself, or
something else is sucking up the juice completely. Or the CPU scheduler
is going to pieces, I dunno. The report says that he cannot even move the
mouse or switch console tabs, clearly we are not (only) dealing with
an issue at the IO side.

What else is interesting is that only a few people seem to see this.
What is different about their setup or their hardware?! I cannot
reproduce reports like this, and if it happened for everybody for
a simple 4 process random write like this, then everything would
grind to a halt.

I propose we fly Andrew out to investigate in person :-)

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
