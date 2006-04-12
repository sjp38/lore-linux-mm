Date: Wed, 12 Apr 2006 10:23:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] squash duplicate page_to_pfn and pfn_to_page
Message-Id: <20060412102334.0553cdea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060411194539.GA2507@shadowen.org>
References: <20060411194539.GA2507@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Apr 2006 20:45:39 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> squash duplicate page_to_pfn and pfn_to_page
> 
> We have architectures where the size of page_to_pfn and pfn_to_page
> are significant enough to overall image size that they wish to
> push them out of line.  However, in the process we have grown
> a second copy of the implementation of each of these routines
> for each memory model.  Share the implmentation exposing it either
> inline or out-of-line as required.
> 

Thank you for elimination of duplicated codes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
