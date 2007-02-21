Received: by ug-out-1314.google.com with SMTP id s2so1091528uge
        for <linux-mm@kvack.org>; Wed, 21 Feb 2007 07:33:31 -0800 (PST)
Message-ID: <84144f020702210733s4576076cw7e9a2257d28b278b@mail.gmail.com>
Date: Wed, 21 Feb 2007 17:33:31 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 02/29] mm: slab allocation fairness
In-Reply-To: <20070221144841.751839000@taijtu.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
	 <20070221144841.751839000@taijtu.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On 2/21/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> [AIM9 results go here]

Yes please. I would really like to know what we gain by making the
slab even more complex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
