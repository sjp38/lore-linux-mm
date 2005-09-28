Date: Wed, 28 Sep 2005 14:09:12 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [patch] Reset the high water marks in CPUs pcp list
In-Reply-To: <1127939185.5046.17.camel@akash.sc.intel.com>
Message-ID: <Pine.LNX.4.62.0509281408480.15213@schroedinger.engr.sgi.com>
References: <20050928105009.B29282@unix-os.sc.intel.com>
 <Pine.LNX.4.62.0509281259550.14892@schroedinger.engr.sgi.com>
 <1127939185.5046.17.camel@akash.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, Mattia Dongili <malattia@linux.it>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Sep 2005, Rohit Seth wrote:

> CONFIG_NUMA needs to be defined for that.  And then too for flushing the
> remote pages.  Also, when are you flushing the local pcps.  Also note
> that this patch is just bringing the free pages on the pcp list closer
> to what used to be the number earlier.

What was the reason for the increase of those numbers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
