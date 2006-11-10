Received: by ug-out-1314.google.com with SMTP id s2so388448uge
        for <linux-mm@kvack.org>; Thu, 09 Nov 2006 17:56:37 -0800 (PST)
Message-ID: <661de9470611091756i3b2a4c7er85e5a581cadfc276@mail.gmail.com>
Date: Fri, 10 Nov 2006 07:26:37 +0530
From: "Balbir Singh" <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
Subject: Re: [ckrm-tech] [RFC][PATCH 8/8] RSS controller support reclamation
In-Reply-To: <1163101543.3138.528.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com>
	 <20061109193636.21437.11778.sendpatchset@balbir.in.ibm.com>
	 <1163101543.3138.528.camel@laptopd505.fenrus.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: dev@openvz.org, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

On 11/10/06, Arjan van de Ven <arjan@infradead.org> wrote:
> On Fri, 2006-11-10 at 01:06 +0530, Balbir Singh wrote:
> >
> > Reclaim memory as we hit the max_shares limit. The code for reclamation
> > is inspired from Dave Hansen's challenged memory controller and from the
> > shrink_all_memory() code
>
>
> Hmm.. I seem to remember that all previous RSS rlimit attempts actually
> fell flat on their face because of the reclaim-on-rss-overflow behavior;
> in the shared page / cached page (equally important!) case, it means
> process A (or container A) suddenly penalizes process B (or container B)
> by making B have pagecache misses because A was using a low RSS limit.
>
> Unmapping the page makes sense, sure, and even moving then to inactive
> lists or whatever that is called in the vm today, but reclaim... that's
> expensive...
>

I see your point, one of things we could do is that we could track
shared and cached pages separately and not be so severe on them.

I'll play around with this idea and see what I come up with.

Thanks for the feedback,
Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
