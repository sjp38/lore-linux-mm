Date: Wed, 11 Jun 2008 08:57:24 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: 2.6.26-rc5-mm2: OOM with 1G free swap
Message-ID: <20080611085724.1c18164f@bree.surriel.com>
In-Reply-To: <20080610232705.3aaf5c06.akpm@linux-foundation.org>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
	<20080611060029.GA5011@martell.zuzino.mipt.ru>
	<20080610232705.3aaf5c06.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 23:27:05 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> Well I assume that Rik ran LTP.  Perhaps a merge problem.

> Zero pages on active_anon and inactive_anon.  I suspect we lost those pages.

Known problem.  I fixed this one in the updates I sent you last night.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
