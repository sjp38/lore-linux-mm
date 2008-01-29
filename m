Message-ID: <479F8F83.2030809@qumranet.com>
Date: Tue, 29 Jan 2008 22:41:39 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [patch 1/6] mmu_notifier: Core code
References: <20080128202840.974253868@sgi.com> <20080128202923.609249585@sgi.com> <20080129135914.GF7233@v2.random> <Pine.LNX.4.64.0801291148080.24807@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0801291148080.24807@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 29 Jan 2008, Andrea Arcangeli wrote:
>
>   
>>> +	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
>>>  };
>>>       
>> Not sure why you prefer to waste ram when MMU_NOTIFIER=n, this is a
>> regression (a minor one though).
>>     
>
> Andrew does not like #ifdefs and it makes it possible to verify calling 
> conventions if !CONFIG_MMU_NOTIFIER.
>
>   

You could define mmu_notifier_head as an empty struct in that case.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
