Message-ID: <480FA4A9.4090403@qumranet.com>
Date: Thu, 24 Apr 2008 00:05:45 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04 of 12] Moves all mmu notifier methods outside the PT
 lock (first and not last
References: <ac9bb1fb3de2aa5d2721.1208872280@duo.random> <Pine.LNX.4.64.0804221323510.3640@schroedinger.engr.sgi.com> <20080422224048.GR24536@duo.random> <Pine.LNX.4.64.0804221613570.4868@schroedinger.engr.sgi.com> <20080423134427.GW24536@duo.random> <20080423154536.GV30298@sgi.com>
In-Reply-To: <20080423154536.GV30298@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:
>> an hurry like we are, we can't progress without this. Infact we can
>>     
>
> SGI is under an equally strict timeline.  We really needed the sleeping
> version into 2.6.26.  We may still be able to get this accepted by
> vendor distros if we make 2.6.27.
>   

The difference is that the non-sleeping variant can be shown not to 
affect stability or performance, even if configed in, as long as its not 
used.  The sleeping variant will raise performance and stability concerns.

I have zero objections to sleeping mmu notifiers; I only object to tying 
the schedules of the two together.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
