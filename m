Date: Fri, 29 Dec 2006 02:30:37 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] introduce config option to disable DMA zone on i386
Message-ID: <20061228173037.GA22099@linux-sh.org>
References: <20061228170302.GA4335@dmt>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061228170302.GA4335@dmt>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, olpc-devel@laptop.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 28, 2006 at 03:03:02PM -0200, Marcelo Tosatti wrote:
> The following patch adds a config option to get rid of the DMA zone on i386.
> 
> Architectures with devices that have no addressing limitations (eg. PPC)
> already work this way.
> 
> This is useful for custom kernel builds where the developer is certain that 
> there are no address limitations.
> 
Don't know if you're aware or not, but there's already a CONFIG_ZONE_DMA
in -mm that accomplishes this, which goes a bit further in that it rips
out all of the generic ZONE_DMA references. Quite a few architectures
that have no interest in the zone are using this already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
