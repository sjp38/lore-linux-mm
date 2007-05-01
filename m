Received: by ug-out-1314.google.com with SMTP id s2so73758uge
        for <linux-mm@kvack.org>; Tue, 01 May 2007 10:12:28 -0700 (PDT)
Message-ID: <84144f020705011012w53a39500of8e9a02b266a59d9@mail.gmail.com>
Date: Tue, 1 May 2007 20:12:28 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: 2.6.22 -mm merge plans
In-Reply-To: <p73y7k8ybvi.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	 <84144f020705010217j738e461ey6b09fd738574fb70@mail.gmail.com>
	 <p73y7k8ybvi.fsf@bingen.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hch@lst.de, npiggin@suse.de, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Hi Andi,

On 01 May 2007 14:19:45 +0200, Andi Kleen <andi@firstfloor.org> wrote:
> Also have the cache performance concerns raised on the original review
> been addressed?

I am only aware of the fget_light() related issues Eric Dumazet raised
but it's fixed. If you're thinking of something else, could you please
remind me what it is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
