Message-ID: <45D972CC.2010702@sw.ru>
Date: Mon, 19 Feb 2007 12:50:04 +0300
From: Kirill Korotaev <dev@sw.ru>
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [RFC][PATCH][0/4] Memory controller (RSS Control)
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop>	<20070219005441.7fa0eccc.akpm@linux-foundation.org> <6599ad830702190106m3f391de4x170326fef2e4872@mail.gmail.com>
In-Reply-To: <6599ad830702190106m3f391de4x170326fef2e4872@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, Balbir Singh <balbir@in.ibm.com>, xemul@sw.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

> On 2/19/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>>Alas, I fear this might have quite bad worst-case behaviour.  One small
>>container which is under constant memory pressure will churn the
>>system-wide LRUs like mad, and will consume rather a lot of system time.
>>So it's a point at which container A can deleteriously affect things which
>>are running in other containers, which is exactly what we're supposed to
>>not do.
> 
> 
> I think it's OK for a container to consume lots of system time during
> reclaim, as long as we can account that time to the container involved
> (i.e. if it's done during direct reclaim rather than by something like
> kswapd).
hmm, is it ok to scan 100Gb of RAM for 10MB RAM container?
in UBC patch set we used page beancounters to track containter pages.
This allows to make efficient scan contoler and reclamation.

Thanks,
Kirill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
