Date: Mon, 27 Aug 2007 20:35:10 +0100
From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH 1/4] export __put_task_struct for XPMEM
Message-ID: <20070827193510.GJ21089@ftp.linux.org.uk>
References: <20070827155622.GA25589@sgi.com> <20070827155933.GB25589@sgi.com> <20070827161327.GG21089@ftp.linux.org.uk> <20070827181056.GA30176@sgi.com> <20070827181544.GH21089@ftp.linux.org.uk> <20070827191906.GB30176@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070827191906.GB30176@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dean Nelson <dcn@sgi.com>
Cc: akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 27, 2007 at 02:19:06PM -0500, Dean Nelson wrote:

> No operations can be done once it's closed, only while it's opened.

What the hell do you mean, can't be done?

	fd = open(...);
	fp = popen("/bin/date", "r");
	/* read from fp */
	fclose(fp);
	do operations on fd

And you've got yourself
	open
	fork duplicating descriptor
	exit closing that duplicate
	IO on original, after call of flush

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
