Date: Thu, 7 Aug 2003 00:05:42 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test2-mm5
Message-Id: <20030807000542.5cbf0a56.akpm@osdl.org>
In-Reply-To: <28050000.1060237907@[10.10.2.4]>
References: <20030806223716.26af3255.akpm@osdl.org>
	<28050000.1060237907@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> I get lots of these .... (without 4/4 turned on)
> 
>   Badness in as_dispatch_request at drivers/block/as-iosched.c:1241

yes, it happens with aic7xxx as well.  Sorry about that.

You'll need to revert 

	ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test2/2.6.0-test2-mm5/broken-out/as-no-trinary-states.patch
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
