Message-ID: <47840D00.8000907@sgi.com>
Date: Tue, 08 Jan 2008 15:53:36 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] percpu: Per cpu code simplification V3
References: <20080108021142.585467000@sgi.com> <20080108090702.GB27671@elte.hu> <Pine.LNX.4.64.0801081102450.2228@schroedinger.engr.sgi.com> <20080108221646.GC21482@elte.hu>
In-Reply-To: <20080108221646.GC21482@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Christoph Lameter <clameter@sgi.com> wrote:
> 
>> On Tue, 8 Jan 2008, Ingo Molnar wrote:
>>
>>> i had the patch below for v2, it's still needed (because i didnt 
>>> apply the s390/etc. bits), right?
>> Well the patch really should go through mm because it is a change that 
>> covers multiple arches. I think testing with this is fine. I think 
>> Mike has diffed this against Linus tree so this works but will now 
>> conflict with the modcopy patch already in mm.
> 
> well we cannot really ack it for x86 inclusion without having tested it 
> through, so it will stay in x86.git for some time. That approach found a 
> few problems with v1 already. In any case, v3 is looking pretty good so 
> far - and it's cool stuff - i'm all for unifying/generalizing arch code.
> 
> 	Ingo

Hi Ingo,

You probably will want to pick up V4 though I didn't add that ifndef
patch you mentioned earlier.  There are no functional changes, basically
only a rebasing on the correct mm version.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
