Message-ID: <46B3D34B.6010105@sgi.com>
Date: Fri, 03 Aug 2007 18:15:55 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/1] x86: Convert cpuinfo_x86 array to a per_cpu array
 v3
References: <20070924210853.256462000@sgi.com> <20071016011827.91350174.akpm@linux-foundation.org>
In-Reply-To: <20071016011827.91350174.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
...
>> ...  This patch deals with the cpu_data array of
>> cpuinfo_x86 structs.  The model that was used in sparc64
>> architecture was adopted for x86.
>>
> 
> This has mysteriously started to oops on me, only on x86_64.
> 
> http://userweb.kernel.org/~akpm/config-x.txt
> http://userweb.kernel.org/~akpm/dsc00001.jpg
> 
> which is a bit strange since this patch doesn't touch sched.c.  Maybe
> there's something somewhere else in the -mm lineup which when combined with
> this prevents it from oopsing, dunno.  I'll hold it back for now and will
> see what happens.
> 

I'll take a look at this right away.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
