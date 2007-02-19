Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id l1J96DFJ016089
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 09:06:13 GMT
Received: from nf-out-0910.google.com (nfal35.prod.google.com [10.48.63.35])
	by spaceape10.eur.corp.google.com with ESMTP id l1J9623B022763
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 09:06:12 GMT
Received: by nf-out-0910.google.com with SMTP id l35so2589519nfa
        for <linux-mm@kvack.org>; Mon, 19 Feb 2007 01:06:10 -0800 (PST)
Message-ID: <6599ad830702190106m3f391de4x170326fef2e4872@mail.gmail.com>
Date: Mon, 19 Feb 2007 01:06:10 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH][0/4] Memory controller (RSS Control)
In-Reply-To: <20070219005441.7fa0eccc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop>
	 <20070219005441.7fa0eccc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@in.ibm.com>, linux-kernel@vger.kernel.org, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

On 2/19/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> Alas, I fear this might have quite bad worst-case behaviour.  One small
> container which is under constant memory pressure will churn the
> system-wide LRUs like mad, and will consume rather a lot of system time.
> So it's a point at which container A can deleteriously affect things which
> are running in other containers, which is exactly what we're supposed to
> not do.

I think it's OK for a container to consume lots of system time during
reclaim, as long as we can account that time to the container involved
(i.e. if it's done during direct reclaim rather than by something like
kswapd).

Churning the LRU could well be bad though, I agree.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
