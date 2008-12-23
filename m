Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 82E846B0044
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 08:29:29 -0500 (EST)
Received: by nf-out-0910.google.com with SMTP id c10so460007nfd.6
        for <linux-mm@kvack.org>; Tue, 23 Dec 2008 05:29:27 -0800 (PST)
Message-ID: <961aa3350812230529y39b99c90ned87fe590b6b7afb@mail.gmail.com>
Date: Tue, 23 Dec 2008 22:29:27 +0900
From: "Akinobu Mita" <akinobu.mita@gmail.com>
Subject: Re: [PATCH] failslab for SLUB
In-Reply-To: <Pine.LNX.4.64.0812231459580.18017@melkki.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081223103616.GA7217@localhost.localdomain>
	 <Pine.LNX.4.64.0812231459580.18017@melkki.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> The code duplication in your patch is unfortunate. What do you think of
> this patch instead?

Oh, looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
