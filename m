Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Tue, 15 Jan 2019 09:05:10 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: Make CONFIG_FRAME_VECTOR a visible option
Message-ID: <20190115170510.GA4274@infradead.org>
References: <20190115164435.8423-1-olof@lixom.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115164435.8423-1-olof@lixom.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 15, 2019 at 08:44:35AM -0800, Olof Johansson wrote:
> CONFIG_FRAME_VECTOR was made an option to avoid including the bloat on
> platforms that try to keep footprint down, which makes sense.
> 
> The problem with this is external modules that aren't built in-tree.
> Since they don't have in-tree Kconfig, whether they can be loaded now
> depends on whether your kernel config enabled some completely unrelated
> driver that happened to select it. That's a weird and unpredictable
> situation, and makes for some awkward requirements for the standalone
> modules.
> 
> For these reasons, give someone the option to manually enable this when
> configuring the kernel.

NAK, we should not confuse kernel users for stuff that is out of tree.
