Date: Thu, 24 Apr 2003 02:14:54 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.68-mm2
Message-ID: <20030424091454.GP8978@holomorphy.com>
References: <20030423012046.0535e4fd.akpm@digeo.com> <20030423095926.GJ8931@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030423095926.GJ8931@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rml@tech9.net
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2003 at 02:59:26AM -0700, William Lee Irwin III wrote:
> rml and I coordinated to put together a small patch (combining both
> our own) for properly locking the static variables in out_of_memory().
> There's not any evidence things are going wrong here now, but it at
> least addresses the visible lack of locking in out_of_memory().
> Applies cleanly to 2.5.68-mm2.

Improved OOM killer behavior verified on 64GB i386.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
