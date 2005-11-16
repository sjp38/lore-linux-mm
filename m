From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 01/05] NUMA: Generic code
Date: Wed, 16 Nov 2005 09:38:14 +0100
References: <20051110090920.8083.54147.sendpatchset@cherry.local> <p73sltxowx4.fsf@verdi.suse.de> <aec7e5c30511152357g560127c6n88d0bce3b5a2f4e@mail.gmail.com>
In-Reply-To: <aec7e5c30511152357g560127c6n88d0bce3b5a2f4e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511160938.14992.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pj@sgi.com, werner@almesberger.net
List-ID: <linux-mm.kvack.org>

On Wednesday 16 November 2005 08:57, Magnus Damm wrote:

> 
> Sorry, but which one did not work very well? CKRM memory controller or
> NUMA emulation + CPUSETS?

Using simulated nodes for controlling memory.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
