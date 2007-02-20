Date: Tue, 20 Feb 2007 12:57:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] free swap space when (re)activating page
In-Reply-To: <45DB51E3.8090909@redhat.com>
Message-ID: <Pine.LNX.4.64.0702201257190.16830@schroedinger.engr.sgi.com>
References: <45D63445.5070005@redhat.com> <Pine.LNX.4.64.0702192048150.9934@schroedinger.engr.sgi.com>
 <45DAF794.2000209@redhat.com> <Pine.LNX.4.64.0702200833460.13913@schroedinger.engr.sgi.com>
 <45DB25E1.7030504@redhat.com> <Pine.LNX.4.64.0702201015590.14497@schroedinger.engr.sgi.com>
 <45DB4C87.6050809@redhat.com> <45DB51E3.8090909@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Feb 2007, Rik van Riel wrote:

 > Btw, why do we not call pagevec_strip on the pages on l_active?
> I assume we want to reclaim their buffer heads, too...

But those buffer heads may be used soon. So its better to leave them 
alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
