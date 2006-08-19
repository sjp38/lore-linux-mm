Received: by py-out-1112.google.com with SMTP id c59so2120334pyc
        for <linux-mm@kvack.org>; Sat, 19 Aug 2006 09:53:54 -0700 (PDT)
Message-ID: <2c0942db0608190953r71ad8716vc2d11d9366894e40@mail.gmail.com>
Date: Sat, 19 Aug 2006 09:53:54 -0700
From: "Ray Lee" <madrabbit@gmail.com>
Reply-To: ray-gmail@madrabbit.org
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
In-Reply-To: <20060818194435.25bacee0.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20060808211731.GR14627@postel.suug.ch>
	 <20060813215853.0ed0e973.akpm@osdl.org> <44E3E964.8010602@google.com>
	 <20060816225726.3622cab1.akpm@osdl.org> <44E5015D.80606@google.com>
	 <20060817230556.7d16498e.akpm@osdl.org> <44E62F7F.7010901@google.com>
	 <20060818153455.2a3f2bcb.akpm@osdl.org> <44E650C1.80608@google.com>
	 <20060818194435.25bacee0.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Daniel Phillips <phillips@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, riel@redhat.com, tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

On 8/18/06, Andrew Morton <akpm@osdl.org> wrote:
>   I assert that this can be solved by putting swap on local disks.  Peter
>   asserts that this isn't acceptable due to disk unreliability.  I point
>   out that local disk reliability can be increased via MD, all goes quiet.
>
>   A good exposition which helps us to understand whether and why a
>   significant proportion of the target user base still wishes to do
>   swap-over-network would be useful.

Adding a hard drive adds $low per system, another failure point, and
more importantly ~3-10 Watts which then has to be paid for twice (once
to power it, again to cool it). For a hundred seats, that's
significant. For 500, it's ranging toward fully painful.

I'm in the process of designing the next upgrade for a VoIP call
center, and we want to go entirely diskless in the agent systems. We'd
also rather not swap over the network, but 'swap is as swap does.'

That said, it in no way invalidates using /proc/sys/vm/min_free_kbytes...

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
