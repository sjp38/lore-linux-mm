Date: Tue, 28 Aug 2007 14:00:43 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 4/4] add SGI Altix cross partition memory (XPMEM) driver
Message-ID: <20070828190043.GB7140@lnx-holt.americas.sgi.com>
References: <20070827155622.GA25589@sgi.com> <20070827164112.GF25589@sgi.com> <20070828180235.GB32585@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070828180235.GB32585@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Dean Nelson <dcn@sgi.com>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, jes@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 28, 2007 at 07:02:35PM +0100, Christoph Hellwig wrote:
> Big fat NACK, for dirty VM tricks, playing with task_struct lifetimes,
> and last but not least the horrible ioctl "API".

The ioctl is sort of historical.  IIRC, in ProPack 3 (RHEL4 based 2.4
kernel), we added system calls.  When the community started making noise
about system calls being bad, we went to a device special file with a
read/write (couldn't get the needed performance from the ioctl() interface
which used to acquire the BKL).  Now that the community fixed the ioctl
issues, we went to using an ioctl, but are completely open to change.

If you want to introduce system calls, we would expect to need, IIRC, 8.
We also pondered an xpmem filesystem today.  It really felt wrong,
but we could pursue that as an alternative.

What is the correct direction to go with this?  get_user_pages() does
currently require the task_struct.  Are you proposing we develop a way
to fault pages without the task_struct of the owning process/thread group?


Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
