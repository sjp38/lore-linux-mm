Date: Thu, 5 Feb 2004 12:23:28 -0700
From: Deepak Saxena <dsaxena@plexity.net>
Subject: Re: 2.6.2-mm1 aka "Geriatric Wombat"
Message-ID: <20040205192328.GA25331@plexity.net>
Reply-To: dsaxena@plexity.net
References: <20040205014405.5a2cf529.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040205014405.5a2cf529.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On Feb 05 2004, at 01:44, Andrew Morton was caught saying:
> 
> +dmapool-needs-pci.patch
> 
>  The dmapool code doesn't build with CONFIG_PCI=n.  But it should.  Needs
>  work.

Hmm..that defeats the purpose of making it generic. :(

I was able to build w/o PCI for an SA1100 platform, so I'm assuming 
this is an x86 issue.  I'll dig into it when I get some free time.
I only have x86 and arm toolchains, so can folks on other non-PCI
architectures remove the dmapool-needs-pci.patch and try building 
w/o PCI.

~Deepak

-- 
Deepak Saxena - dsaxena at plexity dot net - http://www.plexity.net/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
