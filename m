Date: Fri, 9 Jan 2004 14:47:23 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.1-mm1
Message-ID: <20040109144723.A24989@infradead.org>
References: <20040109014003.3d925e54.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040109014003.3d925e54.akpm@osdl.org>; from akpm@osdl.org on Fri, Jan 09, 2004 at 01:40:03AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, heiko.carstens@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, Jan 09, 2004 at 01:40:03AM -0800, Andrew Morton wrote:
> - A large s390 update.  Various device drivers and IO layer changes there.

The zfcp driver adds a __setup function and lots of idef MODULE code.
Please don't do this for new driver (zfcp is new in 2.6).  the proper
module_param macros work for both modular and builtin use.

adding MODULE ifdefs is a lartable offense :)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
