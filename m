Date: Tue, 28 Aug 2007 19:02:35 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/4] add SGI Altix cross partition memory (XPMEM) driver
Message-ID: <20070828180235.GB32585@infradead.org>
References: <20070827155622.GA25589@sgi.com> <20070827164112.GF25589@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070827164112.GF25589@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dean Nelson <dcn@sgi.com>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, jes@sgi.com
List-ID: <linux-mm.kvack.org>

Big fat NACK, for dirty VM tricks, playing with task_struct lifetimes,
and last but not least the horrible ioctl "API".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
