Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5A98A6B0093
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 16:06:26 -0400 (EDT)
Message-ID: <517ED2A6.5030200@infradead.org>
Date: Mon, 29 Apr 2013 13:05:58 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: linux-next: Tree for Apr 29
References: <20130429191754.8ee71fb814790bf345516ab8@canb.auug.org.au>
In-Reply-To: <20130429191754.8ee71fb814790bf345516ab8@canb.auug.org.au>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On 04/29/13 02:17, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20130426:
> 


(who is responsible for MEM_SOFT_DIRTY?)


on x86_64:

warning: (HWPOISON_INJECT && MEM_SOFT_DIRTY) selects PROC_PAGE_MONITOR which has unmet direct dependencies (PROC_FS && MMU)

because MEM_SOFT_DIRTY selects PROC_PAGE_MONITOR when CONFIG_PROC_FS is not enabled.


Can MEM_SOFT_DIRTY depend on PROC_FS?

and the help text for MEM_SOFT_DIRTY refers to Documentation/vm/soft-dirty.txt,
which does not exist.  Please add the file.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
