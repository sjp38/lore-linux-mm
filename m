Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id B0C0D6B0032
	for <linux-mm@kvack.org>; Thu, 30 May 2013 15:18:14 -0400 (EDT)
Message-ID: <51A7A5F3.4040704@sr71.net>
Date: Thu, 30 May 2013 12:18:11 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] sparsemem: BUILD_BUG_ON when sizeof mem_section is non-power-of-2
References: <51A78EC4.4080703@intel.com> <1369939248-10006-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1369939248-10006-1-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Hansen <dave.hansen@intel.com>

On 05/30/2013 11:40 AM, Cody P Schafer wrote:
> Instead of leaving a hidden trap for the next person who comes along and
> wants to add something to mem_section, add a big fat warning about it
> needing to be a power-of-2, and insert a BUILD_BUG_ON() in sparse_init()
> to catch mistakes.
> 
> Right now non-power-of-2 mem_sections cause a number of WARNs at boot
> (which don't clearly point to the size of mem_section as an issue), but
> the system limps on (temporarily, at least).
> 
> This is based upon Dave Hansen's earlier RFC where he ran into the same
> issue:
> 	"sparsemem: fix boot when SECTIONS_PER_ROOT is not power-of-2"
> 	http://lkml.indiana.edu/hypermail/linux/kernel/1205.2/03077.html

Thanks for doing that, Cody.  At the risk of patting myself on the back:

Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
