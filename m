Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA666B0071
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 14:14:44 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id v10so4036762qac.21
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 11:14:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v4si2356449qcz.47.2014.12.11.11.14.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Dec 2014 11:14:43 -0800 (PST)
Date: Thu, 11 Dec 2014 19:11:40 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
Message-ID: <20141211191140.1ebb74a6@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1412111117510.31381@gentwo.org>
References: <20141210163017.092096069@linux.com>
	<20141211143518.02c781ee@redhat.com>
	<alpine.DEB.2.11.1412110902450.28416@gentwo.org>
	<20141211175058.64a1c2fc@redhat.com>
	<alpine.DEB.2.11.1412111117510.31381@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo.kim@lge.com, brouer@redhat.com

On Thu, 11 Dec 2014 11:18:31 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Thu, 11 Dec 2014, Jesper Dangaard Brouer wrote:
> 
> > I was expecting to see at least (specifically) 4.291 ns improvement, as
> > this is the measured[1] cost of preempt_{disable,enable] on my system.
> 
> Right. Those calls are taken out of the fastpaths by this patchset for
> the CONFIG_PREEMPT case. So the numbers that you got do not make much
> sense to me.

True, that is also that I'm saying.  I'll try to figure out that is
going on, tomorrow.

You are welcome to run my test harness:
 http://netoptimizer.blogspot.dk/2014/11/announce-github-repo-prototype-kernel.html
 https://github.com/netoptimizer/prototype-kernel/blob/master/getting_started.rst

Just load module: time_bench_kmem_cache1
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_kmem_cache1.c

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
