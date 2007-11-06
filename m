Date: Mon, 5 Nov 2007 20:00:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [git Patch] mm/util.c: Remove needless code
In-Reply-To: <20071106031207.GA2478@hacking>
Message-ID: <Pine.LNX.4.64.0711051958380.23689@schroedinger.engr.sgi.com>
References: <20071106031207.GA2478@hacking>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Dong Pu <cocobear.cn@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007, WANG Cong wrote:


> If the code can be executed there, 'new_size' is always larger
> than 'ks'. Thus min() is needless.

Correct.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
