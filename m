Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1336B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:26:59 -0500 (EST)
Message-ID: <498B3D80.1010206@goop.org>
Date: Thu, 05 Feb 2009 11:26:56 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: pud_bad vs pud_bad
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu> <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu>
In-Reply-To: <20090205191017.GF20470@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: William Lee Irwin III <wli@holomorphy.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> But the 32-bit check does the exact same thing but via a single binary 
> operation: it checks whether any bits outside of those bits are zero - just 
> via a simpler test that compiles to more compact code.
>
> So i'd go with the 32-bit version. (unless there are some sign-extension 
> complications i'm missing - but i think we got rid of those already.)

OK, fair enough.  I wouldn't be surprised if gcc does that transform 
anyway, but we may as well be consistent about it.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
