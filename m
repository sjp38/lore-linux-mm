Date: Mon, 3 Jan 2005 12:17:07 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page migration
Message-ID: <20050103201707.GQ29332@holomorphy.com>
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost> <41D99743.5000601@sgi.com> <1104781061.25994.19.camel@localhost> <41D9A7DB.2020306@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41D9A7DB.2020306@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 03, 2005 at 02:15:23PM -0600, Ray Bryant wrote:
> If the consensus is that the correct way to go is to propose the
> memory migration patches as they are, then that is fine by me.  I will
> get my "NUMA process and memory migration" patch working on top of that
> (so that we have a user) and then work with Andrew to get them into -mm
> and then see what happens from there.

Please don't limit the scope of page migration to that; cross-zone page
migration is needed to resolve pathologies arising in swapless systems.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
