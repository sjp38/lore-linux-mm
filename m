Date: Tue, 11 Nov 2003 19:45:25 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: 2.6.0-test9-mm2
Message-ID: <20031112034525.GI2014@mis-mike-wstn.matchmail.com>
References: <20031104225544.0773904f.akpm@osdl.org> <3FB11B93.60701@reactivated.net> <3FB18A69.6020104@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3FB18A69.6020104@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Daniel Drake <dan@reactivated.net>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 12, 2003 at 12:18:33PM +1100, Nick Piggin wrote:
> Switching from X to console or back can cause high CPU scheduling
> latencies. I haven't tried to discover why.

I've heard that it's because of the locking in the tty layer.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
