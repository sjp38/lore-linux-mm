Date: Wed, 21 May 2008 10:46:43 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] [mm] limit the min_free_kbytes
Message-ID: <20080521104643.3c7165ce@core>
In-Reply-To: <1211362481-2136-1-git-send-email-leoli@freescale.com>
References: <1211362481-2136-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Yang <leoli@freescale.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kong Wei <weikong@redflag-linux.com>
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008 17:34:41 +0800
Li Yang <leoli@freescale.com> wrote:

> From: Kong Wei <weikong@redflag-linux.com>
> 
> Unlimited of min_free_kbytes is dangerous,
> An user of our company set this value bigger than 3584*1024*K,
> cause the system OOM on DMA.

You need to be root to set this value, and as root you could equally just
type "halt", run a real time process in a tight loop or reformat the hard
disk.

NAK this patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
