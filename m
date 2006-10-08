Date: Sun, 8 Oct 2006 10:33:45 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: mm section mismatches
In-Reply-To: <20061006184930.855d0f0b.akpm@google.com>
Message-ID: <Pine.LNX.4.64.0610081030100.2562@sbz-30.cs.Helsinki.FI>
References: <20061006184930.855d0f0b.akpm@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: linux-mm@kvack.org, Christoph Lameter <christoph@lameter.com>
List-ID: <linux-mm.kvack.org>

Hola Senor Morton,

On Fri, 6 Oct 2006, Andrew Morton wrote:
> i386 allmoconfig, -mm tree:
> 
> WARNING: vmlinux - Section mismatch: reference to .init.data:initkmem_list3 from .text between 'set_up_list3s' (at offset 0xc016ba8e) and 'kmem_flagcheck'
> 
> any takers?

setup_cpu_cache is a non-init function that calls set_up_list3s which is 
init.  However, due to g_cpucache_up, we will never hit the branch in 
setup_cpu_cache that calls set_up_list3s.

No idea how to fix the warning. Due to g_cpucache_up, we need some entry 
point that calls both init and non-init functions... Christoph?

				Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
