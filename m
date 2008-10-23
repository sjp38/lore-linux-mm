Date: Thu, 23 Oct 2008 06:40:43 -0700 (PDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <E1KsviY-0003Mq-6M@pomaz-ex.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0810230638450.11924@quilx.com>
References: <1223883004.31587.15.camel@penberg-laptop>
 <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu>  <48FE6306.6020806@linux-foundation.org>
  <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810220822500.30851@quilx.com>
  <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221252570.3562@quilx.com>
  <E1Ksk3g-00027r-Lp@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221315080.26671@quilx.com>
  <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu>  <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
  <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221416130.26639@quilx.com>
  <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu> <1224745831.25814.21.camel@penberg-laptop>
 <E1KsviY-0003Mq-6M@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Oct 2008, Miklos Szeredi wrote:

> I think the _real_ problem is that instead of fancy features like this
> defragmenter, SLUB should first concentrate on getting the code solid
> enough to replace the other allocators.

Solid? What is not solid? The SLUB design was made in part because of the 
defrag problems that were not easy to solve with SLAB. The ability to lock 
down a slab allows stabilizing objects. We discussed solutions to the 
fragmentation problem for years and did not get anywhere with SLAB.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
