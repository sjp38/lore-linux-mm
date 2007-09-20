Message-ID: <46F2DC5A.3030500@sgi.com>
Date: Thu, 20 Sep 2007 13:47:22 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] x86: Convert cpuinfo_x86 array to a per_cpu array
References: <20070920204932.663196000@sgi.com> <20070920204932.927174000@sgi.com>
In-Reply-To: <20070920204932.927174000@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

travis@sgi.com wrote:

> 
> This patch is based on 2.6.23-rc6 with the prior per_cpu patches
> applied.  I can also provide a version based on 2.6.23-rc4-mm1 
> which has some different changes.
> 

I just noticed that 2.6.23-rc6-mm1 is now available.  I will rebase
this patch on that version as there are some significant differences.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
