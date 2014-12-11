Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1108A6B0071
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 14:15:49 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so5568991pdj.14
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 11:15:48 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id cc10si3189883pdb.37.2014.12.11.11.15.46
        for <linux-mm@kvack.org>;
        Thu, 11 Dec 2014 11:15:47 -0800 (PST)
Date: Thu, 11 Dec 2014 14:15:38 -0500 (EST)
Message-Id: <20141211.141538.912268168491944997.davem@davemloft.net>
Subject: Re: [RFC PATCH 1/3] lib: adding an Array-based Lock-Free (ALF)
 queue
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141210141512.31779.96487.stgit@dragon>
References: <20141210141332.31779.56391.stgit@dragon>
	<20141210141512.31779.96487.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: brouer@redhat.com
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux.com, linux-api@vger.kernel.org, eric.dumazet@gmail.com, hannes@stressinduktion.org, alexander.duyck@gmail.com, ast@plumgrid.com, paulmck@linux.vnet.ibm.com, mathieu.desnoyers@efficios.com, rostedt@goodmis.org

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 10 Dec 2014 15:15:26 +0100

> +static inline int
> +alf_mp_enqueue(const u32 n;
> +	       struct alf_queue *q, void *ptr[n], const u32 n)
> +{
 ...
> +/* Main Multi-Consumer DEQUEUE */
> +static inline int
> +alf_mc_dequeue(const u32 n;
> +	       struct alf_queue *q, void *ptr[n], const u32 n)
> +{

I would seriously consider not inlining these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
