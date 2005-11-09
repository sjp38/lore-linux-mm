Date: Tue, 8 Nov 2005 16:17:33 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH]: Cleanup of __alloc_pages
Message-Id: <20051108161733.0814c12b.pj@sgi.com>
In-Reply-To: <20051107174349.A8018@unix-os.sc.intel.com>
References: <20051107174349.A8018@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rohit, Seth" <rohit.seth@intel.com>
Cc: akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If you're going to remove the early reclaim logic, then
lets also nuke the related apparatus: should_reclaim_zone()
and __GFP_NORECLAIM (which is used in a couple of pagemap.h
macros as well)?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
