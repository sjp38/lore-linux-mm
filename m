Message-ID: <4790A29F.9000006@sgi.com>
Date: Fri, 18 Jan 2008 04:59:11 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] x86: Reduce memory and intra-node effects with	large
 count NR_CPUs fixup
References: <20080117223546.419383000@sgi.com> <478FD9D9.7030009@sgi.com> <20080118092352.GH24337@elte.hu>
In-Reply-To: <20080118092352.GH24337@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Mike Travis <travis@sgi.com> wrote:
> 
>> Hi Andrew,
>>
>> My automatic scripts accidentally sent this mail prematurely.  Please 
>> hold off applying yet.
> 
> I've picked it up for x86.git and i'll keep testing it (the patches seem 
> straightforward) and will report any problems with the bite-head-off 
> option unset.
> 
> [ The 32-bit NUMA compile issue is orthogonal to these patches - it's 
>   due to the lack of 32-bit NUMA support in your changes :) That needs 
>   fixing before this could go into v2.6.25. ]
> 
> 	Ingo

I hadn't considered doing 32-bit NUMA changes as I didn't know if the
NR_CPUS count would really be increased for the 32-bit architecture.
I have been trying though not to break it. ;-)

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
