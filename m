From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] mm: use pagevec to rotate reclaimable page
Date: Tue, 18 Sep 2007 11:29:50 +1000
References: <6.0.0.20.2.20070907113025.024dfbb8@172.19.0.2> <20070913193711.ecc825f7.akpm@linux-foundation.org> <6.0.0.20.2.20070918193944.038e2ea0@172.19.0.2>
In-Reply-To: <6.0.0.20.2.20070918193944.038e2ea0@172.19.0.2>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709181129.50253.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 18 September 2007 20:41, Hisashi Hifumi wrote:
> I modified my patch based on your comment.
>
> At 11:37 07/09/14, Andrew Morton wrote:
>  >So I do think that for safety and sanity's sake, we should be taking a
>  > ref on the pages when they are in a pagevec.  That's going to hurt your
>  > nice performance numbers :(
>
> I did ping test again to observe performance deterioration caused by taking
> a ref.
>
> 	-2.6.23-rc6-with-modifiedpatch
> 	--- testmachine ping statistics ---
> 	3000 packets transmitted, 3000 received, 0% packet loss, time 53386ms
> 	rtt min/avg/max/mdev = 0.074/0.110/4.716/0.147 ms, pipe 2, ipg/ewma
> 17.801/0.129 ms
>
> The result for my original patch is as follows.
>
> 	-2.6.23-rc5-with-originalpatch
> 	--- testmachine ping statistics ---
> 	3000 packets transmitted, 3000 received, 0% packet loss, time 51924ms
> 	rtt min/avg/max/mdev = 0.072/0.108/3.884/0.114 ms, pipe 2, ipg/ewma
> 17.314/0.091 ms
>
>
> The influence to response was small.

It would be interesting to test -mm kernels. They have a patch which reduces
zone lock contention quite a lot.

I think your patch is a nice idea, and with less zone lock contention in other
areas, it is possible that it might produce a relatively larger improvement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
