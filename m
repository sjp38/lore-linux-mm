Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1056B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 19:08:36 -0500 (EST)
Message-ID: <498B7F7F.3090701@goop.org>
Date: Thu, 05 Feb 2009 16:08:31 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: pud_bad vs pud_bad
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu> <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu> <Pine.LNX.4.64.0902051921150.30938@blonde.anvils> <498B4F1F.5070306@goop.org> <Pine.LNX.4.64.0902052046240.18431@blonde.anvils> <498B54A0.7040005@goop.org> <20090205215050.GB28097@elte.hu> <498B6325.1040401@goop.org> <20090205234241.GA14203@elte.hu>
In-Reply-To: <20090205234241.GA14203@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Hugh Dickins <hugh@veritas.com>, William Lee Irwin III <wli@movementarian.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> just the act of using PAE was measured to cause multi-percent slowdown in 
> fork() and exec() latencies, etc. The pagetables are twice as large so is 
> that really surprising?
>   

Is there a similar slowdown running the CPU in 32 vs 64 bit mode?  Or 
does having more/wider registers mitigate it?

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
