Message-ID: <47926DFA.5020601@sgi.com>
Date: Sat, 19 Jan 2008 13:39:06 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX
References: <20080118183011.354965000@sgi.com> <20080118183011.917801000@sgi.com> <20080119145243.GA27974@elte.hu>
In-Reply-To: <20080119145243.GA27974@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * travis@sgi.com <travis@sgi.com> wrote:
> 
>> Adds and increases some config variables to accomodate larger SMP
>> configurations:
>>
>> 	NR_CPUS:      max limit now 4096
>> 	NODES_SHIFT:  max limit now 9
>> 	THREAD_ORDER: max limit now 3
>> 	X86_SMP_MAX:  say Y to enable possible cpus == NR_CPUS
>>
>> Signed-off-by: Mike Travis <travis@sgi.com>
> 
> i've bisected a boot failure down to this patch (sans the THREAD_ORDER 
> bits): it causes an instant reboot of the 64-bit kernel upon bootup. 
> Failing config attached.
> 
> 	Ingo
> 

Thanks Ingo! 

I've pulled the THREAD_ORDER change from my next version of the patch.
Seems SMP_MAX is just not ready for prime time yet.

One problem that I'm having appears to be that the !NUMA config of the
current -mm version also doesn't boot so I haven't been able to verify
that.  (At least it doesn't seem to make it worse... ;-)

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
