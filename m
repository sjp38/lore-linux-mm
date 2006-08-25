Date: Fri, 25 Aug 2006 08:51:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/4] VM deadlock prevention -v5
In-Reply-To: <20060825153946.24271.42758.sendpatchset@twins>
Message-ID: <Pine.LNX.4.64.0608250849480.9083@schroedinger.engr.sgi.com>
References: <20060825153946.24271.42758.sendpatchset@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Indan Zupancic <indan@nul.nu>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Aug 2006, Peter Zijlstra wrote:

> The basic premises is that network sockets serving the VM need undisturbed
> functionality in the face of severe memory shortage.
> 
> This patch-set provides the framework to provide this.

Hmmm.. Is it not possible to avoid the memory pools by 
guaranteeing that a certain number of page is easily reclaimable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
