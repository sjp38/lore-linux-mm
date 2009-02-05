Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 747F86B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:32:08 -0500 (EST)
Date: Thu, 5 Feb 2009 20:31:21 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pud_bad vs pud_bad
Message-ID: <20090205193121.GA31839@elte.hu>
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu> <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu> <498B3D80.1010206@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <498B3D80.1010206@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Ingo Molnar wrote:
>> But the 32-bit check does the exact same thing but via a single binary  
>> operation: it checks whether any bits outside of those bits are zero - 
>> just via a simpler test that compiles to more compact code.
>>
>> So i'd go with the 32-bit version. (unless there are some 
>> sign-extension complications i'm missing - but i think we got rid of 
>> those already.)
>
> OK, fair enough.  I wouldn't be surprised if gcc does that transform 
> anyway, but we may as well be consistent about it.

i checked and it doesnt - at least 4.3.2 inserts an extra AND instruction. 
So the 32-bit version is really better. (beyond being more readable)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
