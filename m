Subject: Re: [PATCH] mm: yield during swap prefetching
From: Lee Revell <rlrevell@joe-job.com>
In-Reply-To: <200603081228.05820.kernel@kolivas.org>
References: <200603081013.44678.kernel@kolivas.org>
	 <200603081212.03223.kernel@kolivas.org>
	 <20060307172337.1d97cd80.akpm@osdl.org>
	 <200603081228.05820.kernel@kolivas.org>
Content-Type: text/plain
Date: Tue, 07 Mar 2006 21:08:30 -0500
Message-Id: <1141783711.767.121.camel@mindpipe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-03-08 at 12:28 +1100, Con Kolivas wrote:
> I can't distinguish between when cpu activity is important (game) and when it 
> is not (compile), and assuming worst case scenario and not doing any swap 
> prefetching is my intent. I could add cpu accounting to prefetch_suitable() 
> instead, but that gets rather messy and yielding achieves the same endpoint. 

Shouldn't the game be running with RT priority or at least at a low nice
value?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
