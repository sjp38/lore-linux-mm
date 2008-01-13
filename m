Date: Sun, 13 Jan 2008 00:18:27 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 18/19] account mlocked pages
Message-ID: <20080113001827.76e5a64c@bree.surriel.com>
In-Reply-To: <20080111125109.GC19814@balbir.in.ibm.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210019.684039300@redhat.com>
	<20080111125109.GC19814@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jan 2008 18:21:09 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Rik van Riel <riel@redhat.com> [2008-01-08 15:59:57]:
> 
> The following patch is required to compile the code with
> CONFIG_NORECLAIM enabled and CONFIG_NORECLAIM_MLOCK disabled.

I have untangled the #ifdefs to make things compile with
all combinations of config settings.  Thanks for pointing
out this problem.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
